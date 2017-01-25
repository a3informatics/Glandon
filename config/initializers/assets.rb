# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( colour unload print ajax_requests rspec_helper 
  token_timer
  field_validation
  iso_concept_system_viewer 
  iso_concept_graph iso_concept_impact
  iso_managed_comment_edit iso_managed_list iso_managed_tag_edit iso_managed_tag_list iso_managed_graph
  sdtm_user_domain_editor
  domains domains/variables 
  dashboard_viewer dashboard_index 
  ad_hoc_report_results
  markdown_editor
  background_index 
	biomedical_concepts_editor 
	cdisc_search
  thesauri_editor thesauri_viewer thesauri_search_new
  form_placeholder_new form_editor form_viewer form_show form_utility
  d3_tree d3graph d3_graph d3_editor 
  standard_datatable ).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end