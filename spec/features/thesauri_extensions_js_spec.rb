require 'rails_helper'

describe "Thesauri", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  describe "The Content Admin User can", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "CDISCTerm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "10")
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
      Thesaurus.create({:identifier => "TEST", :label => "Test Label"})
      Token.delete_all
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

     #CDISC CL extensible
    it "displays if a CDISC code list is extensible or not (REQ-MDR-CT-080)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      ui_child_search("C99078")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, false)
    end

    it "if a CDISC code list is extensible, extend button enabled (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2015-03-27 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2015-03-27 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C96783")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C96783')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      click_link 'Extend'
      wait_for_ajax(10)
      click_button 'Close'
      wait_for_ajax(10)
    end

    it "if a CDISC code list is not extensible, extend button disabled (REQ-MDR-EXT-040)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-12-19 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2014-12-19 Release'
      ui_check_table_info("children_table", 1, 10, 477)
      expect(page).to have_content 'Extensible'
      ui_child_search("C78737")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, false)
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      expect(page).to have_content("CDISC SDTM Relationship Type Terminology")
      expect(page).to have_xpath("//*[@id='extend'][@class='ico-btn-sec disabled']")
    end

    it "Select Terminology Container (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-10-06 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_child_search("C66770")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C66770')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      wait_for_ajax(10)
      click_button 'Select'
      wait_for_ajax(10)
      expect(page).to have_content 'Extension'
    end

    it "Select Extension (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2014-09-26 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_child_search("C96783")
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'C96783')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]").click
      wait_for_ajax(10)
      click_button 'Select'
      wait_for_ajax(10)
      expect(page).to have_content 'Extension'
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C96783E'
      expect(page).to have_content 'Extending'
    end

    it "Select Extending (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(10)
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]").click
      wait_for_ajax(10)
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(120)
      expect(page).to have_content 'C99079E'
      click_link 'Extending'
      wait_for_ajax(120)
      expect(page).to have_content 'C99079'
      expect(page).to have_content 'Extension'
    end

    it "Add Code List Item to Extension (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      wait_for_ajax(10)
      ui_child_search("C99075")
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C99075')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C99075E'
      ui_check_table_info("children_table", 1, 6, 6)
      click_link 'Add'
      wait_for_ajax(120)
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C100129")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      click_button 'Add terms'
      wait_for_ajax(10)
      ui_check_table_info("children_table", 1, 7, 7)
    end

    it "Add two Code List Items to Extension (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      ui_child_search("C116110")
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C116110')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C116110E'
      ui_check_table_info("children_table", 1, 9, 9)
      click_link 'Add'
      wait_for_ajax(120)
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C100129")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[5]").click
      click_button 'Add terms'
      ui_check_table_info("children_table", 1, 10, 11)
    end

    it "Add 3 Code List Items to Extension (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      ui_child_search("C99073")
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C99073')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C99073E'
      ui_check_table_info("children_table", 1, 7, 7)
      click_link 'Add'
      wait_for_ajax(120)
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C100129")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[3]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      find(:xpath, "//*[@id='searchTable_paginate']/ul/li[3]/a").click
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[2]").click
      click_button 'Add terms'
      ui_check_table_info("children_table", 1, 10, 10)
    end

    it "not allows to add a Code List to Extension (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      ui_child_search("C96785")
      wait_for_ajax(120)
      find(:xpath, "//tr[contains(.,'C96785')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C96785E'
      ui_check_table_info("children_table", 1, 10, 11)
      click_link 'Add'
      wait_for_ajax(120)
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C1")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[1]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[2]").click
      click_button 'Add terms'
      ui_check_table_info("children_table", 1, 10, 11)
    end

    it "allows the user to delete a code list item from extension", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      wait_for_ajax(120)
      ui_child_search("C99076")
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'C99076')]/td/a", :text => 'Show').click
      wait_for_ajax(120)
      click_link 'Extend'
      wait_for_ajax(120)
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax(10)
      click_link 'Extension'
      wait_for_ajax(10)
      expect(page).to have_content 'C99076E'
      ui_check_table_info("children_table", 1, 4, 4)
      click_link 'Add'
      wait_for_ajax(120)
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C1")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[5]").click
      click_button 'Add terms'
      ui_check_table_info("children_table", 1, 6, 6)
      find(:xpath, "//*[@id='children_table']/tbody/tr[6]/td[8]/button", :text => 'Delete').click
      wait_for_ajax(10)
      ui_check_table_info("children_table", 1, 5, 5)
    end

  end

end
