file = Rails.root.to_s + "/config/config.yml"
APP_CONFIG = YAML.load_file(file)[Rails.env]
