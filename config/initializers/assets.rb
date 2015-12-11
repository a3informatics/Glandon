# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( iso_concept_systems standards domains domains/variables dashboard dashboard_viewer sdtmigs registration_authorities registration_states iso_namespaces 
	biomedical_concept_templates cdisc_bcs cdisc_cls cdisc_clis cdisc_terms sponsor_terms forms scoped_identifiers thesauri thesaurus_concepts cdisc_bcs_editor 
	thesauri_editor thesauri_viewer form_editor form_viewer d3local).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end