require 'rails_helper'

describe "Scenario 9 - Terminology Release, Clone, Impact and Upgrade", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  include TagHelper
  include NameValueHelpers

  def sub_dir
    return "features/scenarios"
  end

  def click_row_contains(table, text)
    find(:xpath, "//*[@id='#{table}']/tbody/tr[contains(.,'#{text}')]").click
  end

  def change_cdisc_version(version)
    page.find('.card-with-tabs .show-more-btn').click
    sleep 0.5
    ui_dashboard_single_slider version
    click_button 'Submit selected version'
    ui_confirmation_dialog true if page.has_text? "Are you sure you want to proceed?"
    wait_for_ajax 20
  end

  def editor_table_fill_in(input, text)
    expect(page).to have_css("##{input}", wait: 15)
    fill_in "#{input}", with: "#{text}"
    wait_for_ajax(5)
  end

  def editor_table_click(row, col)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{col}]").click
  end

  def in_modal
    sleep 0.7
    yield
    sleep 0.7
  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      Token.destroy_all
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "Prepares a tag, system admin", scenario: true, js: true do
      ua_sys_and_content_admin_login
      click_navbar_tags
      fill_in 'add_label', with: 'TstTag'
      fill_in 'add_description', with: 'Tag for Test'
      click_on 'Create tag'
      wait_for_ajax 10
      ua_logoff
    end

    it "Terminology Release, Clone, Impact and Upgrade", scenario: true, js: true do
      ua_curator_login

      # Create Thesaurus
      ui_create_terminology("TST", "Test Terminology")

      # Edit Thesaurus, set reference
      click_navbar_terminology
      wait_for_ajax 10
      click_row_contains("main", "Test Terminology")
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10
      change_cdisc_version "2017-09-29"
      click_link "Return"
      wait_for_ajax 10

      # Create an Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "52.0.0", :show)
      wait_for_ajax 10
      context_menu_element_header(:extend)
      in_modal do
        click_row_contains("thTable", "TST")
        click_on "Select"
      end
      wait_for_ajax 10

      # Edit Extension, Add items
      click_on "Add items"
      in_modal do
        click_row_contains("index", "CDISC")
        wait_for_ajax 10
        click_row_contains("history", "2017-09-29")
        click_on "Submit and proceed"
      end
      in_modal do
        find(:xpath, '//*[@id="searchTable_csearch_cl"]').set "C10"
        find(:xpath, '//*[@id="searchTable_csearch_cl"]').native.send_keys :return
        wait_for_ajax 30
        find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
        find(:xpath, "//*[@id='searchTable_paginate']/ul/li[3]/a").click
        wait_for_ajax 30
        find(:xpath, "//*[@id='searchTable']/tbody/tr[1]").click
        click_button 'Add items'
      end
      wait_for_ajax 10

      # Edit Extension, Add a tag
      w = window_opened_by { context_menu_element_header(:edit_tags) }
      within_window w do
        wait_for_ajax 5
        ui_click_node_name ("TstTag")
        wait_for_ajax 5
        click_button "Add Tag"
        wait_for_ajax 10
      end
      w.close
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Extension Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10

      # Create a Subset
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Anatomical")
      find(:xpath, "//tr[contains(.,'CDISC')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "60.0.0", :show)
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      in_modal do
        click_on "+ New subset"
      end
      in_modal do
        click_on "Do not select"
      end
      wait_for_ajax 20

      # Edit Subset - Add items
      click_row_contains("source_children_table", "ABDOMINAL CAVITY")
      wait_for_ajax 10
      click_row_contains("source_children_table", "C139186")
      wait_for_ajax 10

      # Edit Subset - Update properties
      context_menu_element_header(:edit_properties)
      in_modal do
        fill_in "preferred_term", with: "Anatomical Location Subset 1"
        fill_in "notation", with: "ANATOMICAL LOC SUBSET"
        fill_in "synonym", with: "Synonym1; And Number 2"
        click_button "Save changes"
      end
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Subset Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10


      # New Code List
      click_navbar_code_lists
      wait_for_ajax 20
      cl_identifier = ui_new_code_list
      context_menu_element('history', 4, cl_identifier, :edit)
      wait_for_ajax 10
      click_button 'New'
      wait_for_ajax 10
      editor_table_click(1,2)
      editor_table_fill_in "DTE_Field_notation", "SPONSOR CL\t"
      editor_table_fill_in "DTE_Field_preferred_term", "Some Sponsor Code List\n"
      editor_table_click(1,5)
      editor_table_fill_in "DTE_Field_definition", "And of course, a definition\n"
      wait_for_ajax 5
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make CL Standard, Add Version Label
      context_menu_element_v2("history", "0.1.0", :document_control)

      page.find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard Version Label'
      page.find('#version-label-submit').click

      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"

      click_link "Return"
      wait_for_ajax 10

      # Create a Subset of a Sponsor Extension
      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "Epoch")
      find(:xpath, "//tr[contains(.,'ACME')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :show)
      wait_for_ajax 10
      context_menu_element_header(:subsets)
      in_modal do
        click_on "+ New subset"
      end
      in_modal do
        click_on "Do not select"
      end
      wait_for_ajax 20

      # Edit Subset - Add items
      click_row_contains("source_children_table", "AIMS")
      wait_for_ajax 10
      click_row_contains("source_children_table", "Baseline Epoch")
      wait_for_ajax 10
      click_row_contains("source_children_table", "C99158")
      wait_for_ajax 10

      # Edit Subset - Update properties
      context_menu_element_header(:edit_properties)
      in_modal do
        fill_in "notation", with: "SPONSOR SUBSET"
        click_button "Save changes"
      end
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Subset Standard
      context_menu_element_v2("history", "0.1.0", :document_control)
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_link "Return"
      wait_for_ajax 10

      # Edit Thesaurus, add items
      click_navbar_terminology
      wait_for_ajax 10
      click_row_contains("main", "Test Terminology")
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 20
      click_row_contains("table-cdisc-cls", "Epoch")
      wait_for_ajax 10
      click_row_contains("table-cdisc-cls", "C99073")
      wait_for_ajax 10
      ui_click_tab "Sponsor CLs"
      wait_for_ajax 10
      click_row_contains("table-sponsor-cls", cl_identifier)
      wait_for_ajax 10
      ui_click_tab "Sponsor Subsets"
      wait_for_ajax 10
      page.find("#table-sponsor-subsets-bulk-select").click
      wait_for_ajax 10
      click_link "Return"
      wait_for_ajax 10

      # Document Control, Make Thesaurus Standard
      context_menu_element_v2("history", "0.1.0", :document_control)

      page.find('#version-label-edit').click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard Test TH'
      page.find('#version-label-submit').click

      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"
      click_on "Submit Status Change"

      click_link "Return"
      wait_for_ajax 10

      # Clone Thesaurus
      context_menu_element('history', 8, 'Standard Test TH', :clone)
      in_modal do
        fill_in 'thesauri_identifier', with: "CLONE"
        fill_in 'thesauri_label', with: "Cloned Terminology"
        click_button 'Submit'
      end

      # Change CDISC Reference
      click_navbar_terminology
      wait_for_ajax 10
      click_row_contains("main", "Cloned Terminology")
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 20
      change_cdisc_version("2019-12-20")

      # Upgrade Terms
      context_menu_element_header :upgrade
      wait_for_ajax 20
      expect(page).to have_content("Upgrade Code Lists CLONE v0.1.0")
      pause

      click_row_contains("changes_cdisc_table", "Epoch")
      wait_for_ajax 20


      ua_logoff
    end

  end

end
