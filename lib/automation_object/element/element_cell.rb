module AutomationObject
  class ElementCell
    include EventEmitter

    attr_accessor :framework_object, :screen_object, :driver_object, :configuration, :screen_name, :element_name,
                  :sub_elements, :element_object

    def initialize(params)
      #Set params to properties
      self.framework_object = params[:framework_object] || raise(ArgumentError, 'framework_object is required in params')
      self.screen_object = params[:screen_object] || raise(ArgumentError, 'screen_object is required in params')
      self.driver_object = params[:driver_object] || raise(ArgumentError, 'driver_object is required in params')
      #Clone configuration, this will allow edit/deletes on different levels
      self.configuration = params[:blue_prints].clone || raise(ArgumentError, 'configuration is required in params')

      self.screen_name = params[:screen_name] || raise(ArgumentError, 'screen_name is required in params')
      self.element_name = params[:element_name] || raise(ArgumentError, 'element_name is required in params')

      #Validate properties
      raise ArgumentError, 'framework_object should be an Framework Object' unless self.framework_object.is_a? Framework
      raise ArgumentError, 'screen_object should be an Screen Object' unless self.screen_object.is_a? Screen
      raise ArgumentError, 'configuration should be a Hash Object' unless self.configuration.is_a? Hash
      raise ArgumentError, 'screen_name should be a String Object' unless self.screen_name.is_a? String
      raise ArgumentError, 'element_name should be a String Object' unless self.element_name.is_a? String

      self.sub_elements = Array.new

      #Add Sub-Elements
      return unless self.configuration['sub_elements'].is_a?(Hash)

      self.configuration['sub_elements'].each { |sub_element_name, sub_element_configuration|
        next unless sub_element_configuration.is_a?(Hash)
        modified_element_configuration = self.combine_selector_path(self.configuration, sub_element_configuration)

        element_class_name = self.translate_string_to_class(sub_element_name)
        setter = "#{element_class_name}="
        self.class.send(:attr_accessor, element_class_name) unless self.respond_to?(setter)

        sub_element_object_options = {
            :framework_object => self.framework_object,
            :screen_object => self.screen_object,
            :driver_object => self.driver_object,
            :blue_prints => modified_element_configuration,
            :screen_name => self.screen_name,
            :element_name => element_name
        }

        send setter, AutomationObject::Element.new(sub_element_object_options)

        this = self
        self.send(element_class_name).on :hook do |args|
          this.emit :hook, args
        end

        self.sub_elements.push(sub_element_name)
      }

      #Add Element Object
      sub_element_object_options = {
          :framework_object => self.framework_object,
          :screen_object => self.screen_object,
          :driver_object => self.driver_object,
          :blue_prints => self.configuration,
          :screen_name => self.screen_name,
          :element_name => self.element_name,
          :element_object => params[:element_object]
      }

      self.element_object = AutomationObject::Element.new(sub_element_object_options)
      this = self
      self.element_object.on :hook do |args|
        this.emit :hook, args
      end
    end

    def combine_selector_path(cell_configuration, sub_element_configuration)
      modified_configuration = sub_element_configuration.clone
      if cell_configuration['xpath']
        sub_element_configuration.has_key?('xpath').should == true
        modified_configuration['xpath'] = cell_configuration['xpath'] + sub_element_configuration['xpath']
      elsif cell_configuration['css']
        sub_element_configuration.has_key?('css').should == true
        modified_configuration['css'] = cell_configuration['css'] + ' ' + sub_element_configuration['css']
      else
        raise 'Expecting either css or xpath for selector in element cell configuration'
      end

      return modified_configuration
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
      return true if super.respond_to?(method_symbol, include_private)

      #If not try element object
      return self.element_object.respond_to?(method_symbol, include_private)
    end

    def element_respond_to?(method_symbol, include_private = false)
      return self.element_object.respond_to?(method_symbol, include_private)
    end

    def method_missing(method_requested, *args, &block)
      class_symbol = self.translate_string_to_class(method_requested)

      if self.element_respond_to?(method_requested)
        return self.element_object.send(method_requested, *args, &block)
      end

      if self.respond_to?(class_symbol)
        return self.send(class_symbol, *args, &block)
      end

      raise "Element (#{method_requested}) is not defined in ElementCell object"
    end
  end
end