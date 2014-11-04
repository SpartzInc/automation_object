module AutomationObject
  class ElementHash < Hash
    include AutomationObject::ElementsHelpers

    def load_elements
      modified_elements_array = self.load_elements_global

      modified_elements_array.each { |modified_element|
        element_key = self.get_element_key(modified_element)
        #Change element name so that it includes the hash index instead of the array index
        modified_element.element_name = (self.element_name + "(#{element_key})")
        self[element_key] = modified_element
      }
    end

    def get_element_key(element_object)
      element_method = self.configuration['define_elements_by'].to_sym
      unless element_object.respond_to?(element_method)
        raise ArgumentError, "Element object does not have method (#{element_method}), for ElementHash (#{self.element_name}) in Screen (#{self.screen_name})"
      end

      element_object.send(self.configuration['define_elements_by'])
    end
  end
end