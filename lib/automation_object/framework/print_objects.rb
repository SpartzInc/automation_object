module AutomationObject
  module FrameworkPrintObjects
    def print_objects(requested_screen_name = false)
      puts 'Screens:'.colorize(:green)

      self.instance_variables.each { |automation_variable|
        automation_variable_value = self.instance_variable_get(automation_variable)
        next unless automation_variable_value.class == Screen

        screen_name = self.translate_class_to_string(automation_variable).gsub('@', '')

        if requested_screen_name
          next unless requested_screen_name == screen_name
        end

        screen_class_symbol = self.translate_string_to_class(screen_name)

        puts "\t#{screen_name}".colorize(:blue)

        self.send(screen_class_symbol).instance_variables.each { |screen_variable|
          screen_object_name = self.translate_class_to_string(screen_variable).gsub('@', '')
          screen_object_symbol = self.translate_string_to_class(screen_object_name)

          output = "\t\t#{screen_object_name}".colorize(:magenta)

          begin
            object_class = self.send(screen_class_symbol).send(screen_object_symbol).class.to_s
            case object_class
              when 'AutomationObject::Element'
                puts output + ' (Element)'.colorize(:green)
              when 'AutomationObject::ElementHash'
                puts output + ' (Element Hash)'.colorize(:red)
              when 'AutomationObject::ElementArray'
                puts output + ' (Element Array)'.colorize(:blue)
              when 'AutomationObject::Modal'
                puts output + ' (Modal)'.colorize(:cyan)

                self.send(screen_class_symbol).send(screen_object_symbol).instance_variables.each { |modal_variable|
                  modal_object_name = self.translate_class_to_string(modal_variable).gsub('@', '')
                  modal_object_symbol = self.translate_string_to_class(modal_object_name)

                  modal_output = "\t\t\t#{modal_object_name}".colorize(:magenta)
                  #puts modal_output
                  begin
                    modal_object_class = self.send(screen_class_symbol).send(screen_object_symbol).send(modal_object_symbol).class.to_s

                    case modal_object_class
                      when 'AutomationObject::Element'
                        puts modal_output + ' (Element)'.colorize(:green)
                      when 'AutomationObject::ElementHash'
                        puts modal_output + ' (Element Hash)'.colorize(:red)
                      when 'AutomationObject::ElementArray'
                        puts modal_output + ' (Element Array)'.colorize(:blue)
                    end
                  rescue
                    next
                  end
                }
            end
          rescue
            next
          end
        }
      }
    end
  end
end