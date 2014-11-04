module AutomationObject
  module ScreenModalHelpers
    def add_modals(params, configuration)
      return unless configuration.class == Hash

      configuration.each { |modal_name, modal_configuration|
        modal_class_symbol = self.translate_string_to_class(modal_name)

        setter = "#{modal_class_symbol}="
        self.class.send(:attr_accessor, modal_class_symbol) unless respond_to?(setter)

        params[:blue_prints] = modal_configuration
        send setter, Modal.new(modal_name, params)

        #Add emit listeners and relay from this screen out
        #Add Listeners
        this = self
        self.send(modal_class_symbol).on :change_screen do |args|
          this.emit :change_screen, {
              :screen_class_symbol => args[:screen_class_symbol],
              :created_window_handle => args[:created_window_handle]
          }
        end

        self.send(modal_class_symbol).on :close_window do |args|
          this.emit :close_window, {
              :screen_name => args[:screen_name],
              :skip_close => args[:skip_close]
          }
        end
      }
    end

    #Todo: modify show modal to be on all possible element methods, also add stuff for hide modal
    def route_to_modal(modal_requested)
      AutomationObject::Logger::add('Trying to route to modal', [self.framework_location])

      use_element = nil
      #Loop through all the elements and try to find "show_modal"
      self.configuration['elements'] = Hash.new unless self.configuration['elements'].class == Hash
      self.configuration['elements'].each { |element_name, element_configuration|
        next unless element_configuration.class == Hash
        next unless element_configuration['click'].class == Hash
        next unless element_configuration['click']['after'].class == Hash
        next unless element_configuration['click']['after']['show_modal']
        next unless element_configuration['click']['after']['show_modal'].to_s == modal_requested.to_s

        use_element = element_name
      }

      unless use_element
        raise "Unable to route to modal #{modal_requested} in screen #{self.screen_name}, no element in screen has show modal for the requested modal"
      end

      #Send the click request
      self.send(use_element).click
    end

    def activate_modal(modal_requested)
      self.active_modal = modal_requested
      self.send(modal_requested).before_load #Run before_load event
    end

    def close_modal(modal_symbol)
      unless self.active_modal == modal_symbol
        raise "Expecting modal #{modal_symbol} to be active when requesting to close the modal."
      end

      modal_configuration = self.send(modal_symbol).configuration

      unless modal_configuration.class == Hash
        raise "Expecting modal #{modal_symbol} to have a Hash configuration, got: #{modal_configuration.class}"
      end

      unless modal_configuration['elements'].class == Hash
        raise "Expecting modal #{modal_symbol} -> elements to have a Hash configuration, got: #{modal_configuration['elements'].class}"
      end

      modal_elements = modal_configuration['elements']
      modal_elements.each { |modal_element, element_value|
        next unless element_value.class == Hash

        element_value.each { |property_key, property_value|
          next unless property_value.class == Hash
          next unless property_value['after'].class == Hash

          property_value['after'].each { |hook_key, hook_value|
            next unless hook_key == 'close_modal'
            next unless hook_value == true

            self.send(modal_symbol).send(modal_element).send(property_key)
            return
          }
        }
      }

      raise "Unable to close modal #{modal_symbol}, no elements found that would close the modal"

    end
  end
end