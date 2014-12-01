#Thread Safe Execution Purposes
module AutomationObject
  module Driver
    class Driver
      @@anonymous_skip_classes = [TrueClass, FalseClass, String, Numeric, Array, Hash]
      attr_accessor :mutex_object

      attr_accessor :is_browser, :is_mobile, :supports_contexts

      @@throttle_methods = {
          'navigate' => 2,
          'close' => 2,
          'manage' => 1
      }

      @@minimum_speed = 0 #0.01 #Speed it up to see where faults may lay

      @@implicit_wait_timeout = 30
      @@script_timeout = 500
      @@page_load_timeout = 500

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

        return if self.is_mobile?

        self.mutex_object.synchronize do
          @driver_object.manage.timeouts.implicit_wait = @@implicit_wait_timeout
          @driver_object.manage.timeouts.script_timeout = @@script_timeout
          @driver_object.manage.timeouts.page_load = @@page_load_timeout
        end
      end

      def respond_to?(method_symbol, include_private = false)
        self.mutex_object.synchronize do
          return true if super
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
              @driver_object.manage.timeouts.implicit_wait = 0
              element_objects = @driver_object.find_elements(selector_type, selector_path)
              @driver_object.manage.timeouts.implicit_wait = @@implicit_wait_timeout
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

      def screenshot(path)
        start_time = Time.new.to_f

        if self.driver_object.respond_to?(:screenshot)
          driver_return = self.driver_object.screenshot(path)
        else
          driver_return = self.driver_object.save_screenshot(path)
        end

        self.throttle_speed(:find_elements, start_time)

        total_time_taken = (Time.new.to_f-start_time)
        AutomationObject::Logger::add_driver_message(total_time_taken, caller_locations, :screenshot, [path])

        return driver_return
      end

      def accept_prompt
        start_time = Time.new.to_f

        if self.driver_object.respond_to?(:alert_accept)
          self.driver_object.alert_accept
        else
          alert = self.driver_object.switch_to.alert
          alert.accept
        end

        self.throttle_speed(:accept_prompt, start_time)
        return nil
      end

      def dismiss_prompt
        start_time = Time.new.to_f

        begin
          @driver_object.alert_dismiss
        rescue NoMethodError
          alert = @driver_object.switch_to.alert
          alert.dismiss
          @driver_object.switch_to.default_content
        end

        self.throttle_speed(:dismiss_prompt, start_time)
        return nil
      end

      def is_mobile?
        if self.is_mobile == nil
          self.is_mobile = self.supports_contexts?
        end

        return self.is_mobile
      end

      def is_browser?
        unless self.is_browser == nil
          return self.is_browser
        end

        #If Selenium the yeah we are using a browser
        if self.supports_window_handles?
          self.is_browser = true
          return self.is_browser
        end

        #Now we need to check Appium's contexts to see if WEBVIEW is in available_contexts
        available_contexts = nil
        self.mutex_object.synchronize do
          available_contexts = @driver_object.available_contexts
        end
        self.supports_contexts = true

        available_contexts.each { |context|
          if context.match(/^WEBVIEW_\d+$/)
            self.is_browser = true
            return self.is_browser
          end
        }

        self.is_browser = false
        return self.is_browser
      end

      #Selenium's use of window_handles
      def supports_window_handles?
        begin
          self.mutex_object.synchronize do
            @driver_object.window_handles
          end
          return true
        rescue NoMethodError, Selenium::WebDriver::Error::UnknownError
          return false
        end
      end

      #Appium's use of window_handles
      def supports_contexts?
        return self.supports_contexts if self.supports_contexts != nil

        self.mutex_object.synchronize do
          begin
            @driver_object.available_contexts
            self.supports_contexts = true
          rescue NoMethodError
            self.supports_contexts = false
          end
        end

        return self.supports_contexts
      end
    end
  end
end