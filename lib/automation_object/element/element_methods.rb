#Provides wrapper for mutex safe executions on a single driver
#Without results in pain in the ass errors involving IO interruptions with driver
module AutomationObject
  class ElementMethods
    include AutomationObject::ElementHelpers

    attr_accessor :parent_element_object, :driver_object,
                  :framework_object,
                  :element_object, :configuration,
                  :screen_name, :element_name

    def initialize(parent_element_object)
      self.parent_element_object = parent_element_object
      self.framework_object = self.parent_element_object.framework_object

      self.screen_name = self.parent_element_object.screen_name
      self.element_name = self.parent_element_object.element_name

      self.driver_object = self.parent_element_object.driver_object
      self.element_object = parent_element_object.element_object if parent_element_object.element_object
      self.configuration = self.parent_element_object.configuration
    end

    def respond_to?(method_symbol, include_private = false)
      #If this ElementMethods class has the method then return true
      if super
        return true
      end

      #Check custom_methods configuration, return true if it does have the key
      if self.configuration['custom_methods'].class == Hash
        if self.configuration['custom_methods'].has_key?(method_symbol.to_s)
          return true
        end
      end

      #Now we need to check the element
      element_object = self.get_element
      element_object.respond_to?(method_symbol, include_private)
    end

    def method_missing(method_symbol, *arguments, &block)
      unless element_object.respond_to?(method_symbol)
        configuration = self.configuration
        if configuration['custom_methods'].class == Hash
          if configuration['custom_methods'].has_key?(method_symbol.to_s)
            method_eval_configuration = configuration['custom_methods'][method_symbol.to_s]
            return self.custom_evaluation(method_symbol.to_s, method_eval_configuration)
          end
        end
      end

      element_object = self.get_element
      element_object.send(method_symbol, *arguments, &block)
    end

    def get_element
      #Return element_object if already set
      return self.element_object if self.element_object
      #Get Element
      self.find_element
      self.element_object
    end

    def find_element
      #Find element if not already set and set it to self
      selector_params = self.get_selector_params(self.configuration)
      #ap selector_params
      self.element_object = self.driver_object.find_element(selector_params[:selector_method], selector_params[:selector])
    end

    def reset_element
      if self.element_object
        AutomationObject::Logger::add('Resetting element', [self.parent_element_object.framework_location])
      end
      self.element_object = nil
    end

    def exists?
      if self.element_object
        begin #Just do a quick check to make sure no errors will be raised
          self.displayed?
          return true
        rescue #Todo: add specific rescues
          return false
        end
      end

      selector_params = self.get_selector_params(self.configuration)
      return self.driver_object.exists?(selector_params[:selector_method], selector_params[:selector])
    end

    def custom_evaluation(custom_method_name, method_eval_configuration)
      return nil if method_eval_configuration.class != Hash

      unless method_eval_configuration['element_method']
        raise ArgumentError, "element_method key is needed for the custom method #{custom_method_name}"
      end

      unless method_eval_configuration['evaluate']
        raise ArgumentError, "evaluate key is needed for the custom method #{custom_method_name}"
      end

      element_method = method_eval_configuration['element_method'].to_sym

      element_object = self.get_element
      if self.respond_to?(element_method)
        evaluation_value = self.send(element_method)
      else
        evaluation_value = element_object.send(element_method)
      end

      evaluation_script = "evaluation_value.#{method_eval_configuration['evaluate']}"

      AutomationObject::Logger::add("Running custom evaluation method #{custom_method_name}", [self.parent_element_object.framework_location])

      return eval(evaluation_script)
    end

    #Check to see if this gets fixed in the future otherwise leave it
    def click
      self.scroll_into_view

      #Is a browser and mobile?
      if self.framework_object.is_mobile? and self.framework_object.is_browser?
        unless self.driver_object.device_is_android?
          if self.configuration.class == Hash
            if self.configuration['click'].class == Hash
              if self.configuration['click']['after'].class == Hash
                if self.configuration['click']['after']['wait_for_new_window'] == true
                  return self.ios_web_temp_click
                end
              end
            end
          end
        end
      end

      element_object = self.get_element
      return element_object.click
    end

    #Todo: temp fix for Appium iOS Mobile Safari (Web), doesn't click on buttons that open new windows
    def ios_web_temp_click
      self.get_element

      #Switch to Native Context to get actual window size
      current_web_context = self.driver_object.current_context
      self.driver_object.set_context('NATIVE_APP')

      #Get the top nav bar height
      navigation_bar_element = self.driver_object.find_element(:xpath, '//UIAApplication[1]/UIAWindow[2]/UIAButton[1]')
      navigation_bar_size = navigation_bar_element.size

      self.driver_object.set_context(current_web_context)

      element_location = self.element_object.location
      element_size = self.element_object.size

      tap_location = Hash.new
      tap_location[:x] = element_location[:x].to_f + (element_size[:width].to_f / 2.0)
      tap_location[:y] = navigation_bar_size[:height].to_f + element_location[:y].to_f + (element_size[:height].to_f / 2.0)

      execution_return = self.driver_object.execute_script('mobile: tap', tap_location)
      return execution_return
    end

    #Rescue possible input issue, clear and retry; mostly an Appium issue
    def send_keys(text_input)
      element_object = self.get_element
      begin
        element_object.send_keys(text_input)
      rescue Selenium::WebDriver::Error::JavascriptError
        sleep(2)
        element_object.clear
        sleep(2)
        element_object.send_keys(text_input)
      end
    end

    def attribute(key, value = false)
      element_object = self.get_element
      return element_object.attribute(key) unless value

      script = "return arguments[0].#{key} = '#{value}'"
      self.driver_object.execute_script(script, element_object)
    end

    def hover
      element_object = self.get_element

      self.scroll_to_view
      self.driver_object.action.move_to(element_object).perform
    end

    def visible?
      element_object = self.get_element
      element_object.displayed?
    end

    def invisible?
      element_object = self.get_element
      element_object.displayed? ? false : true
    end

    def id
      element_object = self.get_element
      element_object.attribute('id').to_s
    end

    def href
      element_object = self.get_element
      element_object.attribute('href').to_s
    end

    def scroll_into_view
      return self.scroll_to_view
    end

    def scroll_to_view
      element_object = self.get_element
      element_object.location_once_scrolled_into_view

      if self.framework_object.is_mobile?
        return unless self.framework_object.is_browser?

        element_center = self.get_element_center
        window_height = self.driver_object.execute_script('return window.innerHeight;').to_f
        current_y_position = self.driver_object.execute_script('var doc = document.documentElement; return (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);').to_f

        if element_center[:y] < (window_height/2)
          ideal_y_position = (current_y_position + element_center[:y] - (window_height.to_f / 2.0)).abs
        else
          ideal_y_position = (current_y_position - element_center[:y] + (window_height.to_f / 2.0)).abs
        end

        self.driver_object.execute_script("window.scroll(#{element_center[:x].to_f},#{ideal_y_position});")
        #Just in case in close to the top or bottom bounds of the window
        element_location = element_object.location_once_scrolled_into_view

        if element_location[:y] < 0
          current_y_position = self.driver_object.execute_script('var doc = document.documentElement; return (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);').to_f
          scroll_y_position = current_y_position + element_location[:y]
          self.driver_object.execute_script("window.scroll(#{element_location[:x].to_f},#{scroll_y_position});")
        end
      else
        element_location = element_object.location
        window_height = self.driver_object.execute_script('return window.innerHeight;').to_f

        #Don't scroll down
        window_scroll_x = element_location.x.to_f
        window_scroll_y = element_location.y.to_f - window_height/2

        return if window_scroll_y <= 0
        window_scroll_x = 0 if window_scroll_x < 0

        javascript_string = "return window.scroll(#{window_scroll_x}, #{window_scroll_y});"

        self.driver_object.execute_script(javascript_string)
      end
    end

    def x
      element_object = self.get_element
      element_object.location.x
    end

    def y
      element_object = self.get_element
      element_object.location.y
    end

    def width
      element_object = self.get_element
      element_object.size.width
    end

    def height
      element_object = self.get_element
      element_object.size.height
    end

    def drag_to_element(secondary_element)
      if self.parent_element_object.driver_object.device_is_android?
        raise 'This has not been implemented for Android services yet'
      end

      #Do this internally to avoid thread locking
      secondary_element_configuration = self.parent_element_object.screen_object.send(secondary_element).configuration
      secondary_element_params = self.get_selector_params(secondary_element_configuration)

      unless self.parent_element_object.framework_object.is_mobile?
        secondary_element = self.driver_object.find_element(secondary_element_params[:selector_method], secondary_element_params[:selector])
        return self.driver_object.drag_and_drop(self.get_element, secondary_element)
      end

      primary_center = self.get_element_center
      secondary_center = self.get_element_center(secondary_element_params)

      location_string = "{x:#{primary_center[:x]}, y:#{primary_center[:y]}}, {x:#{secondary_center[:x]}, y:#{secondary_center[:y]}}"
      ios_command = "UIATarget.localTarget().dragFromToForDuration(#{location_string}, 0.7);"

      AutomationObject::Logger::add("Running drag command on element to element #{secondary_element}", [self.parent_element_object.framework_location])

      self.driver_object.execute_script(ios_command)
    end

    def get_element_center(element_params = nil)
      if element_params
        element_object = self.driver_object.find_element(element_params[:selector_method], element_params[:selector])
        element_location = element_object.location
        element_size = element_object.size
      else
        element_location = self.location
        element_size = self.size
      end

      center = {
          :x => 0,
          :y => 0
      }

      center[:x] = (element_location.x + element_size.width/2).to_i
      center[:y] = (element_location.y + element_size.height/2).to_i

      return center
    end
  end
end