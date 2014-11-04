module AutomationObject
  module BluePrintValidation
    module ScreenModalCommonMethods
      def validate_screen_modal(screen_name, modal_name = false, configuration)
        error_messages = Array.new

        if modal_name == false #Skip multiple errors
          unless screen_name.is_a?(String)
            error_message = "(screens) level key (#{screen_name}) is an invalid key type, expecting: ("
            error_message << String.to_s
            error_message << "), got: (#{screen_name.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))
          end
        else
          unless modal_name.is_a?(String)
            error_message = "(screens/#{screen_name}/modals) level key (#{modal_name}) is an invalid key type, expecting: ("
            error_message << String.to_s
            error_message << "), got: (#{modal_name.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))
          end
        end

        return error_messages if configuration == nil

        unless configuration.is_a?(Hash)
          if modal_name == false
            error_message = "(screens) level key (#{screen_name}) has an invalid value type, expecting: ("
          else
            error_message = "(screens/#{screen_name}/modals) level key (#{modal_name}) has an invalid value type, expecting: ("
          end

          error_message << Hash.to_s
          error_message << "), got: (#{configuration.class.to_s})"
          error_messages.push(FormattedErrors::format_message(error_message))

          return error_messages
        end

        configuration.each { |sub_screen_key, sub_screen_value|
          #Check if valid screen keys
          unless KeyValueConstants::SCREEN_PAIR_TYPES.keys.include?(sub_screen_key)
            if modal_name == false
              error_message = "(screens) level key (#{screen_name}) sub key (#{sub_screen_key}) "
            else
              error_message = "(screens/#{screen_name}/modals) level key (#{modal_name}) sub key (#{sub_screen_key}) "
            end

            error_message << 'is not a valid key, available (screens) sub level keys ('
            error_message << KeyValueConstants::SCREEN_PAIR_TYPES.keys.join(', ').to_s + ')'
            error_messages.push(FormattedErrors::format_message(error_message))

            next #skip if not a valid key since we are not going to check value
          end

          #Skip checking if nil, being nice
          next if sub_screen_value == nil

          #Check sub screen value
          unless sub_screen_value.is_a?(KeyValueConstants::SCREEN_PAIR_TYPES[sub_screen_key])
            if modal_name == false
              error_message = "(screens) level key (#{screen_name}) sub key (#{sub_screen_key}) "
            else
              error_message = "(screens/#{screen_name}/modals) level key (#{screen_name}) sub key (#{sub_screen_key}) "
            end

            error_message << 'has an invalid value type, expected: ('
            error_message << KeyValueConstants::SCREEN_PAIR_TYPES[sub_screen_key].to_s
            error_message << "), got: (#{sub_screen_value.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          #More complex validation
          case sub_screen_key
            when 'included_views'
              sub_screen_value.each { |included_view|
                unless self.view_exists?(included_view)
                  if modal_name == false
                    error_message = "(screens) level key (#{screen_name}) sub key (#{sub_screen_key}) "
                  else
                    error_message = "(screens/#{screen_name}/modals) level key (#{screen_name}) sub key (#{sub_screen_key}) "
                  end

                  error_message << "included_view (#{included_view}) does not exist. Available views ("
                  error_message << self.get_views.join(', ')
                  error_message << ')'
                  error_messages.push(FormattedErrors::format_message(error_message))
                end
              }
            when 'automatic_screen_changes'
              sub_screen_value.each { |automatic_screen_change|
                unless self.screen_exists?(automatic_screen_change)
                  error_message = "(screens) level key (#{screen_name}) sub key (#{sub_screen_key}) "
                  error_message << "screen (#{automatic_screen_change}) does not exist. Available screens ("
                  error_message << self.get_screens.join(', ')
                  error_message << ')'
                  error_messages.push(FormattedErrors::format_message(error_message))

                  next
                end

                unless self.screen_has_live?(automatic_screen_change)
                  error_message = "(screens) level key (#{screen_name}) sub key (#{sub_screen_key}) "
                  error_message << "screen (#{automatic_screen_change}) does not have live? configuration. "
                  error_message << 'Automatic screen changes need to have associated live? configurations.'
                  error_messages.push(FormattedErrors::format_message(error_message))

                  next
                end
              }
          end
        }

        return error_messages
      end
    end
  end
end