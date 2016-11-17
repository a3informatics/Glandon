module UserSettings
  
  # Simple Setting Moduel

  extend ActiveSupport::Concern

  # Constants
  C_CLASS_NAME = "UserSettings"

  # Include for the user class. Sets up the properties. Defined within a configuration file.
  # This could be made better such that config parameters do not need to be 'known' but it 
  # will do for now
  included do
    has_many :user_settings
    # User settings
    hash = APP_CONFIG['paper_size'][0]
    values = hash['enum_values']
    enum_values = values.split
    @@settings_metadata = {:paper_size => {:type => hash['type'], :enum_values => enum_values, :label => hash['label']}}
    @@settings = {:paper_size => hash['value']}
  end

  # Add class methods
  module ClassMethods
  
    # Allows a setting to have the default value set  
    def setting(name, default)
      settings = self.class_variable_get(:'@@settings')
      settings[name] = default
      self.class_variable_set(:'@@settings', settings)
    end
  
  end

  # Return the settings
  #
  # @return [hash] Hash of the setting values
  def settings
    results = Hash.new
    @@settings_metadata.each do |key, setting|
      result = read_setting(key)
      results[key] = result.value
    end  
    return results
  end

  # Return the settings metadata
  #
  # @return [hash] Hash of the setting metadata
  def settings_metadata
    return @@settings_metadata
  end

  # Read a setting
  #
  # @param [string] 
  # @return [hash] The setting value or nil
  def read_setting(name)
    if p = self.user_settings.where(:name => name).first
      return p
    end
    return self.user_settings.new(:name => name, :value => @@settings[name]) if @@settings.has_key?(name)
    nil
  end

  # Write a setting
  #
  # @param name [string] The setting's name
  # @param value [string] the setting's value
  def write_setting(name, value)
    p = self.user_settings.where(name: name).first_or_create
    p.update(value: value)
  end

  # Handle missing method. Attempt to read or write the setting, otherwise will fail
  def method_missing(method, *args)
    if @@settings.keys.any?{|k| method =~ /#{k}/}
      if method =~ /=/
        self.write_setting(method.gsub('=', ''), *args)
      else
        p = self.read_setting(method)
        return p.value
      end
    else
      super
    end
  end
end