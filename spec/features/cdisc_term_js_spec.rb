require 'rails_helper'

describe "CDISC Terminology", :type => :feature do
  
  include DataHelpers
  include UiHelpers
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

  describe "Curator Search", :type => :feature do
  
    before :all do
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      #Notepad.destroy_all
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-09-25'
      wait_for_ajax_long 
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    it "allows a search to be performed, searches", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-12-18'
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
      
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    it "allows a search to be performed, code list double click", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-12-18'
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

      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

  end

  describe "Reader Search", :type => :feature do
  
    before :all do
      user = User.create :email => "reader@example.com", :password => "12345678" 
      user.add_role :reader
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      #Notepad.destroy_all
      user = User.where(:email => "reader@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-09-25'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "allows a search to be performed", js: true do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-12-18')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-12-18'
      wait_for_ajax_v_long # Big load
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

  end
end