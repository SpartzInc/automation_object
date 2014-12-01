module AutomationObject
  class ElementGroup < Array
    include AutomationObject::ElementsHelpers

    def load_elements
      elements_array = self.get_elements
      elements_array.each_with_index { |element_object, index|
        element_cell_configuration = self.get_individual_configuration(index, self.configuration)

        group_cell_options = {
            :framework_object => self.framework_object,
            :screen_object => self.screen_object,
            :driver_object => self.driver_object,
            :blue_prints => element_cell_configuration,
            :screen_name => self.screen_name,
            :element_name => (self.element_name + "(#{index})"),
            :element_object => element_object
        }

        element_cell_object = AutomationObject::ElementCell.new(group_cell_options)

        self.push(element_cell_object)

        this = self
        element_cell_object.on :hook do |args|
          this.emit :hook, args
        end
      }

      self.elements_loaded = true
    end
  end
end