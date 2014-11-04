module AutomationObject
  module BluePrintValidation
    module BaseValidation
      def validate_base
        error_messages = Array.new

        self.each { |base_key, base_value|
          #Check if valid base keys
          unless KeyValueConstants::BASE_PAIR_TYPES.keys.include?(base_key)
            error_message = "Base level key (#{base_key}) is not a valid key, available base level keys ("
            error_message << KeyValueConstants::BASE_PAIR_TYPES.keys.join(', ').to_s + ')'
            error_messages.push(FormattedErrors::format_message(error_message))

            next #skip if not a valid key since we are not going to check value
          end

          #Skip checking if nil, being nice
          next if base_value == nil

          unless base_value.is_a?(KeyValueConstants::BASE_PAIR_TYPES[base_key])
            error_message = "Base level key (#{base_key}) has an invalid value type, expecting: ("
            error_message << KeyValueConstants::BASE_PAIR_TYPES[base_key].to_s
            error_message << "), got: (#{base_value.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          case base_key
            when 'default_screen'
              unless self.screen_exists?(self[base_key])
                error_message = "(#{base_key}) value has screen that does not exist (#{self[base_key]}), available screens ("
                error_message << self.get_screens.join(', ').to_s
                error_message << ')'
                error_messages.push(FormattedErrors::format_message(error_message))
              end
          end
        }

        return error_messages
      end
    end
  end
end