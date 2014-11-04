#Thread Safe Execution Purposes
module AutomationObject
  module Driver
    class Driver
      @@anonymous_skip_classes = [TrueClass, FalseClass, String, Numeric, Array, Hash]
      attr_accessor :mutex_object

      @@throttle_methods = {
          'navigate' => 2, #Appears the navigate to returns before url is even done
          'close' => 1
          #'find_element' => 0.1, #Connection refused event
          #'find_elements' => 0.1,
          #'exists?' => 0.05,
          #'switch_to' => 0.5,
          #'set_context' => 0.5,
          #'manage' => 0.5
      }

      @@minimum_speed = 0 #0.01 #Speed it up to see where faults may lay

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

      def initialize(driver_object)
        @driver_object = driver_object
        self.mutex_object = Mutex.new
      end

      def respond_to?(method_symbol, include_private = false)
        self.mutex_object.synchronize do
          return true if super.respond_to?(method_symbol)
          return @driver_object.respond_to?(method_symbol, include_private)
        end
      end

      def method_missing(method_symbol, *arguments, &block)
        anonymous_object = nil
        start_time = Time.new.to_f

        self.mutex_object.synchronize do
          #For Appium because it's under driver method
          if @driver_object.respond_to?(:driver) and not @driver_object.respond_to?(method_symbol)
            driver_return = @driver_object.driver.send(method_symbol, *arguments, &block)
          else
            driver_return = @driver_object.send(method_symbol, *arguments, &block)
          end

          self.throttle_speed(method_symbol, start_time)

          total_time_taken = (Time.new.to_f-start_time)
          AutomationObject::Logger::add_driver_message(total_time_taken, caller_locations, method_symbol, *arguments, &block)

          @@anonymous_skip_classes.each { |skip_class|
            if driver_return.is_a?(skip_class)
              return driver_return
            end
          }

          anonymous_object = AutomationObject::Driver::Anonymous.new(self, driver_return)
        end

        return anonymous_object
      end

      def exists?(selector_type, selector_path)
        start_time = Time.new.to_f

        self.mutex_object.synchronize do
          if @driver_object.respond_to?(:exists) #Appium
            exists = @driver_object.exists { @driver_object.find_element(selector_type, selector_path) }
          else
            begin
              element_objects = @driver_object.find_elements(selector_type, selector_path)

              if element_objects.length == 0
                exists = false
              else
                exists = true
              end
            rescue
              exists = false
            end
          end

          self.throttle_speed(:exists?, start_time)

          total_time_taken = (Time.new.to_f-start_time)
          AutomationObject::Logger::add_driver_message(total_time_taken, caller_locations, :exists?, [selector_type, selector_path])

          return exists
        end
      end

      def find_element(selector_type, selector_path)
        start_time = Time.new.to_f

        self.mutex_object.synchronize do
          element_object = @driver_object.find_element(selector_type, selector_path)

          self.throttle_speed(:find_element, start_time)

          total_time_taken = (Time.new.to_f-start_time)
          AutomationObject::Logger::add_driver_message(total_time_taken, caller_locations, :find_element, [selector_type, selector_path])

          return AutomationObject::Driver::Element.new(self, element_object)
        end
      end

      def find_elements(selector_type, selector_path)
        start_time = Time.new.to_f

        self.mutex_object.synchronize do
          element_objects = @driver_object.find_elements(selector_type, selector_path)

          parsed_element_objects = Array.new
          element_objects.each { |element_object|
            parsed_element_objects.push(AutomationObject::Driver::Element.new(self, element_object))
          }

          self.throttle_speed(:find_elements, start_time)

          total_time_taken = (Time.new.to_f-start_time)
          AutomationObject::Logger::add_driver_message(total_time_taken, caller_locations, :find_elements, [selector_type, selector_path])

          return parsed_element_objects
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
    end
  end
end