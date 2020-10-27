require 'rails_helper'

describe "SDTM IGs", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to index page (REQ-MDR-MIT-015)", js:true do
      click_navbar_ig
      wait_for_ajax 10
      find(:xpath, "//a[@href='/sdtm_igs']").click
      expect(page).to have_content 'Index: SDTM IGs'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "SDTM IG")
      ui_check_table_cell("index", 1, 3, "SDTM Implementation Guide")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_ig
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM IG')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM IG\''
      ui_check_table_cell("history", 1, 1, "3.2.0")
      ui_check_table_cell("history", 1, 5, "SDTM Implementation Guide")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_ig
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM IG')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM IG\''
      context_menu_element('history', 4, 'SDTM IG', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM IG'
      ui_check_table_info("show", 1, 10, 48)
      ui_check_table_cell("show", 5, 2, "Tumor/Lesion Results")
      ui_check_table_cell("show", 5, 1, "SDTM IG TR")
    end

  end

end
