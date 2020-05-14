require 'rails_helper'

describe "Thesauri Clone", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include UiHelpers

  before :all do
    load_files(schema_files, [])
    load_cdisc_term_versions(1..62)
    load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")

    ua_create
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  after :all do
    ua_destroy
  end

  describe "Clone Terminology", :type => :feature do

    it "allows to clone a sponsor terminology", js: true do
      click_navbar_terminology
      wait_for_ajax 10
      expect(page).to have_content "Index: Terminology"
      find(:xpath, "//tr[contains(.,'2019 Release 1')]/td/a").click
      wait_for_ajax 20
      expect(page).to have_content 'Version History of \'2019 R1\''
      Capybara.ignore_hidden_elements = false
      expect(page).to have_link("Clone")
      Capybara.ignore_hidden_elements = true
      context_menu_element('history', 8, '2019 Release 1', :clone)
      sleep 1
      expect(page).to have_content "Clone Terminology"
      fill_in 'thesauri_identifier', with: "CLONETERM"
      fill_in 'thesauri_label', with: "Cloned Terminology"
      click_button 'Submit'
      sleep 1
      expect(page).to have_content "Terminology was successfully cloned"
      find(:xpath, "//tr[contains(.,'Cloned Terminology')]/td/a").click
      wait_for_ajax 20
      expect(page).to have_content 'Version History of \'CLONETERM\''
      context_menu_element('history', 8, 'CLONETERM', :show)
      wait_for_ajax 20
      expect(page).to have_content 'Cloned Terminology'
      expect(page).to have_content '0.1.0' 
      ui_check_table_info("children_table", 1, 10, 803)
      ui_check_table_cell("children_table", 2, 2, "UNIT_05")
    end

    it "does not allow to special characters in a cloned terminology", js: true do
      click_navbar_terminology
      wait_for_ajax 10
      expect(page).to have_content "Index: Terminology"
      find(:xpath, "//tr[contains(.,'2019 Release 1')]/td/a").click
      wait_for_ajax 20
      expect(page).to have_content 'Version History of \'2019 R1\''
      Capybara.ignore_hidden_elements = false
      expect(page).to have_link("Clone")
      Capybara.ignore_hidden_elements = true
      context_menu_element('history', 8, '2019 R1', :clone)
      sleep 1
      expect(page).to have_content "Clone Terminology"
      fill_in 'thesauri_identifier', with: "!€&(=!)"
      fill_in 'thesauri_label', with: "Wrong Terminology !€%/{)}"
      click_button 'Submit'
      sleep 1
      expect(page).to have_content "Label contains invalid characters and Has identifier: Identifier contains invalid characters"
    end

    it "does not allow to clone a non-owned terminology", js: true do
      click_navbar_cdisc_terminology
      wait_for_ajax 20
      Capybara.ignore_hidden_elements = false
      expect(page).to_not have_link("Clone")
      Capybara.ignore_hidden_elements = true
    end

  end

end
