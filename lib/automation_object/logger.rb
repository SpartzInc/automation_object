module AutomationObject
  class Logger
    @@log = Array.new

    @@output_message_caller_locations = false
    @@output_driver_caller_locations = false
    @@output_driver_element_caller_locations = false

    def self.output_message_caller_locations
      @@output_message_caller_locations
    end

    def self.output_message_caller_locations=(value)
      @@output_message_caller_locations = value
    end

    def self.output_driver_caller_locations
      @@output_driver_caller_locations
    end

    def self.output_driver_caller_locations=(value)
      @@output_driver_caller_locations = value
    end

    def self.output_driver_element_caller_locations
      @@output_driver_element_caller_locations
    end

    def self.output_driver_element_caller_locations=(value)
      @@output_driver_element_caller_locations = value
    end

    def self.add(message, location = false)
      called_locations = caller_locations
      parsed_message = self::parse_message(message, called_locations, location)

      @@log.push(parsed_message)

      if AutomationObject::debug_mode
        self::output_message(parsed_message)
      end
    end

    def self.add_driver_message(total_time_taken, called_locations, method_symbol, *arguments, &block)
      parsed_message = self::parse_driver_message(total_time_taken, called_locations, method_symbol, *arguments, &block)

      @@log.push(parsed_message)

      if AutomationObject::debug_mode
        self::output_driver_message(parsed_message)
      end
    end

    def self.add_driver_element_message(total_time_taken, called_locations, method_symbol, *arguments, &block)
      parsed_message = self::parse_driver_element_message(total_time_taken, called_locations, method_symbol, *arguments, &block)

      @@log.push(parsed_message)

      if AutomationObject::debug_mode
        self::output_driver_element_message(parsed_message)
      end
    end

    def self.get_thread_message
      return (Thread.main == Thread.current) ? 'main '.colorize(:black) : 'secondary '.colorize(:light_black)
    end

    def self.parse_message(message, called_locations, location)
      parsed_message = Hash.new
      parsed_message[:message] = message.to_s
      parsed_message[:called_locations] = called_locations

      #Add which thread this is under
      parsed_message[:thread_name] = self::get_thread_message

      parsed_message[:location] = 'framework_object'
      return parsed_message unless location.is_a?(Array)

      parsed_message[:location] << '.'
      location.each { |part|
        parsed_message[:location] << part.to_s + '.'
      }
      parsed_message[:location].gsub!(/\.$/, '')

      return parsed_message
    end

    def self.parse_driver_message(total_time_taken, called_locations, method_symbol, *arguments, &block)
      parsed_message = Hash.new
      parsed_message[:driver_message] = true

      #Add which thread this is under
      parsed_message[:thread_name] = self::get_thread_message

      parsed_message[:total_time_taken] = total_time_taken.round(4)
      parsed_message[:method_called] = method_symbol.to_s
      parsed_message[:called_locations] = called_locations

      parsed_message[:arguments] = arguments.to_s
      parsed_message[:arguments] = parsed_message[:arguments].to_s
      return parsed_message
    end

    def self.parse_driver_element_message(total_time_taken, called_locations, method_symbol, *arguments, &block)
      parsed_message = Hash.new
      parsed_message[:driver_element_message] = true

      #Add which thread this is under
      parsed_message[:thread_name] = self::get_thread_message

      parsed_message[:total_time_taken] = total_time_taken.round(4)
      parsed_message[:method_called] = method_symbol.to_s
      parsed_message[:called_locations] = called_locations
      parsed_message[:arguments] = arguments.to_s

      return parsed_message
    end

    def self.format_object_name(object_name)
      return false unless object_name

      return object_name.to_s.gsub(/_class$/, '')
    end

    def self.output_messages
      @@log.each { |parsed_message|
        self::output_message(parsed_message)
      }
    end

    def self.output_message(parsed_message)
      return self::output_driver_message(parsed_message) if parsed_message[:driver_message]
      return self::output_driver_element_message(parsed_message) if parsed_message[:driver_element_message]

      output_string = 'debug: '.colorize(:black)
      output_string << "thread: ".colorize(:cyan)
      output_string << parsed_message[:thread_name]
      output_string << "location: ".colorize(:cyan)
      output_string << "#{parsed_message[:location]} "
      output_string << "message: ".colorize(:cyan)
      output_string << "#{parsed_message[:message]} "

      Kernel.puts output_string #Just in case you're running under Cucumber
      if self.output_message_caller_locations
        Kernel.ap parsed_message[:called_locations] if parsed_message[:called_locations]
      end
    end

    def self.output_driver_message(parsed_message)
      output_string = "driver call (#{parsed_message[:total_time_taken]} S): ".colorize(:light_black)
      output_string << "thread: ".colorize(:cyan)
      output_string << parsed_message[:thread_name]
      output_string << "method: ".colorize(:cyan)
      output_string << "#{parsed_message[:method_called]} "
      output_string << "args: ".colorize(:cyan)
      output_string << "#{parsed_message[:arguments]} "

      Kernel.puts output_string #Just in case you're running under Cucumber
      if self.output_driver_caller_locations
        Kernel.ap parsed_message[:called_locations] if parsed_message[:called_locations]
      end
    end

    def self.output_driver_element_message(parsed_message)
      output_string = "driver element call (#{parsed_message[:total_time_taken]} S): ".colorize(:light_black)
      output_string << "thread: ".colorize(:cyan)
      output_string << parsed_message[:thread_name]
      output_string << "method: ".colorize(:cyan)
      output_string << "#{parsed_message[:method_called]} "
      output_string << "args: ".colorize(:cyan)
      output_string << "#{parsed_message[:arguments]} "

      Kernel.puts output_string #Just in case you're running under Cucumber
      if self.output_driver_element_caller_locations
        Kernel.ap parsed_message[:called_locations] if parsed_message[:called_locations]
      end
    end
  end
end