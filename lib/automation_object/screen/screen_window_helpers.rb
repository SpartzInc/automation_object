module AutomationObject
  module ScreenWindowHelpers
    #in_iframe String, element_name that is the iframe
    attr_accessor :in_iframe

    def navigate_back
      unless self.framework_object.screen_history_hash[self.window_handle].class == Array
        raise ArgumentError, "Screen history hash doesn't contain window handle (#{self.window_handle}) for screen: #{self.screen_name}"
      end

      history_array = self.framework_object.screen_history_hash[self.window_handle]
      unless history_array.length > 1
        raise ArgumentError, 'Cannot navigate back in the current window, nothing to go back to'
      end

      #Remove last screen, which should be this one
      history_array.pop
      previous_screen_class = history_array.pop

      self.driver_object.navigate.back

      self.emit :change_screen, {
          :screen_class_symbol => previous_screen_class
      }
    end

    def close_window(skip_close = false)
      self.emit :close_window, {
          :screen_name => self.screen_name,
          :skip_close => skip_close
      }
    end

    def get_window_size
      return self.driver_object.window_size if self.driver_object.respond_to?(:window_size)
      return self.driver_object.manage.window.size
    end

    def set_window_size(x, y)
      self.driver_object.manage.window.resize_to(x, y)
    end

    def set_window_location(x, y)
      self.driver_object.manage.window.move_to(x, y)
    end

    def maximize_window
      self.driver_object.manage.window.maximize
    end

    def current_url
      return self.driver_object.current_url
    end

    def hide_keyboard(close_key = nil)
      unless self.framework_object.is_mobile?
        raise 'This is not implemented for Browsers'
      end

      self.driver_object.hide_keyboard(close_key)
    end

    def screenshot(path)
      unless path.match(/\.png$/)
        raise ArgumentError, 'Screenshot path must contain .png file extension'
      end

      return self.driver_object.screenshot(path)
    end

    def window_in_iframe?
      return (self.in_iframe) ? true : false
    end

    def element_in_current_iframe?(element_name)
      configuration = self.send(self.translate_string_to_class(element_name)).configuration

      return false unless configuration.is_a?(Hash)
      return false unless configuration.has_key?('in_iframe')

      return (configuration['in_iframe'] == self.in_iframe)
    end

    def switch_to_default_content
      return unless self.window_in_iframe?

      AutomationObject::Logger::add('Switching from iframe to default content', {:screen_name => self.screen_name})

      self.driver_object.switch_to.default_content
      self.in_iframe = nil
    end

    def switch_to_iframe(element_name)
      configuration = self.send(self.translate_string_to_class(element_name)).configuration
      iframe_element_name = configuration['in_iframe']

      unless iframe_element_name.class == String
        raise ArgumentError, "Expected String for in_iframe property of element (#{element_name}), screen (#{self.screen_name})"
      end

      iframe_element_object = self.get_element_object(iframe_element_name)
      iframe_element_object.scroll_to_view

      AutomationObject::Logger::add('Switching from default content to iframe', [self.framework_location])
      iframe_element_object.switch_to_iframe
      self.in_iframe = iframe_element_name
    end

    def scroll_up
      AutomationObject::Logger::add('Scrolling up', [self.framework_location])

      self.do_hook_action('scroll_up', 'before')
      driver_return = self.driver_object.execute_script('mobile: swipe', startX: 0.5, startY: 0.2, endX: 0.5, endY: 0.8, duration: 0.1)
      self.do_hook_action('scroll_up', 'after')

      return driver_return
    end

    def scroll_down
      AutomationObject::Logger::add('Scrolling down', [self.framework_location])

      self.do_hook_action('scroll_down', 'before')
      driver_return = self.driver_object.execute_script('mobile: swipe', startX: 0.5, startY: 0.8, endX: 0.5, endY: 0.2, duration: 0.1)
      self.do_hook_action('scroll_down', 'after')

      return driver_return
    end

    def scroll_left
      AutomationObject::Logger::add('Scrolling left', [self.framework_location])

      self.do_hook_action('scroll_left', 'before')
      driver_return = self.driver_object.execute_script('mobile: swipe', startX: 0.8, startY: 0.5, endX: 0.2, endY: 0.5, duration: 0.1)
      self.do_hook_action('scroll_left', 'after')

      return driver_return
    end

    def scroll_right
      AutomationObject::Logger::add('Scrolling right', [self.framework_location])

      self.do_hook_action('scroll_right', 'before')
      driver_return = self.driver_object.execute_script('mobile: swipe', startX: 0.2, startY: 0.5, endX: 0.8, endY: 0.5, duration: 0.1)
      self.do_hook_action('scroll_right', 'after')

      return driver_return
    end
  end
end