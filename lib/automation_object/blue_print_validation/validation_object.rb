module AutomationObject
  module BluePrintValidation
    class ValidationObject < Hash
      include CommonMethods
      include BaseValidation
      include ScreenValidation
      include ModalValidation
      include ElementValidation
      include HookValidation

      def initialize(blue_print_object)
        #Figured on cloning the Hash Object, probably not needed
        blue_print_object_cloned = blue_print_object.clone

        blue_print_object_cloned.each { |key, value|
          self[key] = value
        }

        error_messages = Array.new
        error_messages += self.validate_base #BaseValidation Module
        error_messages += self.validate_screens #ScreenValidation Module
        error_messages += self.validate_modals
        error_messages += self.validate_elements
        error_messages += self.validate_hooks

        if error_messages.length > 0
          raise FormattedErrors::array_to_message(error_messages)
        end
      end
    end
  end
end