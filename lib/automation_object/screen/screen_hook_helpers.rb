module AutomationObject
  module ScreenHookHelpers
    def hook_listener(args)
      self.hook(args[:configuration], args[:created_window_handle])
    end

    def before_load
      AutomationObject::Logger::add('Running Before Load Hook', [self.framework_location])

      return unless self.configuration.has_key?('before_load')
      unless self.configuration['before_load'].class == Hash
        raise ArgumentError, "Expecting before_load in screen (#{self.screen_name}) to be a Hash"
      end

      self.hook(self.configuration['before_load'])
    end

    def hook(configuration, created_window_handle = false)
      #Use each, allow for ordering of wait, change_screen in configuration
      configuration.each { |key, value|
        case key
          when 'wait_for_new_window'
            unless value == true
              raise ArgumentError, "Only expecting the value of true for wait_for_new_window hook in screen (#{self.screen_name})"
            end
            created_window_handle = self.wait_for_new_window unless created_window_handle
          when 'show_modal'
            #Add modal to active modal, prevent multiple requests to do the same thing or error out
            self.activate_modal(self.translate_string_to_class(value))
          when 'close_window'
            self.close_window(true) #Don't close the window, already closed
          when 'change_screen'
            screen_class_symbol = self.translate_string_to_class(value)
            self.emit :change_screen, {
                :screen_class_symbol => screen_class_symbol,
                :created_window_handle => created_window_handle
            }
          when 'sleep'
            sleep(value.to_f)
          when 'wait_for_elements'
            self.wait_for_elements(value)
          when 'change_to_previous_screen'
            self.emit :change_screen, {
                :screen_class_symbol => self.framework_object.previous_screen_class,
                :created_window_handle => created_window_handle
            }
          when 'close_modal'
            self.active_modal = nil
          when 'automatic_onload_modals'
            self.automatic_onload_modals_hook(value)
          when 'reset_screen'
            self.reset_screen(true)
          else
            raise ArgumentError, "Hook requested (#{key}) is not implemented, found in screen #{self.screen_name}"
        end
      }
    end

    def automatic_onload_modals_hook(configuration)
      return unless configuration.class == Array

      configuration.each { |modal_configuration|
        next unless modal_configuration.class == Hash
        next unless modal_configuration.has_key?('modal_name')


        if modal_configuration['number_of_checks']
          number_of_checks = modal_configuration['number_of_checks'].to_i
        else
          number_of_checks = 10
        end

        number_of_checks.times do
          modal_symbol = self.translate_string_to_class(modal_configuration['modal_name'])
          if self.send(modal_symbol).live?
            self.activate_modal(modal_symbol)
            if modal_configuration['action'] == 'close'
              self.close_modal(modal_symbol)
            end
            break
          end

          sleep(1)
        end
      }
    end

    def wait_for_new_window
      loops = 0
      max_loops = 30
      loop_sleep = 1

      stored_window_handles = self.framework_object.current_screen_hash.keys
      new_window_handle = nil

      until new_window_handle
        loops = loops + 1
        if loops > max_loops
          raise "Max loop breached waiting for new window in screen #{self.screen_name}"
        end

        window_handles = self.framework_object.get_window_handles.clone
        window_handle_difference = window_handles.length - stored_window_handles.length

        #Still waiting for new window
        if window_handle_difference == 0
          sleep(loop_sleep)
          next
        end

        window_handle_difference = window_handles - stored_window_handles

        #Throw error if more than one extra window, not sure which one to use
        if window_handle_difference.length > 1
          raise "More than one window was opened on an element action, found in screen #{self.screen_name}"
        end

        new_window_handle = window_handle_difference.shift
        break
      end

      return new_window_handle
    end

    def wait_for_elements(configuration)
      unless configuration.class == Array
        raise ArgumentError, "Expecting Array for wait_for_elements, got #{configuration.class} in screen #{self.screen_name}"
      end

      AutomationObject::Logger::add('Running Wait for Elements Hook', [self.framework_location])

      configuration.each { |element_configuration|
        unless element_configuration.class == Hash
          raise ArgumentError, "Expecting wait_for_elements array to have Hash items got #{element_configuration.class} in screen #{self.screen_name}"
        end

        unless element_configuration.has_key?('element_name')
          raise ArgumentError, "Expecting wait_for_elements array item hash to include the 'element_name' key in screen #{self.screen_name}"
        end

        element_name = element_configuration['element_name']
        element_class_symbol = self.translate_string_to_class(element_name)
        #Add exists? to requirements if it doesn't exist
        unless element_configuration.has_key?('exists?')
          unless self.send(element_class_symbol).configuration['multiple']
            element_configuration['exists?'] = true
          end
        end

        element_requirements = Hash.new
        #Always put exists? at top if exists? is true
        if element_configuration['exists?']
          element_requirements['exists?'] = true
          element_configuration.each { |key, value|
            next if key == 'exists?' || key == 'element_name'
            element_requirements[key] = value
          }
        else
          element_configuration.each { |key, value|
            next if key == 'element_name'
            element_requirements[key] = value
          }
        end

        self.wait_for_element(element_name, element_requirements)
      }
    end

    def wait_for_element(element_name, element_requirements)
      AutomationObject::Logger::add('Running Wait for Element Hook', [self.framework_location])

      element_class_symbol = self.translate_string_to_class(element_name)

      unless self.respond_to?(element_class_symbol)
        raise "Element class was not defined correctly in screen class (#{self.screen_name}) for element (#{element_name})"
      end

      element_requirements.each { |requirement, requirement_value|
        requirement_symbol = requirement.to_s.to_sym

        unless self.send(element_class_symbol).respond_to?(requirement_symbol)
          raise ArgumentError, "Element (#{element_name}) in screen (#{self.screen_name}) does not have the method (#{requirement_symbol})"
        end

        requirement_success = false

        loops = 0
        until requirement_success
          if self.send(element_class_symbol).is_multiple?
            self.send(element_class_symbol).load_elements
          end

          element_value = self.send(element_class_symbol).send(requirement)
          requirement_success = (element_value == requirement_value)

          AutomationObject::Logger::add("Waiting for element method #{requirement} got: #{element_value}, expecting: #{requirement_value}", [self.framework_location])

          sleep(1) if loops > 0

          if loops > 30
            raise "Element (#{element_name}) in screen (#{self.screen_name}) breached max wait loops for #{requirement}"
          end

          loops += 1
        end
      }
    end

    def has_live_configuration?
      return false unless self.configuration.class == Hash
      return false unless self.configuration['live?'].class == Hash

      configuration = self.configuration['live?']

      elements_array = Array.new
      elements_array.push(configuration['element']) if configuration['element'].class == Hash
      elements_array += configuration['elements'] if configuration['elements'].class == Array

      return false if elements_array.length == 0 #No elements to check

      true
    end

    def live?
      AutomationObject::Logger::add('Checking if screen is live?', [self.framework_location])

      #Make sure live? configuration is setup correctly, return false if not
      return false unless self.has_live_configuration?
      configuration = self.configuration['live?']

      self.hook(configuration['before']) if configuration['before'].class == Hash

      elements_array = Array.new
      elements_array.push(configuration['element']) if configuration['element'].class == Hash
      elements_array += configuration['elements'] if configuration['elements'].class == Array

      elements_array.each { |element_configuration|
        next unless element_configuration.class == Hash
        element_requirements = element_configuration.clone

        #Add element_name since is name conflicts with the Element Class method name()
        if element_requirements['element_name']
          element_name = element_requirements['element_name']
          element_requirements.delete('element_name')
        else
          element_name = element_requirements['name']
          element_requirements.delete('name')
        end

        unless element_name
          raise "Need to define element name in live? configuration for screen (#{self.screen_name})"
        end

        element_class_symbol = self.translate_string_to_class(element_name)

        unless element_class_symbol
          raise "Element class symbol was not defined internally in screen (#{self.screen_name}) for element (#{element_name})"
        end

        unless self.respond_to?(element_class_symbol)
          raise "Element class was not defined correctly in screen class (#{self.screen_name}) for element (#{element_name})"
        end

        #Always put exists? at top if exists? is true
        #only for AutomationObject::Element

        if self.send(element_class_symbol).class.is_a?(AutomationObject::Element)
          modified_requirements = Hash.new
          exists = true
          exists = element_requirements['exists?'] if element_requirements.has_key?('exists?')

          modified_requirements['exists?'] = exists
          element_requirements.each { |key, value|
            next if key == 'exists?'
            modified_requirements[key] = value
          }
        else
          modified_requirements = element_requirements
        end

        modified_requirements.each { |requirement, value|
          requirement_symbol = requirement.to_s.to_sym

          unless self.send(element_class_symbol).respond_to?(requirement_symbol)
            raise ArgumentError, "Element (#{element_name}) in screen (#{self.screen_name}) does not have the method (#{requirement_symbol})"
          end

          #If no element error thrown then return live? false
          # instead of throwing it through the whole program
          begin
            success = (self.send(element_name).send(requirement_symbol) == value)
          rescue Selenium::WebDriver::Error::NoSuchElementError
            return false
          end

          unless success
            self.reset_screen
            return false
          end
        }
      }

      self.hook(configuration['after']) if configuration['after'].class == Hash

      #Reset screen parts, except window handle
      self.reset_screen(true)
      true
    end
  end
end