module AutomationObject
  module FrameworkScreenMonitor
    def screen_monitor_thread_method(screen_class_symbol)
      Thread.abort_on_exception = true

      auto_screens_array = self.send(screen_class_symbol).configuration['automatic_screen_changes']
      unless auto_screens_array.is_a?(Array)
        raise "Expecting #{screen_class_symbol} screen to have automatic_screen_changes as an Array"
      end

      if auto_screens_array.length == 0
        raise "Expecting #{screen_class_symbol} screen to have automatic_screen_changes count larger than 0"
      end

      if self.previous_screen_class
        if self.screen_monitor_thread[self.previous_screen_class].class == Thread
          AutomationObject::Logger::add("Attempting to kill previous screen threads for screen #{self.previous_screen_class}")

          previous_thread = self.screen_monitor_thread[self.previous_screen_class]
          Thread.kill(previous_thread)
          self.screen_monitor_thread[self.previous_screen_class] = nil
        end
      end

      AutomationObject::Logger::add("Running thread listener for screen #{screen_class_symbol}")

      possible_screen_change_symbol = nil
      possible_screen_change_name = nil

      screen_live = false

      #Todo: window switching while checking for live?
      until screen_live
        self.screen_monitor_mutex_object.synchronize do
          auto_screens_array.each { |possible_screen_change_name|
            possible_screen_change_symbol = self.translate_string_to_class(possible_screen_change_name)

            start_time = Time.now.to_f
            screen_live = self.send(possible_screen_change_symbol).live?
            end_time = Time.now.to_f

            AutomationObject::Logger::add("Automatic screen check of #{possible_screen_change_name} took (#{end_time-start_time})S")

            break if screen_live
          }
        end
      end

      if screen_live
        AutomationObject::Logger::add("Automatic screen change to #{possible_screen_change_name} found")
        self.set_current_screen(possible_screen_change_symbol)
      end
    end
  end
end