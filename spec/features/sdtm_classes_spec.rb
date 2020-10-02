require 'rails_helper'

describe "SDTM Classes", :type => :feature do

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
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
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
      click_navbar_sdtm_class
      wait_for_ajax 20
      expect(page).to have_content 'Index: SDTM Classes'
      find(:xpath, "//th[contains(.,'Identifier')]").click # Order
      ui_check_table_info("index", 1, 10, 18)
      ui_check_table_cell("index", 3, 2, "SDTM MODEL EVENTS")
      ui_check_table_cell("index", 3, 3, "SDTM MODEL EVENTS")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_sdtm_class
      wait_for_ajax 10
      ui_table_search('index', 'SDTM MODEL EVENTS')
      find(:xpath, "//tr[contains(.,'SDTM MODEL EVENTS')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL EVENTS\''
      ui_check_table_cell("history", 1, 1, "1.4.0")
      ui_check_table_cell("history", 1, 5, "SDTM MODEL EVENTS")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_sdtm_class
      wait_for_ajax 10
      ui_table_search('index', 'SDTM MODEL EVENTS')
      find(:xpath, "//tr[contains(.,'SDTM MODEL EVENTS')]/td/a", :text => 'History').click
      wait_for_ajax 10
      context_menu_element('history', 4, 'SDTM MODEL EVENTS', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM Class'
      ui_check_table_info("show", 1, 10, 81)
      ui_check_table_cell("show", 5, 2, "--SPID")
      ui_check_table_cell("show", 5, 3, "Sponsor-Defined Identifier")
    end

  end

end
