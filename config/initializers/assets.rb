# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( iso_concept_systems iso_concept_systems/nodes iso_concept_system_viewer 
  iso_registration_authorities 
  iso_registration_states 
  iso_namespaces 
  iso_concept iso_concept_graph
  iso_managed iso_managed_list iso_managed_tag_edit iso_managed_tag_list iso_managed_graph
  iso_scoped_identifiers 
  sdtm_models sdtm_model_domains sdtm_igs sdtm_ig_domains sdtm_user_domains sdtm_user_domain_editor
  domains domains/variables 
  dashboard dashboard_viewer dashboard_index 
  markdown_editor
  sdtmigs 
  backgrounds background_index notepads users user_settings
	biomedical_concept_templates biomedical_concepts biomedical_concepts_editor 
	cdisc_cls 
  cdisc_clis 
  cdisc_terms cdisc_search
  sponsor_terms 
  thesauri thesauri_editor thesauri_viewer thesauri_search
  thesaurus_concepts 
	forms forms/groups forms/items form_placeholder_new form_editor form_editor_new form_viewer 
  d3local d3_local_v2 d3graph d3_graph d3_editor).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end