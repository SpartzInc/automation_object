module AutomationObject
  class ElementArray < Array
    include AutomationObject::ElementsHelpers

    def load_elements
      modified_elements_array = self.load_elements_global
      modified_elements_array.each { |modified_element|
        self.push(modified_element)
      }
    end
  end
end