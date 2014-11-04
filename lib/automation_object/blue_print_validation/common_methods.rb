module AutomationObject
  module BluePrintValidation
    module CommonMethods
      def get_screens
        screens = Array.new
        return screens unless self.has_key?('screens')
        return screens unless self['screens'].class == Hash

        screens = self['screens'].keys
        return screens
      end

      def screen_exists?(screen_name)
        return self.get_screens.include?(screen_name)
      end

      def view_has_modal?(view_name, modal_name)
        return false unless self.view_exists?(view_name)

        view_configuration = self['views'][view_name]
        return self.get_modals(view_configuration).include?(modal_name)
      end

      def get_view_modals(view_name)
        modals = Array.new
        return modals unless self.has_key?('views')
        return modals unless self['views'].class == Hash
        return modals unless self['views'].has_key?(view_name)

        view_configuration = self['views'][view_name]
        return self.get_modals(view_configuration)
      end

      def screen_has_modal?(screen_name, modal_name)
        return false unless self.screen_exists?(screen_name)

        screen_configuration = self['screens'][screen_name]
        return self.get_modals(screen_configuration).include?(modal_name)
      end

      def get_screen_modals(screen_name)
        modals = Array.new
        return modals unless self.has_key?('screens')
        return modals unless self['screens'].class == Hash
        return modals unless self['screens'].has_key?(screen_name)

        screen_configuration = self['screens'][screen_name]
        return self.get_modals(screen_configuration)
      end

      def get_modals(configuration)
        modals = Array.new

        return modals unless configuration.class == Hash
        return modals unless configuration.has_key?('modals')
        return modals unless configuration['modals'].class == Hash

        modals = configuration['modals'].keys
        return modals
      end

      def screen_has_live?(screen_name)
        return false unless self.screen_exists?(screen_name)

        screen_configuration = self['screens'][screen_name]
        return false unless screen_configuration.class == Hash

        if screen_configuration.has_key?('live?')
          return true if screen_configuration['live?'].class == Hash
          return false
        end

        #Check if has views
        return false unless screen_configuration.has_key?('included_views')
        return false unless screen_configuration['included_views'].class == Array

        #No need to check if views doesn't exit
        return false unless self.has_key?('views')
        return false unless self['views'].class == Hash

        screen_configuration['included_views'].each { |included_view|
          return false unless self['views'].has_key?(included_view)
          return false unless self['views'][included_view].class == Hash

          view_configuration = self['views'][included_view]
          return true if view_configuration.has_key?('live?') and view_configuration['live?'].class == Hash
        }

        return false
      end

      def view_exists?(view_name)
        return self.get_views.include?(view_name)
      end

      def get_views
        views = Array.new
        return views unless self.has_key?('views')
        return views unless self['views'].class == Hash

        views = self['views'].keys
        return views
      end
    end
  end
end