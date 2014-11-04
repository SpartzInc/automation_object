module AutomationObject
  module BluePrintValidation
    class FormattedErrors
      MESSAGE_COLOR = :red
      SPECIFIC_VALUE_COLOR = :blue

      def self.array_to_message(error_messages)
        error_messages.each_with_index { |raw_message, index|
          error_messages[index] = (((index+1).to_s + '. ').colorize(MESSAGE_COLOR) + raw_message)
          error_messages[index] = "\n" + error_messages[index] if index == 0
        }

        formatted_message = error_messages.join("\n ----- \n")
        formatted_message << "\n ----- \n"
        return formatted_message
      end

      def self.format_message(error_message)
        specific_values = error_message.scan(/\([^\)]+\)/)
        replaced_string = error_message.gsub(/\([^\)]+\)/, '######')
        message_array = replaced_string.split('######')

        return error_message.colorize(MESSAGE_COLOR) if specific_values.length == 0

        formatted_message = ''
        message_array.each_with_index { |message, index|
          formatted_message << message.colorize(MESSAGE_COLOR)

          next if specific_values[index] == nil
          stripped_specific_value = specific_values[index].gsub(/\(/, '').gsub(/\)/, '')
          final_specific_value = '('.colorize(MESSAGE_COLOR)
          final_specific_value << stripped_specific_value.colorize(SPECIFIC_VALUE_COLOR)
          final_specific_value << ')'.colorize(MESSAGE_COLOR)
          formatted_message << final_specific_value
        }

        return formatted_message
      end
    end
  end
end