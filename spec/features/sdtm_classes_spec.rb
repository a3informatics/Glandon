require 'rails_helper'

describe "SDTM Classes", :type => :feature do

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
      click_navbar_sdtm_class
      wait_for_ajax 20
      expect(page).to have_content 'Index: SDTM Classes'
      find(:xpath, "//th[contains(.,'Identifier')]").click # Order
      ui_check_table_info("index", 1, 7, 7)
      ui_check_table_cell("index", 3, 2, "SDTMMODEL FINDINGS ABOUT")
      ui_check_table_cell("index", 3, 3, "Findings About")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_sdtm_class
      wait_for_ajax 10
      ui_table_search('index', 'SDTMMODEL EVENTS')
      find(:xpath, "//tr[contains(.,'SDTMMODEL EVENTS')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'SDTMMODEL EVENTS\''
      ui_check_table_cell("history", 1, 1, "1.4.0")
      ui_check_table_cell("history", 1, 5, "Events")
      ui_check_table_cell("history", 1, 7, "Standard")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_sdtm_class
      wait_for_ajax 10
      ui_table_search('index', 'SDTMMODEL EVENTS')
      find(:xpath, "//tr[contains(.,'SDTMMODEL EVENTS')]/td/a", :text => 'History').click
      wait_for_ajax 10
      context_menu_element('history', 4, 'SDTMMODEL EVENTS', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM Class'
      ui_check_table_info("show", 1, 10, 85)
      ui_check_table_cell("show", 5, 2, "SPDEVID")
      ui_check_table_cell("show", 5, 3, "Sponsor Device Identifier")
    end

  end

end
