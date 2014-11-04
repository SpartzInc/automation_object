module AutomationObject
  module BluePrintValidation
    module HookValidation
      def validate_hooks
        error_messages = Array.new

        hooks = self.get_hooks
        hooks.each { |hook|
          #Set level string and get it out of the way
          level_key_string = self.get_hook_level(hook)

          #Skip checking if nil, being nice
          next if hook[:configuration] == nil

          unless hook[:configuration].is_a?(Hash)
            error_message = "(#{level_key_string}) hook key (#{hook[:hook_name]}) is an invalid value type, expecting: ("
            error_message << Hash.to_s
            error_message << "), got: (#{hook[:configuration].class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          #before_load has no sub actions so go straight to validate_hook_action and skip this validation
          if hook[:hook_name] == 'before_load'
            error_messages += self.validate_hook_action(hook, hook[:hook_name], hook[:configuration])
            next
          end

          hook[:configuration].each { |hook_action, hook_action_configuration|
            #Check if valid element keys
            hook_pair_types = KeyValueConstants::HOOK_PAIR_TYPES.clone
            hook_pair_types.delete('elements') unless hook[:hook_name] == 'live?'

            unless hook_pair_types.keys.include?(hook_action)
              error_message = "(#{level_key_string}) level key (#{hook[:hook_name]}) sub key (#{hook_action}) "
              error_message << 'is not a valid key, available hook sub level keys ('
              error_message << hook_pair_types.keys.join(', ').to_s + ')'
              error_messages.push(FormattedErrors::format_message(error_message))

              next #skip if not a valid key since we are not going to check value
            end

            #Skip checking if nil, being nice
            next if hook_action_configuration == nil

            #Check sub element value
            unless hook_action_configuration.is_a?(KeyValueConstants::HOOK_PAIR_TYPES[hook_action])
              error_message = "(#{level_key_string}) level key (#{hook[:hook_name]}) sub key (#{hook_action}) "
              error_message << 'has an invalid value type, expected: ('
              error_message << KeyValueConstants::HOOK_PAIR_TYPES[hook_action].to_s
              error_message << "), got: (#{hook_action_configuration.class.to_s})"
              error_messages.push(FormattedErrors::format_message(error_message))

              next #Skip any additional validation on this
            end

            error_messages += self.validate_hook_action(hook, hook_action, hook_action_configuration)
          }
        }

        return error_messages
      end

      def validate_hook_action(hook, action, hook_action_configuration)
        error_messages = Array.new
        return error_messages if hook_action_configuration == nil #Being nice

        level_key_string = self.get_hook_level(hook, action)

        #Skip if elements action and use validate_elements_hook
        if action == 'elements'
          return self.validate_elements_hook(hook, action, hook_action_configuration)
        end

        unless hook_action_configuration.is_a?(Hash)
          error_message = "(#{level_key_string}) hook action is an invalid value type, expecting: ("
          error_message << Hash.to_s
          error_message << "), got: (#{hook_action_configuration.class.to_s})"
          error_messages.push(FormattedErrors::format_message(error_message))

          return error_messages #Skip any additional validation on this
        end

        hook_action_configuration.each { |sub_action_key, sub_action_value|
          #Check if valid sub hook action keys
          unless KeyValueConstants::HOOK_ACTION_PAIR_TYPES.keys.include?(sub_action_key)
            error_message = "(#{level_key_string}) level sub key (#{sub_action_key}) "
            error_message << 'is not a valid key, available (hook action) sub level keys ('
            error_message << KeyValueConstants::HOOK_ACTION_PAIR_TYPES.keys.join(', ').to_s + ')'
            error_messages.push(FormattedErrors::format_message(error_message))

            next #skip if not a valid key since we are not going to check value
          end

          #Skip checking if nil, being nice
          next if sub_action_value == nil

          #Check sub hook action value
          unless sub_action_value.is_a?(KeyValueConstants::HOOK_ACTION_PAIR_TYPES[sub_action_key])
            error_message = "(#{level_key_string}) level sub key (#{sub_action_key}) "
            error_message << 'has an invalid value type, expected: ('
            error_message << KeyValueConstants::HOOK_ACTION_PAIR_TYPES[sub_action_key].to_s
            error_message << "), got: (#{sub_action_key.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          #wait_for_elements test with validate_elements_hook, same set up as live?/elements
          if sub_action_key == 'wait_for_elements'
            error_messages += self.validate_elements_hook(hook, action, sub_action_key, sub_action_value)
            next
          end

          case sub_action_key
            when 'show_modal'
              if hook[:view_name]
                modal_exists = self.view_has_modal?(hook[:view_name], sub_action_value)
              else
                modal_exists = self.screen_has_modal?(hook[:screen_name], sub_action_value)
              end

              unless modal_exists
                error_message = "(#{level_key_string}) level sub key (#{sub_action_key}) value (#{sub_action_value}) "
                error_message << 'modal does not exist in '

                if hook[:view_name]
                  error_message << "view (#{hook[:view_name]}), available modals ("
                  error_message << self.get_view_modals(hook[:view_name]).join(', ')
                  error_message << ')'
                else
                  error_message << "screen (#{hook[:screen_name]}), available modals ("
                  error_message << self.get_screen_modals(hook[:screen_name]).join(', ')
                  error_message << ')'
                end

                error_messages.push(FormattedErrors::format_message(error_message))
              end
            when 'change_screen'
              unless self.screen_exists?(sub_action_value)
                error_message = "(#{level_key_string}/#{sub_action_key}) value (#{sub_action_value}) is not a defined screen. Available screens ("
                error_message << self.get_screens.join(', ')
                error_message << ')'
                error_messages.push(FormattedErrors::format_message(error_message))
              end
          end
        }

        return error_messages
      end

      def validate_elements_hook(hook, action, sub_action_key = false, hook_action_configuration)
        error_messages = Array.new
        return error_messages if hook_action_configuration == nil

        if action == 'before_load'
          action = "#{sub_action_key}" if sub_action_key.is_a?(String)
        else
          action = action + "/#{sub_action_key}" if sub_action_key.is_a?(String)
        end

        level_key_string = self.get_hook_level(hook, action)

        unless hook_action_configuration.is_a?(Array)
          error_message = "(#{level_key_string}) level key is an invalid value type, expecting: ("
          error_message << Array.to_s
          error_message << "), got: (#{hook_action_configuration.class.to_s})"
          error_messages.push(FormattedErrors::format_message(error_message))

          return error_messages #Skip any further validation
        end

        hook_action_configuration.each_with_index { |element_hash, index|
          unless element_hash.is_a?(Hash)
            error_message = "(#{level_key_string}/#{index.to_s}) level key is an invalid value type, expecting: ("
            error_message << Hash.to_s
            error_message << "), got: (#{element_hash.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))

            next #Skip any additional validation on this
          end

          unless element_hash.has_key?('element_name')
            error_message = "(#{level_key_string}/#{index.to_s}) level key Hash requires the element_name key"
            error_message << Hash.to_s
            error_message << "), got: (#{element_hash.class.to_s})"
            error_messages.push(FormattedErrors::format_message(error_message))
          end

          acceptable_keys = KeyValueConstants::ELEMENT_KEYS + ['element_name']
          acceptable_keys += self.get_element_custom_methods_via_hook(hook, element_hash['element_name'])
          element_hash.each { |sub_element_key, sub_element_value|
            unless acceptable_keys.include?(sub_element_key)
              error_message = "(#{level_key_string}/#{index.to_s}) level sub key (#{sub_element_key}) "
              error_message << 'is not a valid key, available sub level keys ('
              error_message << acceptable_keys.join(', ').to_s + ')'
              error_messages.push(FormattedErrors::format_message(error_message))

              next #skip if not a valid key since we are not going to check value
            end
          }
        }

        return error_messages
      end

      def get_element_custom_methods_via_hook(hook, element_name)
        custom_methods = Array.new

        if hook[:screen_name]
          return custom_methods unless self.has_key?('screens')
          return custom_methods unless self['screens'].class == Hash
          return custom_methods unless self['screens'].has_key?(hook[:screen_name])

          configuration = self['screens'][hook[:screen_name]]
        else
          return custom_methods unless self.has_key?('views')
          return custom_methods unless self['views'].class == Hash
          return custom_methods unless self['views'].has_key?(hook[:view_name])

          configuration = self['views'][hook[:view_name]]
        end

        if hook[:modals]
          return custom_methods unless configuration.has_key?('modals')
          return custom_methods unless configuration['modals'].class == Hash
          return custom_methods unless configuration['modals'].has_key?(hook[:modal_name])

          configuration = configuration['modals'][hook[:modal_name]]
        end

        return custom_methods unless configuration.class == Hash
        return custom_methods unless configuration.has_key?('elements')
        return custom_methods unless configuration['elements'].class == Hash
        return custom_methods unless configuration['elements'].has_key?(element_name)

        element_configuration = configuration['elements'][element_name]

        return custom_methods unless element_configuration.class == Hash
        return custom_methods unless element_configuration.has_key?('custom_methods')
        return custom_methods unless element_configuration['custom_methods'].class == Hash

        return element_configuration['custom_methods'].keys
      end

      def get_hook_level(hook, hook_action = false)
        level_key_string = ''
        if hook[:view_name]
          level_key_string << "views/#{hook[:view_name]}"
        else
          level_key_string << "screens/#{hook[:screen_name]}"
        end

        level_key_string << "/modals/#{hook[:modal_name]}" if hook[:modal_name]
        level_key_string << "/elements/#{hook[:element_name]}" if hook[:element_name]

        level_key_string << "/#{hook[:hook_name]}" if hook[:hook_name]
        level_key_string << "/#{hook_action}" if hook_action and hook_action != 'before_load'

        return level_key_string
      end

      def get_hooks
        hooks = Array.new

        if self.has_key?('views') and self['views'].class == Hash
          self['views'].each { |view_name, view_configuration|
            next unless view_configuration.class == Hash

            view_configuration.each { |sub_view_key, sub_view_configuration|
              next unless KeyValueConstants::HOOK_KEYS.include?(sub_view_key)

              hook = {:view_name => view_name, :hook_name => sub_view_key, :configuration => sub_view_configuration}
              hooks.push(hook)
            }

            #Check for Modals
            if view_configuration.has_key?('modals') and view_configuration['modals'].class == Hash
              view_configuration['modals'].each { |modal_name, modal_configuration|
                next unless modal_configuration.class == Hash

                modal_configuration.each { |sub_modal_key, sub_modal_configuration|
                  next unless KeyValueConstants::HOOK_KEYS.include?(sub_modal_key)

                  hook = {:view_name => view_name, :modal_name => modal_name,
                          :hook_name => sub_modal_key, :configuration => sub_modal_configuration}
                  hooks.push(hook)
                }

                next unless modal_configuration.has_key?('elements')
                next unless modal_configuration['elements'].class == Hash

                modal_configuration['elements'].each { |modal_element_name, modal_element_configuration|
                  next unless modal_element_configuration.class == Hash

                  modal_element_configuration.each { |sub_modal_element_key, sub_modal_element_configuration|
                    next unless KeyValueConstants::ELEMENT_KEYS.include?(sub_modal_element_key)

                    hook = {:view_name => view_name, :modal_name => modal_name,
                            :element_name => modal_element_name, :hook_name => sub_modal_element_key,
                            :configuration => sub_modal_element_configuration}
                    hooks.push(hook)
                  }
                }
              }
            end

            #Check for element hooks
            next unless view_configuration.has_key?('elements')
            next unless view_configuration['elements'].class == Hash

            view_configuration['elements'].each { |element_name, element_configuration|
              next unless element_configuration.class == Hash

              element_configuration.each { |sub_element_key, sub_element_configuration|
                next unless KeyValueConstants::ELEMENT_KEYS.include?(sub_element_key)

                hook = {:view_name => view_name, :element_name => element_name,
                        :hook_name => sub_element_key, :configuration => sub_element_configuration}
                hooks.push(hook)
              }
            }
          }
        end

        return hooks unless self.has_key?('screens')
        return hooks unless self['screens'].class == Hash

        self['screens'].each { |screen_name, screen_configuration|
          next unless screen_configuration.class == Hash

          screen_configuration.each { |sub_screen_key, sub_screen_configuration|
            next unless KeyValueConstants::HOOK_KEYS.include?(sub_screen_key)

            hook = {:screen_name => screen_name, :hook_name => sub_screen_key,
                    :configuration => sub_screen_configuration}
            hooks.push(hook)
          }

          #Check for Modals
          if screen_configuration.has_key?('modals') and screen_configuration['modals'].class == Hash
            screen_configuration['modals'].each { |modal_name, modal_configuration|
              next unless modal_configuration.class == Hash

              modal_configuration.each { |sub_modal_key, sub_modal_configuration|
                next unless KeyValueConstants::HOOK_KEYS.include?(sub_modal_key)

                hook = {:screen_name => screen_name, :modal_name => modal_name,
                        :hook_name => sub_modal_key, :configuration => sub_modal_configuration}
                hooks.push(hook)
              }

              next unless modal_configuration.has_key?('elements')
              next unless modal_configuration['elements'].class == Hash

              modal_configuration['elements'].each { |modal_element_name, modal_element_configuration|
                next unless modal_element_configuration.class == Hash

                modal_element_configuration.each { |sub_modal_element_key, sub_modal_element_configuration|
                  next unless KeyValueConstants::ELEMENT_KEYS.include?(sub_modal_element_key)

                  hook = {:screen_name => screen_name, :modal_name => modal_name,
                          :element_name => modal_element_name, :hook_name => sub_modal_element_key,
                          :configuration => sub_modal_element_configuration}
                  hooks.push(hook)
                }
              }
            }
          end

          #Check for element hooks
          next unless screen_configuration.has_key?('elements')
          next unless screen_configuration['elements'].class == Hash

          screen_configuration['elements'].each { |element_name, element_configuration|
            next unless element_configuration.class == Hash

            element_configuration.each { |sub_element_key, sub_element_configuration|
              next unless KeyValueConstants::ELEMENT_KEYS.include?(sub_element_key)

              hook = {:screen_name => screen_name, :element_name => element_name,
                      :hook_name => sub_element_key, :configuration => sub_element_configuration}
              hooks.push(hook)
            }
          }
        }

        return hooks
      end
    end
  end
end