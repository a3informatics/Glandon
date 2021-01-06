require 'rails_helper'

describe "SDTM Sponsor Domains", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
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
      click_navbar_sdtm_sponsor_domain
      wait_for_ajax 10
      expect(page).to have_content 'Index: SDTM Sponsor Domains'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "AAA")
      ui_check_table_cell("index", 1, 3, "SDTM Sponsor Domain")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_sdtm_sponsor_domain
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM Sponsor Domain')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'AAA\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "SDTM Sponsor Domain")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_sdtm_sponsor_domain
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM Sponsor Domain')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'AAA\''
      context_menu_element_v2('history', "SDTM Sponsor Domain", :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM Sponsor Domain'
      ui_check_table_info("show", 1, 10, 41)
      ui_check_table_row("show", 1, [ "1", "STUDYID", "Study Identifier", "Character", "", "Identifier", "Unique identifier for a study.", "Required"])
    end

  end

end
