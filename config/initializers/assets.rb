# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w( colour unload print ajax_requests rspec_helper panel_collapse
  token_timer spinner
  field_validation
  iso_concept_system_viewer 
  iso_concept_graph iso_concept_impact
  iso_managed_comment_edit iso_managed_list iso_managed_tag_edit iso_managed_tag_list 
  iso_managed_graph iso_managed_list_panel iso_managed_select_panel 
  impact_analysis_graph_panel impact_analysis
  cdisc_cross_ref_panel cdisc_cross_ref
  sdtm_user_domain_editor
  domains domains/variables 
  dashboard_viewer dashboard_index 
  ad_hoc_report_results
  markdown_editor
  background_index 
  import_terminology
	biomedical_concepts_editor biomedical_concept_template_new
	thesauri_editor thesauri_viewer thesauri_search_new thesauri_field_editor thesauri_impact
	thesaurus_concept_list_panel
  form_placeholder_new form_editor form_viewer form_show form_utility
  d3_tree d3graph d3_graph d3_editor d3_editor_new
  standard_datatable ).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.js", "#{controller}.css"]
end