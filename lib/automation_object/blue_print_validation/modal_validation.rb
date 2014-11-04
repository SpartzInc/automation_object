module AutomationObject
  module BluePrintValidation
    module ModalValidation
      include ScreenModalCommonMethods

      def validate_modals
        error_messages = Array.new

        self.get_all_modals.each { |modal|
          error_messages += self.validate_screen_modal(modal[:screen_name], modal[:modal_name], modal[:configuration])
        }

        return error_messages
      end

      def get_all_modals
        modals = Array.new
        return modals unless self.has_key?('screens')
        return modals unless self['screens'].class == Hash

        self['screens'].each { |screen_name, screen_configuration|
          next unless screen_configuration.class == Hash
          next unless screen_configuration.has_key?('modals')
          next unless screen_configuration['modals'].class == Hash

          screen_configuration['modals'].each { |modal_name, modal_configuration|
            next if modal_configuration == nil
            modal = {:screen_name => screen_name, :modal_name => modal_name, :configuration => modal_configuration}
            modals.push(modal)
          }
        }

        return modals
      end
    end
  end
end