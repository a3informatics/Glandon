require 'rails_helper'

describe "CDISC Terminology", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features"
  end

  def wait_for_ajax_long
    wait_for_ajax(15)
  end

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  def wait_for_ajax_short
    wait_for_ajax(7)
  end

  describe "Curator Search", :type => :feature do
  
    before :all do
      clear_triple_store
      ua_create
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      
      load_cdisc_term_versions(1..45)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "allows a search to be performed (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2014-12-19 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V41.0.0, 41, Standard)'
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Return'
      expect(page).to have_content 'History: CT'
    end

    it "allows a search to be performed, searches (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)

      ui_term_column_search(:code_list, 'C100129')
      ui_check_table_info("searchTable", 1, 10, 142)
      
      ui_term_column_search(:definition, 'Hamilton')
      ui_check_table_info("searchTable", 1, 3, 3)
      
      ui_term_column_search(:notation, 'ADMINISTRATION')
      ui_check_table_info("searchTable", 1, 2, 2)
      
      fill_in 'searchTable_csearch_submission_value', with: 'A' # In effect delete all bar one character
      ui_hit_backspace('searchTable_csearch_submission_value') # Delete last character so now empty
      wait_for_ajax_long
      ui_check_table_info("searchTable", 1, 3, 3)
      
      fill_in 'searchTable_csearch_definition', with: 'H'
      ui_hit_backspace('searchTable_csearch_definition')
      wait_for_ajax_long
      ui_check_table_info("searchTable", 1, 10, 142)
      
      ui_term_overall_search('Hamilton')
      ui_check_table_info("searchTable", 1, 3, 3)
      
      input = find(:xpath, '//*[@id="searchTable_filter"]/label/input')
      input.set('H')
      input.native.send_keys(:backspace)
      wait_for_ajax_long
      ui_check_table_info("searchTable", 1, 10, 142)
      
      link = find(:xpath, '//*[@id="searchTable_paginate"]/ul/li[3]/a')
      link.click
      wait_for_ajax_long
      ui_check_table_info("searchTable", 11, 20, 142)
      
      link = find(:xpath, '//*[@id="searchTable_paginate"]/ul/li[4]/a')
      link.click
      wait_for_ajax_long
      ui_check_table_info("searchTable", 21, 30, 142)
      
      link = find(:xpath, '//*[@id="searchTable_previous"]/a')
      link.click
      wait_for_ajax_long
      ui_check_table_info("searchTable", 11, 20, 142)
      
      link = find(:xpath, '//*[@id="searchTable_next"]/a')
      link.click
      wait_for_ajax_long
      ui_check_table_info("searchTable", 21, 30, 142)
    end

    it "allows a search to be performed, code list double click (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)

      ui_term_overall_search('race')
      ui_check_table_info("searchTable", 1, 10, 35)

      ui_term_column_search(:notation, 'RACE')
      ui_check_table_info("searchTable", 1, 10, 11)

      ui_table_row_double_click('searchTable', 'CDISC SDTM Race Terminology')
      wait_for_ajax_short
			ui_check_table_info("searchTable", 1, 6, 6)

			ui_term_column_search(:definition, 'the')
      ui_check_table_info("searchTable", 1, 5, 5)
      
			ui_term_column_search(:notation, 'RACE')
			expect(page).to have_content 'Showing 1 to 1 of 1 entries'

      ui_table_row_double_click('searchTable', 'CDISC SDTM Race Terminology')
			wait_for_ajax_short
      ui_check_table_info("searchTable", 1, 6, 6)
    end

    it "clearing overall search input (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('race')
      ui_check_table_info("searchTable", 1, 10, 35)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 10 of 35 entries'
      expect(find('#searchTable_filter input')).to have_content('')
    end

    it "clearing column search inputs with one input (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:notation, 'NOT DONE')
      ui_check_table_info("searchTable", 1, 1, 1)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 1 of 1 entries'
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
    end

    it "searching for same value after clearing overall search input (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 10, 11)
      click_button 'clearbutton'
      ui_term_column_search(:notation, 'm2')
      ui_check_table_info("searchTable", 1, 10, 234)
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_button 'clearbutton'
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 10, 11)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 10 of 11 entries'
      expect(find('#searchTable_filter input')).to have_content('')
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
    end

    it "searching for same value after clearing overall search input in another date (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-09-25 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V44.0.0, 44, Standard)'
      wait_for_ajax_long 
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 10, 11)
      click_button 'clearbutton'
      ui_term_column_search(:notation, 'm2')
      ui_check_table_info("searchTable", 1, 10, 231)
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 2, 2)
      click_button 'clearbutton'
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 10, 11)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 10 of 11 entries'
      expect(find('#searchTable_filter input')).to have_content('')
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
    end


    it "clearing column search inputs with more inputs (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_column_search(:notation, 'bpi')
      ui_check_table_info("searchTable", 1, 10, 177)
      ui_term_column_search(:definition, 'surgery')
      ui_check_table_info("searchTable", 1, 4, 4)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 4 of 4 entries'
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
      expect(find('#searchTable_csearch_definition')).to have_content('')
    end


    it "clearing both overall search input and all column search input (REQ-MDR-CT-060)", js: true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History: CDISC Terminology'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-12-18 Release", :search)
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      ui_term_overall_search('inches')
      ui_check_table_info("searchTable", 1, 10, 11)
      ui_term_column_search(:notation, 'ft2')
      ui_check_table_info("searchTable", 1, 1, 1)
      click_button 'clearbutton'
      expect(page).to have_content 'Showing 1 to 1 of 1 entries'
      expect(find('#searchTable_filter input')).to have_content('')
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
    end

  end

end