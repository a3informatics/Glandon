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
      wait_for_ajax
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
      click_on "Add items"
      in_modal do
        click_row_contains("index", "CDISC")
        wait_for_ajax 10
        click_row_contains("history", "2017-09-29")
        click_on "Submit and proceed"
      end
      in_modal do
        find(:xpath, '//*[@id="searchTable_csearch_cl"]').set "C10"
        input.native.send_keys :return
        wait_for_ajax 30
        find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
        find(:xpath, "//*[@id='searchTable']/ul/li[3]/a").click
        wait_for_ajax 30
        find(:xpath, "//*[@id='searchTable']/tbody/tr[1]").click
        click_button 'Add items'
      end
      pause

      ua_logoff
    end

  end

end
