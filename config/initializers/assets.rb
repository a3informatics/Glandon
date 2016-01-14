# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( iso_concept_systems standards domains domains/variables dashboard dashboard_viewer dashboard_index sdtmigs iso_registration_authorities 
	iso_registration_states iso_namespaces 
	biomedical_concept_templates biomedical_concepts biomedical_concepts_editor 
	cdisc_cls cdisc_clis cdisc_terms sponsor_terms forms iso_scoped_identifiers thesauri thesaurus_concepts 
	thesauri_editor thesauri_viewer form_editor form_viewer d3local).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end