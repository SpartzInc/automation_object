module AutomationObject
  module ElementsHelpers
    include EventEmitter
    include AutomationObject::ElementHelpers

    attr_accessor :framework_object, :screen_object, :driver_object,
                  :configuration,
                  :screen_name, :element_name,
                  :elements_loaded #Boolean

    #Same initialize in both Array and Hash Classes
    def initialize(params)
      self.elements_loaded = false #Set to false as default

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
    end

    def get_elements
      #Deal with iFrames
      if self.framework_object.is_browser?
        if self.in_iframe?
          self.screen_object.switch_to_iframe(self.element_name)
        end
      end

      selector_params = self.get_selector_params(self.configuration)

      if self.configuration['multiple_ios_fix'] and self.framework_object.is_mobile?
        unless self.driver_object.device_is_android?
          return self.get_elements_temp_ios_fix
        end
      end

      elements_array = self.driver_object.find_elements(selector_params[:selector_method], selector_params[:selector])

      return elements_array unless elements_array.is_a?(Array)
      return elements_array if elements_array.length == 0

      if self.configuration['remove_duplicates']
        elements_array = self.remove_duplicates(elements_array, self.configuration['remove_duplicates'])
      end

      return elements_array if elements_array.length == 0

      if self.configuration['custom_range']
        elements_array = self.get_custom_range_elements(elements_array, self.configuration['custom_range'])
      end

      return elements_array
    end

    #Dump array into Hash so that we can skip already existing keys that return Hash values Array
    def remove_duplicates(elements_array, element_method)
      element_method = element_method.to_sym
      elements_hash = Hash.new

      elements_array.each { |element|
        unless element.respond_to?(element_method)
          raise "Expecting element to respond to method #{element_method} defined in remove_duplicates for #{self.screen_name}->#{self.element_name}"
        end

        element_value = element.send(element_method)

        next if elements_hash.has_key?(element_value)
        elements_hash[element.send(element_method)] = element
      }

      #Return the values array
      return elements_hash.values
    end

    def get_custom_range_elements(elements_array, range_hash)
      unless range_hash.is_a?(Hash)
        raise "Expecting custom_range to be a Hash, got #{range_hash.class}. Defined in #{self.screen_name}->#{self.element_name}"
      end

      start_index = 0
      if range_hash['start'].is_a?(Numeric)
        start_index = range_hash['start'].to_i
      end

      end_index = 0
      if range_hash['end'].is_a?(Numeric)
        end_index = range_hash['end'].to_i
      end

      new_elements_array = Array.new
      elements_array.each_with_index { |element, index|
        element_index = index + 1 #Since elements start at 1
        next if element_index < start_index

        if end_index != 0
          break if element_index > end_index
        end

        new_elements_array.push(element)
      }

      return new_elements_array
    end

    #Todo: remove when Appium is fixed for iOS Apps
    #Multiple elements in iOS App is killing the whole thing
    #Get around the problem by appending [index] to each using find_element til failure
    def get_elements_temp_ios_fix
      selector_params = self.get_selector_params(self.configuration)
      #Get rid of any shit at the end, //blah/element[1] becomes //blah/element only for numeric indexes, going to add a numeric index

      elements_array = Array.new

      index = 1
      find_element_failure = false
      until find_element_failure
        selector_params[:selector] = selector_params[:selector].gsub(/\[\d+\]$/, '')
        selector_params[:selector] = selector_params[:selector] + "[#{index}]"

        begin
          if self.driver_object.exists?(selector_params[:selector_method], selector_params[:selector])
            elements_array.push(self.driver_object.find_element(selector_params[:selector_method], selector_params[:selector]))
          else
            find_element_failure = true
            break
          end
        rescue
          find_element_failure = true
          break
        end

        index += 1
      end

      return elements_array
    end

    #Cannot override module method, call this in Hash/Array and do specifics in
    # load_elements of those classes
    def load_elements_global
      elements_array = self.get_elements

      modified_elements_array = Array.new
      elements_array.each_with_index do |element_object, index|
        #Get params for individual element, given the index
        element_configuration = self.get_individual_configuration(index, self.configuration)

        element_object_options = {
            :framework_object => self.framework_object,
            :screen_object => self.screen_object,
            :driver_object => self.driver_object,
            :blue_prints => element_configuration,
            :screen_name => self.screen_name,
            :element_name => (self.element_name + "(#{index})"),
            :element_object => element_object
        }

        new_element = AutomationObject::Element.new(element_object_options)

        this = self
        new_element.on :hook do |args|
          this.emit :hook, args
        end

        modified_elements_array.push(new_element)
      end

      self.elements_loaded = true
      return modified_elements_array
    end

    def get_individual_configuration(index, configuration)
      element_configuration = configuration.clone
      element_index = index + 1 #Elements start at one instead of zero, so add one

      if element_configuration['xpath']
        element_configuration['xpath'] = '(' + element_configuration['xpath'].to_s + ')' + "[position() = #{element_index}]"
      elsif element_configuration['css']
        element_configuration['css'] = element_configuration['css'].to_s + ":nth-of-type(#{element_index})"
      else
        raise(ArgumentError, 'xPath and CSS are the only element selectors available')
      end

      return element_configuration
    end

    def reset_elements
      self.clear #Same method for both Hashes and Arrays
      self.elements_loaded = false
    end
  end
end