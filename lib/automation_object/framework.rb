module AutomationObject
  class Framework
    include AutomationObject::FrameworkScreenRouting
    include AutomationObject::FrameworkHelpers
    include AutomationObject::FrameworkWindowHelpers
    include AutomationObject::FrameworkPrintObjects
    include AutomationObject::FrameworkScreenMonitor

    include EventEmitter
    include AutomationObject::FrameworkEvents

    attr_accessor :driver_object, :configuration,
                  :current_screen_class, :previous_screen_class, #Singular
                  :current_screen_hash, :previous_screen_hash, #Multiple, base screens on window_handle
                  :screen_history_hash, #keys => window_handles, values => array of screen_class_symbols
                  :screen_monitor_thread,
                  :screen_monitor_mutex_object

    def initialize(driver, configuration)
      self.screen_monitor_mutex_object = Mutex.new #Mutex for screen monitor threads, operate one at a time, multiple window edge case

      #Hash for contained screen monitor threads
      self.screen_monitor_thread = Hash.new

      self.configuration = configuration

      #Wrap driver object in our Driver for Thread Safe operations
      self.driver_object = AutomationObject::Driver::Driver.new(driver)
      if self.configuration['throttle_driver_methods']
        AutomationObject::Driver::Driver::throttle_methods = self.configuration['throttle_driver_methods']
      end
      if self.configuration['throttle_element_methods']
        AutomationObject::Driver::Element::throttle_methods = self.configuration['throttle_element_methods']
      end

      #Support multiple windows for Browser
      if self.is_browser?
        self.current_screen_hash = Hash.new
        self.previous_screen_hash = Hash.new
        self.screen_history_hash = Hash.new
      end

      #Add Screens
      self.add_screens(configuration['screens']) if configuration['screens']

      #Set Initial Screen
      self.set_initial_screen
    end

    def respond_to?(method_symbol, include_private = false)
      #Translate method in possible internal storage attribute
      class_symbol = self.translate_string_to_class(method_symbol)
      instance_symbol = class_symbol.to_s.gsub(/^@/, '')
      instance_symbol = "@#{instance_symbol}".to_sym

      self.instance_variables.each { |instance_variable|
        return true if instance_variable == instance_symbol
      }

      #If not then do the super on the method_symbol
      super.respond_to?(method_symbol, include_private)
    end

    def method_missing(screen_name, *args, &block)
      unless self.current_screen_class #Don't think this happens, but throwing an exception for checking
        raise "No current screen defined when calling the screen (#{screen_name})"
      end

      #Translate screen name to internal class property
      screen_class_symbol = self.translate_string_to_class(screen_name)
      unless self.respond_to?(screen_class_symbol)
        raise ArgumentError, "Screen called (#{screen_name}) has not been defined"
      end

      #Check for any closed windows and update accordingly
      #Todo: Important!!!! check if this affects anything negatively
      #self.check_closed_windows if self.is_browser?

      #Return screen object if it is the current screen
      return self.send(screen_class_symbol, *args, &block) if self.current_screen_class == screen_class_symbol

      #Check mobile, then just switch_to if the screen is already live
      if self.is_browser?
        self.current_screen_hash.each { |window_handle, current_screen_symbol|
          if current_screen_symbol == screen_class_symbol
            self.switch_to_window(window_handle) unless window_handle == self.get_current_window_handle

            self.current_screen_class = current_screen_symbol
            return self.send(screen_class_symbol, *args, &block)
          end
        }
      end

      unless self.is_browser?
        self.route_to_screen(self.current_screen_class, screen_class_symbol)
        return self.send(screen_class_symbol, *args, &block)
      end

      #Screen is not live, then try to route to it
      routed = false

      self.current_screen_hash.each { |window_handle, current_screen_symbol|
        self.switch_to_window(window_handle)
        self.current_screen_class = current_screen_symbol

        begin
          self.route_to_screen(self.current_screen_class, screen_class_symbol)
          routed = true
          break
        rescue
          # ignored
        end
      }

      unless routed
        #Kind of an edge case but can happen
        if self.current_screen_class != screen_class_symbol
          requested_screen = self.translate_class_to_string(screen_class_symbol)
          current_screen = self.translate_class_to_string(self.current_screen_class)

          raise "Unable to route to screen from any of the current screens. Current Screen (#{current_screen}), Requested Screen (#{requested_screen})"
        end
      end

      self.send(screen_class_symbol, *args, &block)
    end

    def set_initial_screen
      if self.is_browser?
        unless self.configuration['base_url']
          raise ArgumentError, 'base_url is required for Browser configurations'
        end

        begin
          self.driver_object.navigate.to(self.configuration['base_url'])
        rescue Net::ReadTimeout
          sleep(5)
          self.driver_object.navigate.to(self.configuration['base_url'])
        end
      else
        raise ArgumentError, 'App based configuration should not have base_url in configuration' if self.configuration['base_url']
      end

      #Skip checking live? configurations if default_screen is set
      if self.configuration['default_screen']
        initial_screen_symbol = self.translate_string_to_class(self.configuration['default_screen'])

        unless self.respond_to?(initial_screen_symbol)
          raise "Default screen #{self.configuration['default_screen']} has not been defined in configuration"
        end
      else
        initial_screen_symbol = self.find_current_screen
      end

      unless initial_screen_symbol
        raise 'Unable to find the initial screen via live? configurations or no default screen was specified'
      end

      AutomationObject::Logger::add("Setting as initial screen #{initial_screen_symbol}")

      self.set_current_screen(initial_screen_symbol)
    end

    def find_current_screen
      AutomationObject::Logger::add('Looking for possible current screens through screen live? configurations')

      return nil unless self.configuration['screens'].class == Hash

      self.configuration['screens'].each_key { |screen_name|
        screen_class_symbol = self.translate_string_to_class(screen_name)

        next unless self.configuration['screens'][screen_name].class == Hash
        next unless self.configuration['screens'][screen_name]['live?'].class == Hash

        if self.current_screen?(screen_name)
          AutomationObject::Logger::add("Found current screen #{screen_name}")
          return screen_class_symbol
        end
      }

      nil
    end

    def current_screen?(screen_name)
      screen_class_symbol = self.translate_string_to_class(screen_name)

      #Raise error if screen doesn't exist, shouldn't be called in the first place if it doesn't
      unless self.respond_to?(screen_class_symbol)
        raise ArgumentError, "Screen has not been defined, #{screen_class_symbol}"
      end

      #Return true if screen doesn't have live configuration, unable to tell if not so just say yeah
      return true unless self.send(screen_class_symbol).has_live_configuration?

      self.send(self.translate_string_to_class(screen_name)).live?
    end

    def add_screens(configuration)
      this = self
      configuration.each { |screen_name, screen_configuration|
        #Change name of screen for class storage, allows for method missing
        screen_class_symbol = self.translate_string_to_class(screen_name)

        #Add screen class to self
        setter = "#{screen_class_symbol}="
        self.class.send(:attr_accessor, screen_class_symbol) unless self.respond_to?(setter)

        screen_object_options = {
            :framework_object => self,
            :driver_object => self.driver_object,
            :blue_prints => screen_configuration,
            :screen_name => screen_name
        }

        send setter, Screen.new(screen_object_options)

        #Add Listeners
        self.send(screen_class_symbol).on :change_screen do |args|
          this.change_screen_listener(args[:screen_class_symbol], args[:created_window_handle])
        end

        self.send(screen_class_symbol).on :close_window do |args|
          this.close_window(args[:screen_name], args[:skip_close])
        end
      }
    end

    def set_previous_screen
      self.set_current_screen(self.previous_screen_class)
    end

    def reset_screen(screen_class_symbol)
      unless screen_class_symbol.class == Symbol
        raise ArgumentError, 'You need to provide the screen_class_symbol to Framework.reset_screen method'
      end

      unless self.respond_to?(screen_class_symbol)
        raise ArgumentError, "Screen class symbol provided (#{screen_class_symbol}) has not been defined"
      end

      unless self.send(screen_class_symbol).class == Screen
        raise ArgumentError, "Requested symbol (#{screen_class_symbol}) is not a Screen class"
      end

      #Remove listeners
      self.send(screen_class_symbol).reset_screen
    end

    def set_current_screen(screen_class_symbol, new_window = false)
      AutomationObject::Logger::add("Going to set current screen #{screen_class_symbol}")

      #Set current_screen_class to previous_screen_class
      self.previous_screen_class = self.current_screen_class

      #Reset previous screen if needed
      self.reset_screen(self.previous_screen_class) if self.previous_screen_class

      #Reset new screen just in case
      self.reset_screen(screen_class_symbol)

      #Sleep if default sleep
      if self.configuration['screen_transition_sleep']
        transition_sleep = self.configuration['screen_transition_sleep'].to_f
        sleep(transition_sleep)
      end

      #Reset any active modals in classes underneath
      self.send(self.previous_screen_class).active_modal = nil if self.previous_screen_class

      #Do multiple set current screens if multiple screens
      if self.is_browser?
        self.set_current_screen_multiple(screen_class_symbol, new_window)
        self.wait_for_window_load
        self.wait_for_stable_body_size
      end

      #Before Load Event
      self.send(screen_class_symbol).before_load

      #Set current_screen_class
      self.current_screen_class = screen_class_symbol

      #Emit Screen Change
      self.emit :change_screen, self.translate_class_to_symbol(screen_class_symbol)

      #Possible Automatic Screen Changes
      screen_configuration = self.send(screen_class_symbol).configuration
      return unless screen_configuration.is_a?(Hash)
      return unless screen_configuration['automatic_screen_changes'].is_a?(Array)
      return if screen_configuration.length == 0

      AutomationObject::Logger::add("Adding thread listener for screen #{screen_class_symbol}")
      self.screen_monitor_thread[screen_class_symbol] = Thread.new {
        self.screen_monitor_thread_method(screen_class_symbol)
      }
    end

    def change_screen_listener(screen_class_symbol, created_window_handle = false)
      self.set_current_screen(screen_class_symbol, created_window_handle)

      unless self.current_screen?(screen_class_symbol)
        screen_name = self.translate_class_to_string(screen_class_symbol)
        possible_screen_symbol = self.find_current_screen

        message = "Tried to change screen to (#{screen_name}).
                    (#{screen_name}) did not pass live? configuration test. "

        #If it misses the first time around, no need to error out the screen is should be on anyways
        return if possible_screen_symbol == screen_class_symbol

        if possible_screen_symbol
          possible_screen_name = self.translate_class_to_string(possible_screen_symbol)
          message << "Got (#{possible_screen_name}) screen instead."
        end

        raise message
      end
    end

    def set_current_screen_multiple(screen_class_symbol, new_window = false)
      unless self.current_screen_class
        current_window_handle = self.get_current_window_handle

        self.current_screen_hash[current_window_handle] = screen_class_symbol
        self.screen_history_hash[current_window_handle] = Array.new
        self.screen_history_hash[current_window_handle].push(screen_class_symbol)
        self.send(screen_class_symbol).window_handle = current_window_handle

        return
      end

      switch_to_window_handle = nil

      if new_window
        self.current_screen_hash[new_window] = screen_class_symbol
        self.switch_to_window(new_window)
        self.screen_history_hash[new_window] = Array.new
        self.screen_history_hash[new_window].push(screen_class_symbol)
        self.send(screen_class_symbol).window_handle = new_window

        return
      end

      #Add previous screen to previous screen hash
      if self.current_screen_class and not new_window
        self.current_screen_hash.each { |window_handle, current_screen_symbol|
          if self.current_screen_class == current_screen_symbol
            self.previous_screen_hash[window_handle] = current_screen_symbol
            self.current_screen_hash[window_handle] = screen_class_symbol
            switch_to_window_handle = window_handle

            unless self.screen_history_hash[window_handle].class == Array
              self.screen_history_hash[window_handle] = Array.new
            end

            self.screen_history_hash[window_handle].push(screen_class_symbol)
            self.send(screen_class_symbol).window_handle = window_handle

            break
          end
        }
      end

      #Switch to window handle if set
      if switch_to_window_handle
        return if self.current_screen_hash.keys.length == 1

        if switch_to_window_handle != self.get_current_window_handle
          self.switch_to_window(switch_to_window_handle)
        end
      end
    end
  end
end