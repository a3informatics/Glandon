file = Rails.root.to_s + "/config/ontotext.yml"
SEMANTIC_DB_CONFIG = YAML.load_file(file)[Rails.env]
