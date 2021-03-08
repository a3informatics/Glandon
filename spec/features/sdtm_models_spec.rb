require 'rails_helper'

describe "SDTM Models", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  def sub_dir 
    "features/sdtm_models"
  end 

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

    it "allows access to index page (REQ-MDR-MIT-015)" do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//a[@href='/sdtm_models']").click
      expect(page).to have_content 'Index: SDTM Models'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "SDTM MODEL")
      ui_check_table_cell("index", 1, 3, "SDTM Model")
    end

    it "allows the history page to be viewed" do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM MODEL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL\''
      ui_check_table_cell("history", 1, 1, "1.4.0")
      ui_check_table_cell("history", 1, 5, "SDTM Model")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)" do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM MODEL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL\''
      context_menu_element('history', 4, 'SDTM MODEL', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: CDISC SDTM Model'
      ui_check_table_info("show", 1, 10, 20)
      ui_check_table_cell("show", 5, 2, "TE")
      ui_check_table_cell("show", 5, 1, "SDTM MODEL TE")
    end

    it "show page allows to export SDTM IG Domain as CSV" do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM MODEL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL\''
      context_menu_element('history', 4, 'SDTM MODEL', :show)
      wait_for_ajax 10
      click_on 'CSV'

      file = download_content
      check_file_actual_expected(file, sub_dir, "sdtm_model_csv_expected.csv")
    end

  end

end
