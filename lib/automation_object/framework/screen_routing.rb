module AutomationObject
  module FrameworkScreenRouting
    def route_to_screen(from_screen, to_screen)
      AutomationObject::Logger::add("Trying to automatically route to screen: #{to_screen}", [from_screen])

      @from_screen = from_screen
      @to_screen = to_screen
      #Add @avoid_elements[screen_class_symbol].push(element_name),
      #to be added later if elements are invisible or disabled
      #Kind of a fail safe if elements are only sometimes disabled, try to find a new route after in this method if
      #route found isn't working
      @avoid_elements = Hash.new
      @screen_map = self.map_screens
      @route = nil

      self.recursive_route_map

      unless @route.class == Array
        AutomationObject::Logger::add("Unable to find route to screen: #{to_screen}", [from_screen])
        raise "Unable to find route between screen (#{@from_screen}) and screen (#{@to_screen})"
      end

      route_found = self.execute_route(@route)

      unless route_found
        @from_screen = self.current_screen_class
        @screen_map = self.map_screens

        self.recursive_route_map

        unless @route.class == Array
          raise "Unable to find route between screen (#{@from_screen}) and screen (#{@to_screen})"
        end

        self.execute_route(@route)
      end

      #Reset these variables
      @avoid_elements = nil
      @from_screen = nil
      @to_screen = nil
      @screen_map = nil
      @route = nil
    end

    #TODO, enable for all elements, will break except for click, accept, dismiss
    def execute_route(route)
      route.each { |direction|
        screen_configuration = self.send(self.current_screen_class).configuration

        if screen_configuration['accept'].class == Hash
          possible_change_screen = self.find_possible_change_screen(screen_configuration['accept'])
          if possible_change_screen == direction
            self.send(self.current_screen_class).accept
            next
          end
        end

        if screen_configuration.has_key?('dismiss')
          possible_change_screen = self.find_possible_change_screen(screen_configuration['dismiss'])
          if possible_change_screen == direction
            self.send(self.current_screen_class).dismiss
            next
          end
        end

        route_found = false

        #Try modals
        if screen_configuration['modals'].is_a?(Hash)
          screen_configuration['modals'].each { |modal_name, modal_configuration|
            next unless modal_configuration.is_a?(Hash)
            next unless modal_configuration['elements'].is_a?(Hash)

            modal_configuration['elements'].each { |element_name, element_configuration|
              next unless element_configuration.class == Hash
              next unless element_configuration['click'].class == Hash

              possible_change_screen = self.find_possible_change_screen(element_configuration['click'])
              if possible_change_screen == direction
                #If the elements, don't work then don't use them
                #Will implement method to try to find another way to the screen
                element_object = self.send(self.current_screen_class).send(modal_name).send(element_name)
                element_object = element_object.sample if element_object.class == ElementArray
                element_object = element_object[element_object.keys.sample] if element_object.class == ElementHash

                unless element_object.visible?
                  @avoid_elements[self.current_screen_class] = Array.new unless @avoid_elements[self.current_screen_class].class == Array
                  @avoid_elements[self.current_screen_class].push(element_name)
                  next
                end

                unless element_object.exists?
                  @avoid_elements[self.current_screen_class] = Array.new unless @avoid_elements[self.current_screen_class].class == Array
                  @avoid_elements[self.current_screen_class].push(element_name)
                  next
                end

                element_object.click
                route_found = true
                break #Stop from looping through other elements
              end
            }
            break if route_found
          }

          next if route_found
        end

        next unless screen_configuration['elements'].class == Hash

        screen_configuration['elements'].each { |element_name, element_configuration|
          next unless element_configuration.class == Hash
          next unless element_configuration['click'].class == Hash

          possible_change_screen = self.find_possible_change_screen(element_configuration['click'])
          if possible_change_screen == direction
            #If the elements, don't work then don't use them
            #Will implement method to try to find another way to the screen
            element_object = self.send(self.current_screen_class).send(element_name)
            element_object = element_object.sample if element_object.class == ElementArray
            element_object = element_object[element_object.keys.sample] if element_object.class == ElementHash

            unless element_object.visible?
              @avoid_elements[self.current_screen_class] = Array.new unless @avoid_elements[self.current_screen_class].class == Array
              @avoid_elements[self.current_screen_class].push(element_name)
              next
            end

            unless element_object.exists?
              @avoid_elements[self.current_screen_class] = Array.new unless @avoid_elements[self.current_screen_class].class == Array
              @avoid_elements[self.current_screen_class].push(element_name)
              next
            end

            element_object.click
            route_found = true
            break #Stop from looping through other elements
          end
        }

        return route_found unless route_found
      }

      true
    end

    def recursive_route_map
      @depth = 0 unless @depth.class == Fixnum
      @routes_array = Array.new unless @routes_array

      #Get where we are and start there adding every possible direction to start with
      if @depth == 0
        @screen_map[@from_screen].each { |possible_direction|
          new_route = Array.new
          new_route.push(possible_direction)
          @routes_array.push(new_route)
        }

        @depth += 1
      end

      #Better Check
      #Do validation of @routes_array find if route found and break out
      @routes_array.each { |route|
        #Get the last direction and see if its the destination
        if route.last == @to_screen
          @route = route
          @depth = nil
          @routes_array = nil
          return
        end
      }

      tmp_routes_array = Array.new
      @routes_array.each { |route|
        last_direction = route.last
        next unless @screen_map[last_direction]
        @screen_map[last_direction].each { |possible_direction|
          #Skip loops?
          next if route.include?(possible_direction)
          #Skip from screen
          next if possible_direction == @from_screen

          new_route = route.clone
          new_route.push(possible_direction)

          unless @routes_array.include?(new_route)
            tmp_routes_array.push(new_route)
          end
        }

        unless last_direction == @to_screen
          #@routes_array.delete(route)
        end
      }

      @routes_array += tmp_routes_array

      @depth += 1

      if @depth > 100
        ap @routes_array
        raise 'Could not complete route, runaway depth for from screen (' + @from_screen.to_s + ') to screen (' + @to_screen.to_s + ')'
      end

      self.recursive_route_map
    end

    def map_screens
      screen_map = Hash.new
      return screen_map unless self.configuration['screens'].class == Hash

      self.configuration['screens'].each_key { |screen_name|
        screen_class_symbol = self.translate_string_to_class(screen_name)

        next unless self.respond_to?(screen_class_symbol)
        next unless self.send(screen_class_symbol).configuration.class == Hash

        screen_map[screen_class_symbol] = Array.new unless screen_map[screen_class_symbol].class == Array

        screen_configuration = self.send(screen_class_symbol).configuration

        if screen_configuration['accept'].class == Hash
          possible_change_screen = self.find_possible_change_screen(screen_configuration['accept'])
          screen_map[screen_class_symbol].push(possible_change_screen) if possible_change_screen
        end

        if screen_configuration.has_key?('dismiss')
          possible_change_screen = self.find_possible_change_screen(screen_configuration['dismiss'])
          screen_map[screen_class_symbol].push(possible_change_screen) if possible_change_screen
        end

        #Check modals
        if screen_configuration['modals'].is_a?(Hash)
          screen_configuration['modals'].each { |modal_name, modal_configuration|
            next unless modal_configuration.is_a?(Hash)
            next unless modal_configuration['elements'].is_a?(Hash)

            modal_configuration['elements'].each { |element_name, element_configuration|
              next unless element_configuration.class == Hash
              #next if not element_configuration['click'].class == Hash

              if @avoid_elements.has_key?(screen_class_symbol)
                next if @avoid_elements[screen_class_symbol].include?(element_name)
              end

              element_configuration.each { |key, sub_configuration|
                next unless sub_configuration.class == Hash
                next if key == 'custom_methods'
                next if key == 'xpath'
                next if key == 'css'
                next if key == 'multiple'

                possible_change_screen = self.find_possible_change_screen(sub_configuration)
                screen_map[screen_class_symbol].push(possible_change_screen) if possible_change_screen
              }
            }
          }
        end

        next unless screen_configuration['elements'].class == Hash

        screen_configuration['elements'].each { |element_name, element_configuration|
          next unless element_configuration.class == Hash
          #next if not element_configuration['click'].class == Hash

          if @avoid_elements.has_key?(screen_class_symbol)
            next if @avoid_elements[screen_class_symbol].include?(element_name)
          end

          element_configuration.each { |key, sub_configuration|
            next unless sub_configuration.class == Hash
            next if key == 'custom_methods'
            next if key == 'xpath'
            next if key == 'css'
            next if key == 'multiple'

            possible_change_screen = self.find_possible_change_screen(sub_configuration)
            screen_map[screen_class_symbol].push(possible_change_screen) if possible_change_screen
          }
        }

        screen_map[screen_class_symbol] = screen_map[screen_class_symbol].uniq
      }

      screen_map
    end

    def find_possible_change_screen(configuration)
      if configuration['before'].class == Hash
        if configuration['before'].has_key?('change_screen')
          if configuration['before']['change_screen']
            return self.translate_string_to_class(configuration['before']['change_screen'])
          end
        end
      end

      if configuration['after'].class == Hash
        if configuration['after'].has_key?('change_screen')
          if configuration['after']['change_screen']
            return self.translate_string_to_class(configuration['after']['change_screen'])
          end
        end
      end

      nil
    end
  end
end