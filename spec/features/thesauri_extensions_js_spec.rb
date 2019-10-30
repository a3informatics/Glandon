require 'rails_helper'

describe "Thesauri", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

def editor_table_fill_in(input, text)
    expect(page).to have_css("##{input}", wait: 15)
    fill_in "#{input}", with: "#{text}"
    wait_for_ajax(5)
  end

  def editor_table_click(row, col)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{col}]").click
  end

  describe "The Content Admin User can", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "CDISCTerm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      nv_destroy
      nv_create(parent: "10", child: "999")
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      nv_destroy
      ua_destroy
    end

     #CDISC CL extensible
    it "displays if a CDISC code list is extensible or not (REQ-MDR-CT-080)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      ui_child_search("C99078")
      ui_check_table_cell_extensible('children_table', 1, 5, false)
    end

    it "if a CDISC code list is extensible, extend button enabled (REQ-MDR-EXT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-03-27 Release", :show)
      expect(page).to have_content '2015-03-27 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C96783")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C96783')]/td/a", :text => 'Show').click
      wait_for_ajax
      pause
      expect(page).to have_xpath("//*[@id='extend'][@class='ico-btn-sec ']")      
      click_link 'Extend'
      expect(page).to have_content 'Index: Terminology'
      click_button 'Close'
    end

    it "if a CDISC code list is not extensible, extend button disabled (REQ-MDR-EXT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2014-12-19 Release", :show)
      expect(page).to have_content '2014-12-19 Release'
      ui_check_table_info("children_table", 1, 10, 477)
      expect(page).to have_content 'Extensible'
      ui_child_search("C78737")
      ui_check_table_cell_extensible('children_table', 1, 5, false)
      find(:xpath, "//tr[contains(.,'C78737')]/td/a", :text => 'Show').click
      wait_for_ajax
      expect(page).to have_content("CDISC SDTM Relationship Type Terminology")      
      expect(page).to have_xpath("//*[@id='extend'][@class='ico-btn-sec disabled']")      
    end

    it "Select Terminology Container (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology("Test1", "Test term")
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-10-06 Release", :show)
      wait_for_ajax
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_child_search("C66770")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C66770')]/td/a", :text => 'Show').click
      wait_for_ajax
      click_link 'Extend'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax
      expect(page).to have_content 'Extension'
    end

    it "Select Extension (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology("Test2", "Test term")
      click_navbar_cdisc_terminology
      wait_for_ajax
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-09-26 Release", :show)
      wait_for_ajax
      expect(page).to have_content '2014-09-26 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_child_search("C116110")
      find(:xpath, "//tr[contains(.,'C116110')]/td/a", :text => 'Show').click
      wait_for_ajax
      click_link 'Extend'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax
      expect(page).to have_content 'Extension'
      click_link 'Extension'
      wait_for_ajax
      expect(page).to have_content 'C116110E'
      expect(page).to have_content 'Extending'
    end

    it "Select Extending (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology("Test3", "Test term")
      click_navbar_cdisc_terminology
      wait_for_ajax(7)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      wait_for_ajax
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax
      click_link 'Extend'
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      click_link 'Extension'
      wait_for_ajax
      expect(page).to have_content 'C99079E'
      click_link 'Extending'
      wait_for_ajax
      expect(page).to have_content 'C99079'
      expect(page).to have_content 'Extension'
    end

    it "allow the user to delete an extension to a code list", js:true do
      
    end

  end

end
