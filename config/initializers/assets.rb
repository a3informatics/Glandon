# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( standards domains domains/variables sdtmigs registration_authorities registration_states namespaces cdisc_bcs cdisc_cls cdisc_terms forms scoped_identifiers thesauri thesaurus_concepts 
	cdisc_bcs_editor thesauri_editor thesauri_viewer form_viewer d3local).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end