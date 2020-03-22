require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Sponsor Terminology", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_all_edit_locks
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      wait_for_ajax
      ua_logoff
    end

    #test of Terminology show and search

    it "allows the index page to be viewed (REQ-MDR-ST-015, REQ-MDR-MIT-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows the history page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    it "history allows the show page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :show)
      wait_for_ajax(10)
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
    end

    it "allows the lower level show pages to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :show)
      wait_for_ajax(10)
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
      find(:xpath, "//tr[contains(.,'VSTEST')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content 'Vital Sign Test Codes Extension'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00003'
      expect(page).to have_content 'A00002'
      find(:xpath, "//tr[contains(.,'MUAC')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content 'Mid upper arm circumference'
      expect(page).to have_content 'A00003'
    end

    it "history allows the search page to be viewed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element('history', 4, 'CDISC Extensions', :search)
      wait_for_ajax(10)
      expect(page).to have_content 'Search Terminology'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'Standard'
      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    it "allows a search to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      wait_for_ajax(10)
      expect(page).to have_content 'Search Terminology'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'Standard'
      wait_for_ajax(5)
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    it "allows a search (overall) within version to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search Terminology'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'Standard'
      wait_for_ajax(5)
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('other')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

    it "allows a search (detailed) within version to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a").click
      wait_for_ajax(10)
      expect(page).to have_content 'Version History of \'CDISC EXT\''
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      wait_for_ajax(10)
      expect(page).to have_content 'Search Terminology'
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'Standard'
      wait_for_ajax(5)
      ui_check_table_info("searchTable", 0, 0, 0)

      ui_term_column_search(:code_list, 'A00001')
      ui_check_table_info("searchTable", 1, 3, 3)

      ui_term_column_search(:notation, 'A')
      ui_check_table_info("searchTable", 1, 2, 2)

      ui_term_column_search(:definition, 'Score')
      ui_check_table_info("searchTable", 1, 1, 1)

      click_button 'clear_button'

      ui_term_column_search(:item, 'A')
      ui_check_table_info("searchTable", 1, 7, 7)

      ui_term_column_search(:notation, 'Ethnic')
      ui_check_table_info("searchTable", 1, 2, 2)

      click_link 'Return'
      expect(page).to have_content 'Version History of \'CDISC EXT\''
    end

  end

end
