module AutomationObject
  class Screen
    include EventEmitter

    include AutomationObject::ScreenWindowHelpers
    include AutomationObject::ScreenHookHelpers
    include AutomationObject::ScreenPromptHelpers
    include AutomationObject::ScreenModalHelpers

    attr_accessor :framework_object, :driver_object,
                  :configuration,
                  :framework_location,
                  :screen_name,
                  :active_modal,
                  :added_elements,
                  :element_storage,
                  :window_handle

    def initialize(params)
      self.added_elements = Array.new
      self.element_storage = Hash.new
      self.window_handle = nil

      #Set params to properties
      self.framework_object = params[:framework_object] || raise(ArgumentError, 'framework_object is required in params')
      self.driver_object = params[:driver_object] || raise(ArgumentError, 'driver_object is required in params')
      #Clone configuration, this will allow edit/deletes on different levels
      params[:blue_prints] = Hash.new unless params[:blue_prints].class == Hash #Allow empty screen configs
      self.configuration = params[:blue_prints].clone || raise(ArgumentError, 'configuration is required in params')

      self.screen_name = params[:screen_name] || raise(ArgumentError, 'screen_name is required in params')

      #Validate properties
      raise ArgumentError, 'framework_object should be an Framework Object' unless self.framework_object.is_a? Framework
      raise ArgumentError, 'configuration should be a Hash Object' unless self.configuration.is_a? Hash
      raise ArgumentError, 'screen_name should be a String Object' unless self.screen_name.is_a? String

      #Framework Location for Debugging
      self.framework_location = self.screen_name

      #Add Modals
      self.add_modals(params, self.configuration['modals']) if self.configuration['modals'].is_a?(Hash)

      #Add ElementGroups
      self.add_element_groups(self.configuration['element_groups']) if self.configuration['element_groups'].is_a?(Hash)

      #Add Elements
      self.add_elements(self.configuration['elements']) if self.configuration['elements'].is_a?(Hash)
    end

    def respond_to?(method_symbol, include_private = false)
      #Translate method in possible internal storage attribute
      class_symbol = self.translate_string_to_class(method_symbol)
      instance_symbol = class_symbol.to_s.gsub(/^@/, '')
      instance_symbol = "@#{instance_symbol}".to_sym

      self.instance_variables.each { |instance_variable|
        return true if instance_variable == instance_symbol
      }

      #If not then do the super on the method_symbol
      super.respond_to?(method_symbol, include_private)
    end

    def respond_to_element?(method_symbol, include_private = false)
      element_symbol = self.translate_string_to_class(method_symbol)
      instance_symbol = element_symbol.to_s.gsub(/^@/, '')
      instance_symbol = "@#{instance_symbol}".to_sym

      self.instance_variables.each { |instance_variable|
        if instance_variable == instance_symbol
          method_class = self.send(element_symbol).class
          return (method_class == Element || method_class == ElementHash || method_class == ElementArray)
        end
      }

      false
    end

    def method_missing(method_requested, *args, &block)
      class_symbol = self.translate_string_to_class(method_requested)

      unless self.respond_to?(class_symbol)
        raise "Element or Modal (#{method_requested}) is not defined in screen object (#{self.screen_name})"
      end

      if self.window_in_iframe? and self.respond_to_element?(method_requested)
        unless self.element_in_current_iframe?(method_requested)
          self.switch_to_default_content
        end
      else
        self.switch_to_default_content
      end

      #Preload elements for ElementHash/ElementArray
      if self.send(class_symbol).class == ElementHash or self.send(class_symbol).class == ElementArray or self.send(class_symbol).class == ElementGroup
        self.send(class_symbol).load_elements unless self.send(class_symbol).elements_loaded
      end

      #Load modal if needed
      if self.send(class_symbol).class == Modal
        #Skip opening the modal again if it's active
        return self.send(class_symbol, *args, &block) if self.active_modal == class_symbol

        #Try to make the modal active
        self.route_to_modal(method_requested)
      end

      self.send(class_symbol, *args, &block)
    end

    def add_element_groups(configuration)
      return unless configuration.is_a?(Hash)

      configuration.each { |group_name, group_configuration|
        group_class_name = self.translate_string_to_class(group_name)

        setter = "#{group_class_name}="
        self.class.send(:attr_accessor, group_class_name) unless self.respond_to?(setter)

        group_object_options = {
            :framework_object => self.framework_object,
            :screen_object => self,
            :driver_object => self.driver_object,
            :blue_prints => group_configuration,
            :screen_name => self.screen_name,
            :element_name => group_name
        }

        send setter, AutomationObject::ElementGroup.new(group_object_options)

        this = self
        self.send(group_class_name).on :hook do |args|
          this.hook_listener(args)
        end
      }
    end

    def add_elements(configuration)
      return unless configuration.is_a?(Hash)

      configuration.each { |element_name, element_configuration|
        element_class_name = self.translate_string_to_class(element_name)

        setter = "#{element_class_name}="
        self.class.send(:attr_accessor, element_class_name) unless self.respond_to?(setter)

        element_object_options = {
            :framework_object => self.framework_object,
            :screen_object => self,
            :driver_object => self.driver_object,
            :blue_prints => element_configuration,
            :screen_name => self.screen_name,
            :element_name => element_name
        }

        if element_configuration['multiple'] #Use element hash class for multiples
          if element_configuration['define_elements_by']
            send setter, AutomationObject::ElementHash.new(element_object_options)
          else
            send setter, AutomationObject::ElementArray.new(element_object_options)
          end
        else
          send setter, AutomationObject::Element.new(element_object_options)
        end

        this = self
        self.send(element_class_name).on :hook do |args|
          this.hook_listener(args)
        end

        self.added_elements.push(element_class_name)
      }
    end

    def reset_screen(skip_window_handle = false)
      AutomationObject::Logger::add('Resetting screen', [self.framework_location])

      self.switch_to_default_content

      #Reset elements
      self.added_elements.each { |added_element|
        class_name = self.send(added_element).class.name
        case class_name
          when 'AutomationObject::ElementArray', 'AutomationObject::ElementHash', 'AutomationObject::ElementGroup'
            self.send(added_element).reset_elements
          when 'AutomationObject::Element'
            self.send(added_element).reset_element
        end
      }

      #Set active modal to nil
      self.active_modal = nil
      self.window_handle = nil unless skip_window_handle
    end
  end
end