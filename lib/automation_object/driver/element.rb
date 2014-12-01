#Thread Safe Execution Purposes
module AutomationObject
  module Driver
    class Element
      @@throttle_methods = {
          'click' => 2, #Slow down, browser given back before navigation is finished
          #'location_once_scrolled_into_view' => 0.5 #Appeared where Firefox was failing, add a little more time
      }
      @@minimum_speed = 0 #0.01

      @@scroll_into_view_methods = [:click, :tap, :hover, :send_keys]

      def self.throttle_methods
        @@throttle_methods
      end

      def self.throttle_methods=(value)
        @@throttle_methods = value
      end

      def self.minimum_speed
        @@minimum_speed
      end

      def self.minimum_speed=(value)
        @@minimum_speed = value
      end

      def initialize(driver_object, element_object)
        @driver_object = driver_object
        @element_object = element_object
      end

      def respond_to?(method_symbol, include_private = false)
        return true if super
        return @element_object.respond_to?(method_symbol, include_private)
      end

      def method_missing(method_symbol, *arguments, &block)
        if @@scroll_into_view_methods.include?(method_symbol)
          self.scroll_into_view
        end

        @driver_object.mutex_object.synchronize do
          start_time = Time.new.to_f
          element_object_return = @element_object.send(method_symbol, *arguments, &block)

          self.throttle_speed(method_symbol, start_time)

          total_time_taken = (Time.new.to_f-start_time)
          AutomationObject::Logger::add_driver_element_message(total_time_taken, caller_locations, method_symbol, *arguments, &block)

          return element_object_return
        end
      end

      def throttle_speed(method_symbol, start_time)
        method_string = method_symbol.to_s

        throttle_time_minimum = @@minimum_speed
        if @@throttle_methods.is_a?(Hash)
          if @@throttle_methods.has_key?(method_string)
            throttle_time_minimum = @@throttle_methods[method_string].to_f
          end
        end

        time_difference = Time.new.to_f - start_time

        if time_difference < throttle_time_minimum
          sleep((throttle_time_minimum-time_difference))
        end
      end

      def collides_with_element?(second_element_object, collision_tolerance = false)
        box_one = self.get_box_coordinates
        box_two = second_element_object.get_box_coordinates

        collision_tolerance = 0 unless collision_tolerance.is_a?(Numeric)

        if box_one[:x2] > box_two[:x1] and box_one[:x1] < box_two[:x2] and box_one[:y2] > box_two[:y1] and box_one[:y1] < box_two[:y2]
          if box_one[:x2] > (box_two[:x1] + collision_tolerance) and (box_one[:x1] + collision_tolerance) < box_two[:x2] and
              box_one[:y2] > (box_two[:y1] + collision_tolerance) and (box_one[:y1] + collision_tolerance) < box_two[:y2]
            return true
          else
            return false
          end
        else
          return false
        end
      end

      def get_box_coordinates
        element_location = self.location
        element_size = self.size

        box_coordinates = Hash.new
        box_coordinates[:x1] = element_location.x.to_f
        box_coordinates[:y1] = element_location.y.to_f
        box_coordinates[:x2] = element_location.x.to_f + element_size.width.to_f
        box_coordinates[:y2] = element_location.y.to_f + element_size.height.to_f

        return box_coordinates
      end

      def attribute(key, value = false)
        @driver_object.mutex_object.synchronize do
          return @element_object.attribute(key) unless value
        end

        script = "return arguments[0].#{key} = '#{value}'"
        @driver_object.execute_script(script, @element_object)

        @driver_object.mutex_object.synchronize do
          return @element_object.attribute(key)
        end
      end

      def switch_to_iframe
        @driver_object.switch_to.frame(self.get_iframe_switch_value)
      end

      def get_iframe_switch_value
        iframe_switch_value = self.attribute('id')
        if iframe_switch_value.length == 0
          iframe_switch_value = self.attribute('name')
        end

        unless iframe_switch_value
          iframe_switch_value = self.attribute('name', SecureRandom.hex(16))
        end

        return iframe_switch_value
      end

      def get_element_center
        element_location = self.location
        element_size = self.size

        center = Hash.new
        center[:x] = (element_location.x.to_f + element_size.width.to_f/2).to_f
        center[:y] = (element_location.y.to_f + element_size.height.to_f/2).to_f

        return center
      end

      def x
        return self.location.x
      end

      def y
        return self.location.y
      end

      def width
        return self.size.width
      end

      def height
        return self.size.height
      end

      def hover
        self.scroll_into_view
        @driver_object.action.move_to(@element_object).perform
      end

      def visible?
        return self.displayed?
      end

      def invisible?
        return self.displayed? ? false : true
      end

      def id
        return self.attribute('id').to_s
      end

      def href
        return self.attribute('href').to_s
      end

      def content
        return self.attribute('content').to_s
      end

      def scroll_into_view
        return self.scroll_to_view
      end

      def scroll_to_view
        self.location_once_scrolled_into_view

        if @driver_object.is_mobile?
          return unless @driver_object.is_browser?

          element_center = self.get_element_center
          window_height = @driver_object.execute_script('return window.innerHeight;').to_f
          current_y_position = @driver_object.execute_script('var doc = document.documentElement; return (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);').to_f

          if element_center[:y] < (window_height/2)
            ideal_y_position = (current_y_position + element_center[:y] - (window_height.to_f / 2.0)).abs
          else
            ideal_y_position = (current_y_position - element_center[:y] + (window_height.to_f / 2.0)).abs
          end

          @driver_object.execute_script("window.scroll(#{element_center[:x].to_f},#{ideal_y_position});")
          #Just in case in close to the top or bottom bounds of the window
          element_location = self.location_once_scrolled_into_view

          if element_location[:y] < 0
            current_y_position = @driver_object.execute_script('var doc = document.documentElement; return (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);').to_f
            scroll_y_position = current_y_position + element_location[:y]
            @driver_object.execute_script("window.scroll(#{element_location[:x].to_f},#{scroll_y_position});")
          end
        else
          element_location = self.location

          window_height = @driver_object.execute_script('return window.innerHeight;').to_f
          current_scroll_position = @driver_object.execute_script('var doc = document.documentElement; return (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);').to_f

          middle_y_bounds = current_scroll_position + window_height/2

          if middle_y_bounds > element_location.y
            #Add
            y_difference = middle_y_bounds - element_location.y
            scroll_y_position = current_scroll_position - y_difference
          else
            #Subtract
            y_difference = element_location.y - middle_y_bounds
            scroll_y_position = current_scroll_position + y_difference
          end

          #Get the element to halfway
          scroll_x_position = element_location.x.to_f

          javascript_string = "return window.scroll(#{scroll_x_position}, #{scroll_y_position});"
          @driver_object.execute_script(javascript_string)
        end
      end
    end
  end
end