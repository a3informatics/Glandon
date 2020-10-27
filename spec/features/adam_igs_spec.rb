require 'rails_helper'

describe "ADaM IGs", :type => :feature do

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
      click_navbar_adam_ig
      wait_for_ajax 10
      find(:xpath, "//a[@href='/adam_igs']").click
      expect(page).to have_content 'Index: ADaM IGs'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "ADAM IG")
      ui_check_table_cell("index", 1, 3, "ADaM Implementation Guide")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_adam_ig
      wait_for_ajax 10
      ui_table_search('index', 'ADAM IG')
      find(:xpath, "//tr[contains(.,'ADAM IG')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'ADAM IG\''
      ui_check_table_cell("history", 1, 1, "1.0.0")
      ui_check_table_cell("history", 1, 5, "ADaM Implementation Guide")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_adam_ig
      wait_for_ajax 10
      ui_table_search('index', 'ADAM IG')
      find(:xpath, "//tr[contains(.,'ADAM IG')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'ADAM IG\''
      context_menu_element('history', 4, 'ADAM IG', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: ADaM IG'
      ui_check_table_info("show", 1, 2, 2)
      ui_check_table_cell("show", 1, 1, "BDS")
      ui_check_table_cell("show", 1, 2, "Basic Data Structure")
    end

  end

end
