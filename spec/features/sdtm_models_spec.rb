require 'rails_helper'

describe "SDTM Models", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm/SDTM_Model_1-4.ttl"]
      load_files(schema_files, data_files)
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
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//a[@href='/sdtm_models']").click
      expect(page).to have_content 'Index: SDTM Models'
      ui_check_table_info("index", 1, 1, 1)
      ui_check_table_cell("index", 1, 2, "SDTM MODEL")
      ui_check_table_cell("index", 1, 3, "SDTM Model 2013-11-26")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM MODEL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL\''
      ui_check_table_cell("history", 1, 1, "1.4.0")
      ui_check_table_cell("history", 1, 5, "SDTM Model 2013-11-26")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_sdtm_model
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'SDTM MODEL')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTM MODEL\''
      context_menu_element('history', 4, 'SDTM MODEL', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: CDISC SDTM Model'
      ui_check_table_info("show", 1, 7, 7)
      ui_check_table_cell("show", 5, 2, "Findings About")
      ui_check_table_cell("show", 5, 1, "SDTMMODEL FINDINGS ABOUT")
    end

  end

end
