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
  homes print spinner tags
 ).each do |filename|
  Rails.application.config.assets.precompile += ["#{filename}.css"]
end

%w(
    dashboard/dashboard_editor dashboard/dashboard_panel dashboard/dashboard dashboard/statistics_panel
    export/start_panel
    import/crfs/new import/terms/new import/show
    iso_managed/iso_managed_comment_edit
    iso_managed/list_change_notes iso_managed/status
    markdown_engines/markdown_editor
    thesauri/changes thesauri/release_select thesauri/search_multiple thesauri/search thesauri/upgrade
    thesauri/managed_concepts/changes thesauri/impact
    thesauri/unmanaged_concepts/changes thesauri/unmanaged_concepts/show

    shared/annotation/change_instruction_edit shared/annotation/change_instructions_html shared/annotation/change_instruction_modal shared/annotation/change_notes_modal
    shared/cdisc_term/cdisc_selector_modal shared/cdisc_term/index_panel
    shared/d3/d3_impact_graph
    shared/import/crf_files_panel shared/import/items_panel
    shared/iso_managed/children_panel shared/iso_managed/comments_panel shared/iso_managed/managed_children_overview
    shared/iso_managed/managed_children_select shared/iso_managed/managed_item_ico_list shared/iso_managed/managed_item_version_picker 
    shared/items_selector/items_selector_modal shared/items_selector/managed_item_selector shared/items_selector/unmanaged_item_selector
    shared/thesauri/changes_panel shared/thesauri/differences_panel shared/thesauri/edit_properties shared/thesauri/links_panel shared/thesauri/new_panel
    shared/thesauri/search_panel shared/thesauri/upgrade_panel
    shared/thesauri/managed_concepts/rank/edit_ranks shared/thesauri/managed_concepts/rank/enable_rank
    shared/thesauri/impact/changes_cdisc_panel shared/thesauri/impact/impact_graph

    shared/alphabetical_filter shared/confirmation_dialog shared/icons_tags_helpers shared/information_dialog
    shared/list_change_notes_panel shared/tabs_layout shared/timer

    ajax_requests colour field_validation
    locked_items rspec_helper sidebar_handler spinner standard_datatable
    token_timer unload_v2 unload

  ).each do |filename|
  Rails.application.config.assets.precompile += ["#{filename}.js"]
end
