require 'rails_helper'

describe "CDISC Terminology", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
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

  describe "Reader Search", :type => :feature do
      
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
      ua_reader_login
    end

    after :all do
      ua_destroy
    end

    it "allows a search to be performed (REQ-MDR-CT-060)", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-09-25 Release')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: Controlled Terminology CT (V44.0.0, 44, Standard)'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      #click_link 'Close'
      #expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "allows a search to be performed - another CDISC version (REQ-MDR-CT-060)", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-12-18 Release')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: Controlled Terminology CT (V45.0.0, 45, Standard)'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
    end

    it "allows a search to be performed, searches (REQ-MDR-CT-060)", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'2015-12-18 Release')]/td/a", :text => 'Search').click
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
  end
end