module AutomationObject
  module FrameworkHelpers
    attr_accessor :is_mobile, :is_browser, :supports_contexts

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
      available_contexts = self.driver_object.available_contexts
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
        self.driver_object.window_handles
        return true
      rescue NoMethodError, Selenium::WebDriver::Error::UnknownError
        return false
      end
    end

    #Appium's use of window_handles
    def supports_contexts?
      return self.supports_contexts if self.supports_contexts != nil

      begin
        self.driver_object.available_contexts
        self.supports_contexts = true
        return true
      rescue NoMethodError
        return false
      end
    end

    def current_screen
      current_screen_object = Object.new
      current_screen_object.class.module_eval { attr_accessor :framework_object }
      current_screen_object.framework_object = self

      def current_screen_object.method_missing(method_symbol, *args, &block)
        return self.framework_object.send(self.framework_object.get_current_screen).send(method_symbol, *args, &block)
      end

      current_screen_object
    end

    def get_current_screen
      return self.translate_class_to_string(self.current_screen_class).to_sym
    end

    def kill_monitor_threads
      begin
        self.screen_monitor_thread.each_value { |thread|
          Thread.kill(thread) if thread
        }
      rescue
        # ignored
      end
    end

    def quit
      AutomationObject::Logger::add('Quitting the framework')
      self.kill_monitor_threads

      if self.driver_object.respond_to?(:quit)
        self.driver_object.quit if self.driver_object.respond_to?(:quit)
      elsif self.driver_object.respond_to?(:driver_quit)
        self.driver_object.driver_quit if self.driver_object.respond_to?(:driver_quit)
      else
        raise 'Unable to find provided driver quit method'
      end
    end
  end
end