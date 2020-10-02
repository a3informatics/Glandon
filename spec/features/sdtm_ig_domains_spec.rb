require 'rails_helper'

describe "SDTM IG Domains", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm/SDTM_IG_3-2.ttl"]
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
      click_navbar_ig_domain
      wait_for_ajax 20
      expect(page).to have_content 'Index: SDTM IG Domains'
      ui_check_table_info("index", 1, 10, 41)
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
      context_menu_element('history', 4, 'SDTM IG AE', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: SDTM IG Domain'
      ui_check_table_info("show", 1, 10, 51)
      ui_check_table_cell("show", 5, 2, "AEGRPID")
      ui_check_table_cell("show", 5, 3, "Group ID")
    end

  end

end
