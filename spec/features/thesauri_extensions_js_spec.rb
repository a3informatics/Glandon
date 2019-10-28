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
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      click_link 'Extend'
      click_button 'Close'
    end

    it "if a CDISC code list is not extensible, extend button disabled (REQ-MDR-EXT-040)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99077")
      ui_check_table_cell_extensible('children_table', 1, 5, false)
      # click_link 'Show'
      find(:xpath, "//tr[contains(.,'C99077')]/td/a", :text => 'Show').click
      expect(page).to have_xpath("//*[@id='extend'][@class='ico-btn-sec disabled']")      
    end

    it "Select Terminology (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      wait_for_ajax_v_long
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax_v_long
      click_link 'Extend'
      wait_for_ajax_v_long
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax_v_long
      expect(page).to have_content 'Extension'
    end

    it "Select Extension (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2015-09-25 Release", :show)
      expect(page).to have_content '2015-09-25 Release'
      ui_check_table_info("children_table", 1, 10, 463)
      ui_child_search("C99079")
      wait_for_ajax_v_long
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax_v_long
      click_link 'Extend'
      wait_for_ajax_v_long 
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      wait_for_ajax_v_long
      expect(page).to have_content 'Extension'
      click_link 'Extension'
      wait_for_ajax_v_long
      expect(page).to have_content 'C99079E'
      expect(page).to have_content 'Extending'
    end

    it "Select Extending (REQ-MDR-EXT-010)", js:true do
      ui_create_terminology
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2015-06-26 Release", :show)
      expect(page).to have_content '2015-06-26 Release'
      ui_check_table_info("children_table", 1, 10, 504)
      expect(page).to have_content 'Extensible'
      ui_child_search("C99079")
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      click_link 'Extend'
      find(:xpath, "//*[@id='thTable']/tbody/tr[1]/td[1]").click
      click_button 'Select'
      click_link 'Extension'
      expect(page).to have_content 'C99079E'
      click_link 'Extending'
      expect(page).to have_content 'C99079'
      expect(page).to have_content 'Extension'
    end

    it "allow the user to delete an extension to a code list", js:true do
      
    end

  end

end
