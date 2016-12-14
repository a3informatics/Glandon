# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( colour token print
  iso_concept_system_viewer 
  iso_concept_graph iso_concept_impact
  iso_managed_comment_edit iso_managed_list iso_managed_tag_edit iso_managed_tag_list iso_managed_graph
  sdtm_models sdtm_model_domains sdtm_igs sdtm_ig_domains sdtm_user_domains sdtm_user_domain_editor
  domains domains/variables 
  dashboard_viewer dashboard_index 
  markdown_editor
  sdtmigs 
  backgrounds background_index 
	biomedical_concept_templates biomedical_concepts biomedical_concepts_editor 
	cdisc_search
  thesauri_editor thesauri_viewer thesauri_search
  form_placeholder_new form_editor form_viewer 
  d3_local_v2 d3graph d3_graph d3_editor 
  standard_datatable ).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end