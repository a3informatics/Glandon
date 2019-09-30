require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  describe "Sponsor Terminology", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl"]
      load_files(schema_files, data_files)
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_schema_file_into_triple_store("ISO25964.ttl")
      # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      # load_test_file_into_triple_store("iso_namespace_real.ttl")
      # load_test_file_into_triple_store("thesaurus_concept.ttl")
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

    it "allows the index page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows the history page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "history allows the show page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :show)
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
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :show)
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
      find(:xpath, "//tr[contains(.,'VSTEST')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Vital Sign Test Codes Extension'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00003'
      expect(page).to have_content 'A00002'
      find(:xpath, "//tr[contains(.,'MUAC')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Mid upper arm circumference'
      expect(page).to have_content 'A00003'
      #save_and_open_page
    end

    it "history allows the search page to be viewed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #save_and_open_page
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows a search to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #expect(page).to have_button('Notepad+')
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows a search (overall) within version to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #expect(page).to have_button('Notepad+')
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('other')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows a search (detailed) within version to be performed (REQ-MDR-ST-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element("history", 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #expect(page).to have_button('Notepad+')
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
    
      ui_term_column_search(:code_list, 'A00001')
      ui_check_table_info("searchTable", 1, 3, 3)
      
      ui_term_column_search(:notation, 'A')
      ui_check_table_info("searchTable", 1, 2, 2)

      ui_term_column_search(:definition, 'Score')
      ui_check_table_info("searchTable", 1, 1, 1)

      click_button 'clearbutton'
     
      fill_in 'searchTable_csearch_item', with: "A"
      ui_hit_return('searchTable_csearch_item')
      ui_check_table_info("searchTable", 1, 7, 7)

      fill_in 'searchTable_csearch_submission_value', with: "Ethnic"
      ui_hit_return('searchTable_csearch_submission_value')
      ui_check_table_info("searchTable", 1, 2, 2)

      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows a search to be performed on all current versions (REQ-MDR-ST-030)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      click_link 'Search Current'
      expect(page).to have_content 'Search: All Current Terminology'
      wait_for_ajax(5) # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Return'
      expect(page).to have_content 'Index: Terminology'
    end    

    #View option removed
    # it "history allows the view page to be viewed (REQ-MDR-ST-015)", js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: CDISC EXT'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'View').click
    #   expect(page).to have_content 'View: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
    #   click_link 'Close'
    #   expect(page).to have_content 'History: CDISC EXT'
    # end
  
  end

end
