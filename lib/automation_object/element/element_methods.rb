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
      return true if super

      #Check custom_methods configuration, return true if it does have the key
      if self.configuration['custom_methods'].class == Hash
        if self.configuration['custom_methods'].has_key?(method_symbol.to_s)
          return true
        end
      end

      #Now we need to check the element
      element_object = self.get_element
      return element_object.respond_to?(method_symbol, include_private)
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
        rescue Exception
          self.reset_element
        end
      end

      selector_params = self.get_selector_params(self.configuration)
      element_exists = self.driver_object.exists?(selector_params[:selector_method], selector_params[:selector])

      self.reset_element unless element_exists
      return element_exists
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

    def drag_to_element(secondary_element)
      if self.parent_element_object.driver_object.device_is_android?
        raise 'This has not been implemented for Android services yet'
      end

      #Do this internally to avoid thread locking
      secondary_element = self.parent_element_object.screen_object.send(secondary_element)

      unless self.parent_element_object.framework_object.is_mobile?
        return self.driver_object.drag_and_drop(self.get_element, secondary_element.get_element)
      end

      primary_center = self.get_element_center
      secondary_center = secondary_element.get_element_center

      location_string = "{x:#{primary_center[:x]}, y:#{primary_center[:y]}}, {x:#{secondary_center[:x]}, y:#{secondary_center[:y]}}"
      ios_command = "UIATarget.localTarget().dragFromToForDuration(#{location_string}, 0.7);"

      AutomationObject::Logger::add("Running drag command on element to element #{secondary_element}", [self.parent_element_object.framework_location])

      self.driver_object.execute_script(ios_command)
    end
  end
end