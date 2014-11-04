module AutomationObject
  module BluePrintValidation
    module ElementValidation
      def validate_elements
        error_messages = Array.new

        elements = self.get_elements

        elements.each { |element|
          #Set level string and get it out of the way
          level_key_string = ''
          if element[:view_name]
            level_key_string = "(views/#{element[:view_name]}/elements)"
          elsif element[:modal_name]
            level_key_string = "(screens/#{element[:screen_name]}/modals/#{element[:modal_name]}/elements)"
          else
            level_key_string = "(screens/#{element[:screen_name]}/elements)"
          end

          unless element[:element_name].is_a?(String)
            error_message = "#{level_key_string} level key (#{element[:element_name]}) is an invalid key type, expecting: ("
            error_message << String.to_s
            error_message << "), got: (#{element[:element_name].class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))
          end

          #Skip checking if nil, being nice
          next if element[:configuration] == nil

          unless element[:configuration].is_a?(Hash)
            error_message = "#{level_key_string} level key (#{element[:element_name]}) is an invalid value type, expecting: ("
            error_message << Hash.to_s
            error_message << "), got: (#{element[:configuration].class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          element[:configuration].each { |sub_element_key, sub_element_value|
            #Check if valid element keys
            unless KeyValueConstants::ELEMENT_PAIR_TYPES.keys.include?(sub_element_key)
              error_message = "#{level_key_string} level key (#{element[:element_name]}) sub key (#{sub_element_key}) "
              error_message << 'is not a valid key, available (elements) sub level keys ('
              error_message << KeyValueConstants::ELEMENT_PAIR_TYPES.keys.join(', ').to_s + ')'
              error_messages.push(FormattedErrors::format_message(error_message))

              next #skip if not a valid key since we are not going to check value
            end

            #Skip checking if nil, being nice
            next if sub_element_value == nil

            #Check sub element value
            unless sub_element_value.is_a?(KeyValueConstants::ELEMENT_PAIR_TYPES[sub_element_key])
              error_message = "#{level_key_string} level key (#{element[:element_name]}) sub key (#{sub_element_key}) "
              error_message << 'has an invalid value type, expected: ('
              error_message << KeyValueConstants::SCREEN_PAIR_TYPES[sub_element_key].to_s
              error_message << "), got: (#{sub_element_value.class.to_s})"
              error_messages.push(FormattedErrors::format_message(error_message))

              next #Skip any additional validation on this
            end

            case sub_element_key
              when 'define_elements_by'
                valid_element_methods = KeyValueConstants::ELEMENT_KEYS + self.get_element_custom_methods(element[:configuration])

                unless valid_element_methods.include?(sub_element_value)
                  error_message = "#{level_key_string} level key (#{element[:element_name]}) sub key (#{sub_element_key}) "
                  error_message << 'is not a valid element methods key. Available keys ('
                  error_message << valid_element_methods.join(', ')
                  error_message << ')'
                  error_messages.push(FormattedErrors::format_message(error_message))
                end
              when 'custom_methods'
                sub_element_value.each { |custom_method_name, custom_method_configuration|
                  unless custom_method_name.is_a?(String)
                    error_message = "#{level_key_string} level key (#{element[:element_name]}) custom_methods sub key (#{custom_method_name}) "
                    error_message << 'is not a valid key type, expected: ('
                    error_message << String.to_s
                    error_message << "), got: (#{custom_method_name.class.to_s})"
                    error_messages.push(FormattedErrors::format_message(error_message))
                  end

                  unless custom_method_configuration.is_a?(Hash)
                    error_message = "#{level_key_string} level key (#{element[:element_name]}) custom_methods sub key (#{custom_method_name}) "
                    error_message << 'is not a valid key value type, expected: ('
                    error_message << Hash.to_s
                    error_message << "), got: (#{custom_method_configuration.class.to_s})"
                    error_messages.push(FormattedErrors::format_message(error_message))

                    next
                  end

                  custom_method_configuration.each { |custom_method_key, custom_method_value|
                    unless KeyValueConstants::ELEMENT_CUSTOM_METHOD_PAIR_TYPES.keys.include?(custom_method_key)
                      error_message = "#{level_key_string} level key (#{element[:element_name]}) custom_methods (#{custom_method_name}) method sub key (#{custom_method_key}) "
                      error_message << 'is not a valid key, available (custom_methods) sub level keys ('
                      error_message << KeyValueConstants::ELEMENT_CUSTOM_METHOD_PAIR_TYPES.keys.join(', ').to_s + ')'
                      error_messages.push(FormattedErrors::format_message(error_message))

                      next #skip if not a valid key since we are not going to check value
                    end

                    #Skip checking if nil, being nice
                    next if custom_method_value == nil

                    unless custom_method_value.is_a?(KeyValueConstants::ELEMENT_CUSTOM_METHOD_PAIR_TYPES[custom_method_key])
                      error_message = "#{level_key_string} level key (#{element[:element_name]}) custom_methods (#{custom_method_name}) method sub key (#{custom_method_key}) "
                      error_message << 'has an invalid value type, expected: ('
                      error_message << KeyValueConstants::ELEMENT_CUSTOM_METHOD_PAIR_TYPES[custom_method_key].to_s
                      error_message << "), got: (#{custom_method_value.class.to_s})"
                      error_messages.push(FormattedErrors::format_message(error_message))

                      next #Skip any additional validation on this
                    end

                    case custom_method_key
                      when 'element_method'
                        unless KeyValueConstants::ELEMENT_KEYS.include?(custom_method_value)
                          error_message = "#{level_key_string} level key (#{element[:element_name]}) custom_methods (#{custom_method_name}) sub key (#{custom_method_key}) "
                          error_message << 'is not a valid elements method. Available element methods ('
                          error_message << KeyValueConstants::ELEMENT_KEYS.join(', ')
                          error_messages.push(FormattedErrors::format_message(error_message))
                        end
                    end
                  }
                }
            end
          }
        }

        return error_messages
      end

      def get_element_custom_methods(configuration)
        custom_methods = Array.new
        return custom_methods unless configuration.class == Hash
        return custom_methods unless configuration.has_key?('custom_methods')
        return custom_methods unless configuration['custom_methods'].class == Hash

        custom_methods = configuration['custom_methods'].keys
        return custom_methods
      end

      def get_elements
        elements = Array.new

        if self.has_key?('views') and self['views'].class == Hash
          self['views'].each { |view_name, view_configuration|
            next unless view_configuration.class == Hash
            next unless view_configuration.has_key?('elements')
            next unless view_configuration['elements'].class == Hash

            view_configuration['elements'].each { |view_element_name, view_element_configuration|
              element = {:view_name => view_name, :element_name => view_element_name,
                         :configuration => view_element_configuration}
              elements.push(element)
            }
          }
        end

        if self.has_key?('screens') and self['screens'].class == Hash
          self['screens'].each { |screen_name, screen_configuration|
            next unless screen_configuration.class == Hash

            if screen_configuration.has_key?('elements') and screen_configuration['elements'].class == Hash
              screen_configuration['elements'].each { |screen_element_name, screen_element_configuration|
                element = {:screen_name => screen_name, :element_name => screen_element_name,
                           :configuration => screen_element_configuration}
                elements.push(element)
              }
            end

            #Get elements from modals
            next unless screen_configuration.class == Hash
            next unless screen_configuration.has_key?('modals')
            next unless screen_configuration['modals'].class == Hash

            screen_configuration['modals'].each { |modal_name, modal_configuration|
              next unless modal_configuration.class == Hash
              next unless modal_configuration.has_key?('elements')
              next unless modal_configuration['elements'].class == Hash

              modal_configuration['elements'].each { |modal_element_name, modal_element_configuration|
                element = {:screen_name => screen_name, :modal_name => modal_name,
                           :element_name => modal_element_name, :configuration => modal_element_configuration}
                elements.push(element)
              }
            }
          }
        end

        return elements
      end
    end
  end
end