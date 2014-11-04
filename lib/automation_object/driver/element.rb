#Thread Safe Execution Purposes
module AutomationObject
  module Driver
    class Element
      @@throttle_methods = {
          'click' => 2, #Slow down, browser given back before navigation is finished
          #'location_once_scrolled_into_view' => 0.5 #Appeared where Firefox was failing, add a little more time
      }
      @@minimum_speed = 0 #0.01

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
        @driver_object.mutex_object.synchronize do
          return true if super.respond_to?(method_symbol)
          return @element_object.respond_to?(method_symbol, include_private)
        end
      end

      def method_missing(method_symbol, *arguments, &block)
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
        element_location = @element_object.location
        element_size = @element_object.size

        box_coordinates = Hash.new
        box_coordinates[:x1] = element_location.x.to_f
        box_coordinates[:y1] = element_location.y.to_f
        box_coordinates[:x2] = element_location.x.to_f + element_size.width.to_f
        box_coordinates[:y2] = element_location.y.to_f + element_size.height.to_f

        return box_coordinates
      end
    end
  end
end