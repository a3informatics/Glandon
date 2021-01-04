require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Glandon
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.assets.initialize_on_precompile = false
    config.assets.check_precompiled_asset = false # Needed for Teaspoon.

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # Environment variable extra
    config.before_configuration do
        file = Rails.root.to_s + "/config/local_env.yml"
        YAML.load_file(file)[Rails.env].try :each do |key, value|
            ENV[key.to_s] = value
        end
    end

    # Generic configurations
    config.metadata = config_for(:metadata).deep_symbolize_keys
    config.iso_registration_state = config_for(:iso_registration_state)
    config.roles = config_for(:roles)
    config.policy = config_for(:policy).deep_symbolize_keys
    config.imports = config_for(:imports).deep_symbolize_keys
    config.namespaces = config_for(:namespaces).deep_symbolize_keys
    config.datatypes = config_for(:datatypes).deep_symbolize_keys
    config.dependencies = config_for(:dependencies).deep_symbolize_keys
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Installation specific verisons
    installation_path = "installations/#{ENV["installation"]}"
    config.thesauri = config_for("#{installation_path}/#{:thesauri}").deep_symbolize_keys

    # Rspec additions
    config.generators do |g|
        g.test_framework :rspec,
            fixtures: true,
            view_specs: false,
            helper_specs: false,
            routing_specs: false,
            controller_specs: true,
            request_specs: false
        g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

  end
end
