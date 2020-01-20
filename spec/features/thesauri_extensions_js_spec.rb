require 'rails_helper'

describe "Thesauri Extensions", :type => :feature do

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
      Token.delete_all
      Token.restore_timeout
    end

    # Goes to the edit page of the extension - extension must exist beforehand
    def go_to_edit_extension(identifier)
      click_navbar_code_lists
      wait_for_ajax(120)
      ui_table_search("index", identifier)
      ui_check_table_row_indicators("index", 1, 4, ["extension"])
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 8, identifier, :edit)
      wait_for_ajax(20)
      expect(page).to have_content("Edit Extension")
      expect(page).to have_content(identifier)
    end

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
      #wait_for_ajax(10)
      ui_check_table_cell_extensible('children_table', 1, 5, true)
      find(:xpath, "//tr[contains(.,'C96783')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      context_menu_element_header(:extend)
      sleep 1
      expect(page).to have_content("Pick a Terminology")
      click_button 'Close'
      sleep 1
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
      #expect(page).to have_xpath("//*[@id='extend'][@class='ico-btn-sec disabled']")
      expect(context_menu_element_header_present?(:extend, "disabled")).to eq(true)
    end

    it "Create Extension, Terminology container (REQ-MDR-EXT-010)", js:true do
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
      context_menu_element_header(:extend)
      sleep 1.5
      page.find("#select_th")[:class].include?("disabled")
      find(:xpath, "//*[@id='thTable']/tbody/tr[contains(.,'TEST')]").click
      find(:xpath, "//*[@id='thTable']/tbody/tr[contains(.,'TEST')]")[:class].include?("selected")
      expect(page.find("#select_th")[:class]).not_to include("disabled")
      click_button 'Select'
      wait_for_ajax(10)
      expect(page).to have_content("Edit Extension")
      expect(page).to have_content("C66770E")
    end

    it "Show Extension, Extending buttons and links (REQ-MDR-EXT-010)", js:true do
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
      context_menu_element_header(:extension)
      wait_for_ajax(10)
      expect(page).to have_content 'C66770E'
      expect(context_menu_element_header_present?(:extending)).to eq(true)
      context_menu_element_header(:extending)
      wait_for_ajax(10)
      expect(page).to have_content 'C66770'
      expect(context_menu_element_header_present?(:extension)).to eq(true)
    end

    it "Create Extension, no Terminology container (REQ-MDR-EXT-???)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(10)
      expect(page).to have_content 'History'
      context_menu_element("history", 5, "2014-10-06 Release", :show)
      wait_for_ajax(10)
      expect(page).to have_content '2014-10-06 Release'
      ui_check_table_info("children_table", 1, 10, 446)
      ui_check_table_cell_extensible('children_table', 8, 5, true)
      find(:xpath, "//tr[contains(.,'C96785')]/td/a", :text => 'Show').click
      wait_for_ajax(10)
      context_menu_element_header(:extend)
      sleep 1.5
      click_button 'Do not select'
      wait_for_ajax(10)
      expect(page).to have_content("Edit Extension")
      expect(page).to have_content("C96785E")
    end

    it "Add one or more existing Code List Items to Extension (REQ-MDR-EXT-010)", js:true do
      go_to_edit_extension "C66770E"
      expect(page).to have_content("CDISC SDTM Unit for Vital Sign Result Terminology")
      ui_check_table_info("extension-children-table", 1, 10, 15)
      click_link 'Add items'
      sleep 1
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C100129")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      click_button 'Add items'
      wait_for_ajax(10)
      sleep 1
      ui_check_table_info("extension-children-table", 1, 10, 16)
      find(:xpath, "//*[@id='extension-children-table_paginate']/ul/li[3]/a").click
      ui_check_table_cell("extension-children-table", 6, 3, "Abnormal Involuntary Movement Scale Questionnaire")
      ui_check_table_button_class("extension-children-table", 6, 8, "exclude")
      click_link 'Add items'
      sleep 1
      input.set("")
      input = find(:xpath, '//*[@id="searchTable_csearch_cl name"]')
      input.set("Country")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[3]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      find(:xpath, "//*[@id='searchTable_paginate']/ul/li[3]/a").click
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[4]").click
      expect(find("#number-selected").text).to eq("3")
      click_button 'Add items'
      wait_for_ajax(20)
      sleep 1
      ui_check_table_info("extension-children-table", 1, 10, 19)
    end

    it "does not allow to add a Code List to Extension (REQ-MDR-EXT-010)", js:true do
      go_to_edit_extension "C66770E"
      click_link 'Add items'
      sleep 1
      input = find(:xpath, '//*[@id="searchTable_csearch_cl"]')
      input.set("C1")
      input.native.send_keys(:return)
      wait_for_ajax(120)
      find(:xpath, "//*[@id='searchTable']/tbody/tr[1]").click
      find(:xpath, "//*[@id='searchTable']/tbody/tr[2]")[:class].include?("disabled")
      expect(find("#number-selected").text).to eq("1")
      click_button 'Close'
      sleep 1
    end

    it "Create a blank new child item in Extension", js:true do
      go_to_edit_extension "C66770E"
      ui_check_table_info("extension-children-table", 1, 10, 19)
      find("#new-item-button").click
      wait_for_ajax(10)
      ui_check_table_info("extension-children-table", 1, 10, 20)
      ui_check_table_cell("extension-children-table", 1, 3, "Not Set")
      ui_check_table_button_class("extension-children-table", 1, 7, "update-properties")
      ui_check_table_button_class("extension-children-table", 1, 8, "exclude")
    end

    it "Create new children from Synonyms in Extension", js:true do
      go_to_edit_extension "C66770E"
      ui_check_table_info("extension-children-table", 1, 10, 20)
      find(:xpath, "//*[@id='extension-children-table_paginate']/ul/li[3]/a").click
      find("#new-from-synonyms-button").click
      click_button "Cancel"
      find("#new-from-synonyms-button").click
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[8]").click
      sleep 0.5
      expect(page).to have_content "This action will create 2 new Code List Item(s)"
      find("#cd-positive-button").click
      wait_for_ajax(20)
      sleep 0.5
      ui_check_table_info("extension-children-table", 1, 10, 22)
      ui_check_table_cell("extension-children-table", 1, 2, "CONGO, THE DEMOCRATIC REPUBLIC OF")
      ui_check_table_cell("extension-children-table", 2, 2, "DEMOCRATIC REPUBLIC OF THE CONGO")
      ui_check_table_button_class("extension-children-table", 1, 7, "update-properties")
      ui_check_table_button_class("extension-children-table", 1, 8, "exclude")
      ui_check_table_button_class("extension-children-table", 2, 7, "update-properties")
      ui_check_table_button_class("extension-children-table", 2, 8, "exclude")
    end

    it "Remove a Code List Item from an Extension", js:true do
      go_to_edit_extension "C66770E"
      ui_check_table_info("extension-children-table", 1, 10, 22)
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[1]/td[8]/span").click
      ui_confirmation_dialog true
      wait_for_ajax(20)
      ui_check_table_info("extension-children-table", 1, 10, 21)
      find(:xpath, "//*[@id='extension-children-table_paginate']/ul/li[3]/a").click
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[10]/td[8]/span").click
      ui_confirmation_dialog true
      wait_for_ajax(20)
      ui_check_table_info("extension-children-table", 1, 10, 20)
    end

    it "allows the user to edit properties of a child item in an extension", js:true do
      go_to_edit_extension "C66770E"
      ui_check_table_button_class("extension-children-table", 1, 7, "update-properties")
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[1]/td[7]/span").click
      sleep 0.5
      expect(page).to have_content "Edit properties"
      fill_in "ep_input_notation", with: "NOTATION"
      fill_in "ep_input_synonym", with: "Syn1; Syn2"
      find("#submit-button").click
      wait_for_ajax(20)
      ui_check_table_cell("extension-children-table", 1, 2, "NOTATION")
      ui_check_table_cell("extension-children-table", 1, 4, "Syn1; Syn2")
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[2]/td[7]/span").click
      sleep 0.5
      expect(page).to have_content "Edit properties"
      fill_in "ep_input_definition", with: "=/*€%#"
      find("#submit-button").click
      wait_for_ajax(20)
      expect(page).to have_content "Definition contains invalid characters"
      find("#close-modal-button").click
      sleep 0.5
    end

    it "allows the user to edit properties of an extension", js:true do
      go_to_edit_extension "C66770E"
      expect(context_menu_element_header_present?(:edit_properties)).to eq(true)
      context_menu_element_header(:edit_properties)
      expect(page).to have_content "Edit properties"
      fill_in "ep_input_notation", with: "EXTENSION"
      fill_in "ep_input_definition", with: "Extension definition here"
      find("#submit-button").click
      wait_for_ajax(20)
      expect(find("#imh_header")).to have_content "EXTENSION"
      expect(find("#imh_header")).to have_content "Extension definition here"
    end

    it "links to Edit Tags page for an extension", js:true do
      go_to_edit_extension "C66770E"
      expect(context_menu_element_header_present?(:edit_tags)).to eq(true)
      context_menu_element_header(:edit_tags)
      wait_for_ajax(10)
      expect(page).to have_content "C66770E"
      expect(page).to have_content "Attach / Detach Tags"
    end

    it "does not allow edits when edit lock expires", js:true do
      Token.set_timeout(10)
      go_to_edit_extension "C66770E"
      sleep 13
      find("#new-item-button").click
      wait_for_ajax(10)
      expect(page).to have_content("The changes were not saved as the edit lock has timed out")
      find(:xpath, "//*[@id='extension-children-table']/tbody/tr[1]/td[8]/span").click
      ui_confirmation_dialog true
      wait_for_ajax(10)
      expect(page).to have_content("The changes were not saved as the edit lock timed out")
    end

  end

end
