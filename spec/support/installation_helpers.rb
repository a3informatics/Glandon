module InstallationHelpers

  def select_installation(item, installation)
     content = YAML.load_file(Rails.root.join "config/installations/#{installation}/#{item}.yml").deep_symbolize_keys
     Rails.configuration.thesauri = content[Rails.env.to_sym]
  end

  def restore_installation(item)
     content = YAML.load_file(Rails.root.join "config/installations/test/#{item}.yml").deep_symbolize_keys
     Rails.configuration.thesauri = content[Rails.env.to_sym]
  end

end