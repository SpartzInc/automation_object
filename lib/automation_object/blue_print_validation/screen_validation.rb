module AutomationObject
  module BluePrintValidation
    module ScreenValidation
      include ScreenModalCommonMethods

      def validate_screens
        error_messages = Array.new
        return error_messages unless self.has_key?('screens')
        return error_messages unless self['screens'].class == Hash

        error_messages = Array.new

        self['screens'].each { |screen_name, screen_configuration|
          error_messages += self.validate_screen_modal(screen_name, screen_configuration)
        }

        return error_messages
      end
    end
  end
end