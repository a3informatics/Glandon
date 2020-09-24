# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
%w(
  concerns/spinner-component
  shared/datatables_loading
  biomedical_concepts_editor
  shared/d3/d3_tree
  homes panel_collapse print spinner tags
 ).each do |filename|
  Rails.application.config.assets.precompile += ["#{filename}.css"]
end

%w(
    ad_hoc_reports/index ad_hoc_reports/results
    backgrounds/index
    biomedical_concepts/bc_template_new
    dashboard/dashboard_editor dashboard/dashboard_panel dashboard/dashboard dashboard/statistics_panel
    export/start_panel
    forms/form_utility forms/form_viewer
    import/crfs/new import/terms/new import/index import/show
    iso_concept_systems/edit_tags iso_concept_systems/index iso_concept_systems/managed_tags_panel_v2
    iso_managed/impact iso_managed/iso_managed_attributes iso_managed/iso_managed_comment_edit iso_managed/iso_managed_select_panel
    iso_managed/list_change_notes iso_managed/status
    markdown_engines/markdown_editor
    sdtm_user_domains/editor
    thesauri/changes thesauri/release_select thesauri/search_multiple thesauri/search thesauri/show thesauri/upgrade
    thesauri/managed_concepts/changes thesauri/managed_concepts/edit_subset
    thesauri/managed_concepts/show
    thesauri/unmanaged_concepts/changes thesauri/unmanaged_concepts/show
    uploads/index

    shared/annotation/change_instruction_edit shared/annotation/change_instructions_html shared/annotation/change_instruction_modal shared/annotation/change_notes_modal
    shared/cdisc_term/cdisc_selector_modal shared/cdisc_term/index_panel
    shared/d3/d3_impact_graph shared/d3/d3_tree_v2 shared/d3/d3_editor_new shared/d3/d3_editor shared/d3/d3_tree
    shared/impact/changes_cdisc_panel shared/impact/impact_graph
    shared/import/crf_files_panel shared/import/items_panel
    shared/iso_concept_systems/concept_system_view_panel_v2 shared/iso_concept_systems/iso_concept_list shared/iso_concept_systems/iso_concept_tagging
    shared/iso_managed/children_panel shared/iso_managed/comments_panel shared/iso_managed/managed_children_overview shared/iso_managed/managed_children_panel
    shared/iso_managed/managed_children_select shared/iso_managed/managed_item_ico_list shared/iso_managed/managed_item_version_picker shared/iso_managed/managed_item_select_modal
    shared/items_selector/items_selector_modal shared/items_selector/managed_item_selector shared/items_selector/unmanaged_item_selector
    shared/thesauri/changes_panel shared/thesauri/differences_panel shared/thesauri/edit_properties shared/thesauri/links_panel shared/thesauri/new_panel
    shared/thesauri/search_panel shared/thesauri/subsets_index shared/thesauri/term_search_modal shared/thesauri/thesauri_select shared/thesauri/upgrade_panel
    shared/thesauri/managed_concepts/edit_extension_panel shared/thesauri/managed_concepts/extension_create shared/thesauri/managed_concepts/new_button
    shared/thesauri/managed_concepts/subset_edit_children_panel shared/thesauri/managed_concepts/subset_source_children_panel
    shared/thesauri/managed_concepts/rank/edit_ranks shared/thesauri/managed_concepts/rank/enable_rank

    shared/alphabetical_filter shared/confirmation_dialog shared/context_menu shared/icons_tags_helpers shared/information_dialog
    shared/list_change_notes_panel shared/show_more shared/tabs_layout shared/timer

    ajax_requests colour field_validation
    locked_items panel_collapse rspec_helper sidebar_handler spinner standard_datatable thesauri_field_editor
    title token_timer unload_v2 unload

  ).each do |filename|
  Rails.application.config.assets.precompile += ["#{filename}.js"]
end
