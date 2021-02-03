require 'rails_helper'

describe "SDTM IG Domains", :type => :feature do

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
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
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
      click_navbar_ig_domain
      wait_for_ajax 20
      expect(page).to have_content 'Index: SDTM IG Domains'
      ui_check_table_info("index", 1, 10, 48)
      find(:xpath, "//th[contains(.,'Identifier')]").click # Order
      ui_check_table_cell("index", 1, 2, "SDTM IG AE")
      ui_check_table_cell("index", 1, 3, "Adverse Events")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_ig_domain
      wait_for_ajax 10
      ui_table_search('index', 'SDTM IG AE')
      find(:xpath, "//tr[contains(.,'SDTM IG AE')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM IG AE\''
      ui_check_table_cell("history", 1, 1, "3.2.0")
      ui_check_table_cell("history", 1, 5, "Adverse Events")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_ig_domain
      wait_for_ajax 10
      ui_table_search('index', 'SDTM IG AE')
      find(:xpath, "//tr[contains(.,'SDTM IG AE')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM IG AE\''
      context_menu_element('history', 1, '3.2.0', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM IG Domain'
      ui_check_table_info("show", 1, 10, 51)
      ui_check_table_cell("show", 2, 2, "DOMAIN")
      ui_check_table_cell("show", 2, 6, "(DOMAIN)")
      ui_check_table_cell("show", 2, 7, "http://www.cdisc.org/C66734/V28#C66734")
      ui_check_table_cell("show", 5, 2, "AEGRPID")
      ui_check_table_cell("show", 5, 3, "Group ID")
    end

  end

end
