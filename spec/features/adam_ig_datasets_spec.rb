require 'rails_helper'

describe "ADAM IG Datasets", :type => :feature do

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
      load_data_file_into_triple_store("cdisc/adam_ig/ADAM_IG_V1.ttl")
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
      click_navbar_adam_ig_dataset
      wait_for_ajax 20
      expect(page).to have_content 'Index: ADaM IG Dataset'
      ui_check_table_info("index", 1, 2, 2)
      find(:xpath, "//*[@id='index']/thead/tr/th[2]").click #Order data
      ui_check_table_cell("index", 1, 2, "ADSL")
      ui_check_table_cell("index", 1, 3, "Subject-Level Analysis Dataset")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_adam_ig_dataset
      wait_for_ajax 10
      ui_table_search('index', 'ADSL')
      find(:xpath, "//tr[contains(.,'ADSL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'ADSL\''
      ui_check_table_cell("history", 1, 1, "1.0.0")
      ui_check_table_cell("history", 1, 5, "Subject-Level Analysis Dataset")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_adam_ig_dataset
      wait_for_ajax 10
      ui_table_search('index', 'ADSL')
      find(:xpath, "//tr[contains(.,'ADSL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'ADSL\''
      context_menu_element('history', 4, 'ADSL', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: ADaM IG Dataset'
      ui_check_table_info("show", 1, 10, 63)
      ui_check_table_cell("show", 5, 2, "SITEGRy")
      ui_check_table_cell("show", 5, 3, "Pooled Site Group y")
    end

  end

end
