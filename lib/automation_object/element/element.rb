module AutomationObject
  class Element
    include EventEmitter
    include AutomationObject::ElementHelpers

    WINDOW_CHECK_ON_METHOD = [:click, :drag_to_element]
    SCROLL_TO_VIEW_ON_METHOD = [:click, :drag_to_element, :send_keys]

    attr_accessor :framework_object, :driver_object,
                  :framework_location,
                  :screen_object, :element_object,
                  :screen_name, :element_name,
                  :element_methods_object

    attr_accessor :configuration

    def initialize(params)
      #Set params to properties
      self.framework_object = params[:framework_object] || raise(ArgumentError, 'framework_object is required in params')

      self.screen_object = params[:screen_object] || raise(ArgumentError, 'screen_object is required in params')
      self.driver_object = params[:driver_object] || raise(ArgumentError, 'driver_object is required in params')
      #Clone configuration, this will allow edit/deletes on different levels
      self.configuration = params[:blue_prints].clone || raise(ArgumentError, 'configuration is required in params')

      self.screen_name = params[:screen_name] || raise(ArgumentError, 'screen_name is required in params')
      self.element_name = params[:element_name] || raise(ArgumentError, 'elements_name is required in params')

      #Set element object if requested
      self.element_object = params[:element_object] if params[:element_object]

      #Validate properties
      raise ArgumentError, 'framework_object should be an Automation Object' unless self.framework_object.is_a? Framework
      raise ArgumentError, 'screen_object should be an Screen Object' unless self.screen_object.is_a? Screen
      raise ArgumentError, 'configuration should be a Hash Object' unless self.configuration.is_a? Hash
      raise ArgumentError, 'screen_name should be a String Object' unless self.screen_name.is_a? String
      raise ArgumentError, 'elements_name should be a String Object' unless self.element_name.is_a? String

      #This can stay alive, will reset object internally when issued to this class
      #ElementMethod Object will have the available methods for elements, while
      #allowing for thread locking on this level
      #Pass self into it, so it can hit above levels without much issue
      self.element_methods_object = ElementMethods.new(self)

      self.framework_location = self.screen_object.framework_location + ".#{self.element_name}"
    end

    def respond_to?(method_symbol, include_private = false)
      #If this Element class has the method then return true
      if super.respond_to?(method_symbol, include_private)
        return true
      end

      #Check ElementMethods respond_to?, need to wrap in driver mutex object
      return self.element_methods_object.respond_to?(method_symbol, include_private)
    end

    #Avoid deadlocking on resets
    def reset_element
      self.element_methods_object.reset_element
    end

    def check_new_window?(method_symbol)
      return false unless self.framework_object.is_browser?
      WINDOW_CHECK_ON_METHOD.include?(method_symbol)
    end

    def scroll_to_view?(method_symbol)
      return false unless self.framework_object.is_browser?
      SCROLL_TO_VIEW_ON_METHOD.include?(method_symbol)
    end

    def method_missing(method_symbol, *arguments, &block)
      method_string = method_symbol.to_s
      created_window_handle = false
      em_object_return = nil

      AutomationObject::Logger::add("Calling method #{method_symbol} on element", [self.framework_location])

      #Run any before hooks
      self.hook(method_string, 'before')

      #Deal with iFrames
      if self.framework_object.is_browser?
        if self.in_iframe?
          self.screen_object.switch_to_iframe(self.element_name)
        end
      end

      #Check for difference in window handles if needed
      if self.check_new_window?(method_symbol)
        before_window_handles = self.framework_object.get_window_handles
      end

      #Use automation object level mutex object which will lock any element operations will complete
      begin
        AutomationObject::Logger::add("Executing method #{method_symbol} on element", [self.framework_location])
        em_object_return = self.element_methods_object.send(method_symbol, *arguments, &block)
      rescue Selenium::WebDriver::Error::ElementNotVisibleError, Selenium::WebDriver::Error::UnknownError => e
        raise e
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        sleep(2)
        AutomationObject::Logger::add("Stale element error, retrying method #{method_symbol} on element", [self.framework_location])
        self.element_methods_object.find_element
        em_object_return = self.element_methods_object.send(method_symbol, *arguments, &block)
      rescue Selenium::WebDriver::Error::InvalidElementStateError
        sleep(2)
        AutomationObject::Logger::add("Invalid element state error, retrying method #{method_symbol} on element", [self.framework_location])
        self.element_methods_object.find_element
        em_object_return = self.element_methods_object.send(method_symbol, *arguments, &block)
      end

      if self.check_new_window?(method_symbol)
        after_window_handles = self.framework_object.get_window_handles
        window_handle_difference = after_window_handles - before_window_handles
        if window_handle_difference.length > 1
          raise "Click on element (#{self.element_name}) in screen (#{self.screen_name}) has opened more than one window."
        end
        created_window_handle = window_handle_difference.shift
      end

      self.hook(method_string, 'after', created_window_handle)
      return em_object_return
    end

    def hook(action, timing, created_window_handle = false)
      self.before_mutex_lock if action == 'before'

      #Return out if it doesn't meet the given requirements
      return unless self.configuration.class == Hash
      return unless self.configuration[action].class == Hash
      return unless self.configuration[action][timing].class == Hash

      hook_configuration = self.configuration[action][timing].clone
      self.emit :hook, {
          :configuration => hook_configuration,
          :created_window_handle => created_window_handle
      }

      self.after_mutex_lock if action == 'after'
    end
  end
end