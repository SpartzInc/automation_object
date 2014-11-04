module AutomationObject
  module FrameworkWindowHelpers
    def get_window_handles
      window_handles = Array.new
      return window_handles unless self.is_browser?

      unless self.is_mobile?
        #Window handles for Selenium are simpler
        return self.driver_object.window_handles
      end

      #Remove everything except the WEBVIEW
      if self.driver_object.device_is_android?
        window_handles = self.driver_object.window_handles
      else
        available_contexts = self.driver_object.available_contexts
        available_contexts.each { |context|
          window_handles.push(context) if context.match(/^WEBVIEW_\d+$/)
        }
      end

      return window_handles
    end

    def get_current_window_handle
      #Selenium
      unless self.is_mobile?
        return self.driver_object.window_handle
      end

      #Appium
      if self.driver_object.device_is_android?
        return self.driver_object.window_handle
      else
        return self.driver_object.current_context
      end
    end

    def switch_to_window(window_handle)
      unless self.is_mobile?
        #Selenium
        return self.driver_object.switch_to.window(window_handle)
      end

      #Appium
      if self.driver_object.device_is_android?
        return self.driver_object.switch_to.window(window_handle)
      else
        return self.driver_object.set_context(window_handle)
      end
    end

    def check_closed_windows
      window_handles = self.get_window_handles

      self.current_screen_hash.each { |current_window_handle, current_screen_symbol|
        next if window_handles.include?(current_window_handle)

        #Delete current screen hash key
        self.current_screen_hash.delete(current_window_handle)
        self.reset_screen(current_screen_symbol)
        self.previous_screen_hash.delete(current_window_handle)

        if current_screen_symbol == self.current_screen_class
          self.previous_screen_class = nil
        end
      }
    end

    def wait_for_window_load
      AutomationObject::Logger::add('Waiting for window to load via document.readyState')
      loops = 0

      until self.document_complete?
        loops += 1

        if loops > 30
          break #Fuck it for now, just see what happens if we don't wait for this
          raise Net::ReadTimeout, 'Error waiting too long for page to load'
        end

        sleep(3)
      end
    end

    def document_complete?
      AutomationObject::Logger::add('Running document_complete? command')
      return self.driver_object.execute_script('return document.readyState;') == 'complete'
    end

    def wait_for_stable_body_size
      AutomationObject::Logger::add('Going to wait for body element size to stabilize before continuing')
      body_element_object = self.driver_object.find_element(:css, 'body')

      begin
        current_body_size = body_element_object.size
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Errno::ECONNREFUSED
        body_element_object = self.driver_object.find_element(:css, 'body')
        current_body_size = body_element_object.size
      end

      previous_width = current_body_size[:width]
      previous_height = current_body_size[:height]

      sleep(2)

      30.times do
        sizes_string = "before: #{current_body_size[:width]}x#{current_body_size[:height]}"

        begin
          current_body_size = body_element_object.size
        rescue Selenium::WebDriver::Error::StaleElementReferenceError, Errno::ECONNREFUSED
          body_element_object = self.driver_object.find_element(:css, 'body')
          current_body_size = body_element_object.size
        end

        if previous_width == current_body_size[:width] and previous_height == current_body_size[:height]
          break
        end

        sizes_string << ", after: #{current_body_size[:width]}x#{current_body_size[:height]}"
        AutomationObject::Logger::add("Running another loop for body size stabilization. #{sizes_string}")

        previous_width = current_body_size[:width]
        previous_height = current_body_size[:height]

        sleep(2)
      end
    end

    def set_window_size(x, y)
      self.driver_object.manage.window.resize_to(x, y)
    end

    def close_window(screen_name, skip_close = false)
      AutomationObject::Logger::add("Attempting to close window for screen #{screen_name}")

      screen_class_symbol = self.translate_string_to_class(screen_name)
      remove_current_handle = nil

      self.current_screen_hash.each { |window_handle, current_screen_symbol|
        next if current_screen_symbol != screen_class_symbol
        remove_current_handle = window_handle

        #Kill the thread
        self.screen_monitor_thread.each { |key, thread|
          next unless key == screen_class_symbol
          break unless thread.class == Thread
          Thread.kill(thread)

          AutomationObject::Logger::add("Killed any threads belonging to window for screen #{screen_name}")
          break
        }

        self.screen_monitor_thread[current_screen_symbol] = nil

        #Close the window if needed
        if skip_close == false
          self.switch_to_window(window_handle)
          self.driver_object.close
        end

        break
      }

      if remove_current_handle
        self.current_screen_hash.delete(remove_current_handle)
        self.screen_history_hash.delete(remove_current_handle)
      end

      self.current_screen_hash.each { |window_handle, current_screen_symbol|
        self.switch_to_window(window_handle)
        self.current_screen_class = current_screen_symbol
        break
      }

      self.send(screen_class_symbol).reset_screen
    end
  end
end