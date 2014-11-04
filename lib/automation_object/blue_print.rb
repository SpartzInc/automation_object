module AutomationObject
  class BluePrint < Hash
    #Static
    @@max_folder_depth = 10
    @@base_directory = nil
    @@validate_blueprint = false

    def self.max_folder_depth
      @@max_folder_depth
    end

    def self.max_folder_depth=(value)
      @@max_folder_depth = value
    end

    def self.base_directory
      @@base_directory
    end

    def self.base_directory=(value)
      @@base_directory = value
    end

    def self.validate_blueprint
      @@validate_blueprint
    end

    def self.validate_blueprint=(value)
      @@validate_blueprint = value
    end

    #Instance
    def initialize(path)
      full_path = path
      full_path = File.join(@@base_directory, path) if @@base_directory

      unless File.directory?(full_path)
        raise ArgumentError, "Blue prints directory doesn't exist: #{full_path}"
      end

      @configuration = Hash.new
      self.merge_directory(full_path)

      if @@validate_blueprint
        BluePrintValidation::ValidationObject.new(self)
      end

      self.merge_views
    end

    def merge_directory(path, depth = 0)
      raise ArgumentError, "Folder depth breached max depth of #{@@max_folder_depth}" if depth > @@max_folder_depth

      unless File.directory?(path)
        raise ArgumentError, "Blue print path doesn't exist: #{path}"
      end

      Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        next if item[0] == '.'

        file = File.join(path, "#{item}")
        if File.directory?(file)
          depth = depth + 1
          self.merge_directory("#{path}/#{item}", depth) #call this method again for the subdirectory
          next
        end

        file_configuration = YAML.load_file(file)
        @configuration = @configuration.deep_merge(file_configuration) if file_configuration.class == Hash
      end

      @configuration.each { |key, value|
        self[key] = value
      }
    end

    def merge_views
      return unless self['screens'].is_a?(Hash)
      return unless self['views'].is_a?(Hash)

      self['screens'].each { |screen_name, screen_configuration|
        next unless screen_configuration.is_a?(Hash)
        next unless screen_configuration['included_views'].is_a?(Array)

        screen_configuration['elements'] = Hash.new unless screen_configuration['elements'].class == Hash

        screen_configuration['included_views'].each { |view|
          next unless self['views'][view].is_a?(Hash)
          self['views'][view]['elements'] = Hash.new unless self['views'][view]['elements'].is_a?(Hash)
          screen_configuration = screen_configuration.deep_merge(self['views'][view])
        }

        self['screens'][screen_name] = screen_configuration
      }

      self.delete('views')
    end
  end
end