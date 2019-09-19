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
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_schema_file_into_triple_store("ISO25964.ttl")
      # load_schema_file_into_triple_store("CDISCTerm.ttl")
      # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      # load_test_file_into_triple_store("iso_namespace_real.ttl")
      # #load_test_file_into_triple_store("thesaurus_concept.ttl")
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

    it "allows terminology synonyms to be displayed for code lists (REQ-MDR-SY-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      wait_for_ajax
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '43.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 460)
      ui_child_search("C6674")
      ui_check_table_info("children_table", 1, 2, 2)
      ui_check_table_cell("children_table", 1, 1, "C66742")
      ui_check_table_cell("children_table", 1, 3, "CDISC SDTM Yes No Unknown or Not Applicable Response Terminology")
      ui_check_table_cell("children_table", 2, 1, "C66741")
      ui_check_table_cell("children_table", 2, 3, "CDISC SDTM Vital Sign Test Code Terminology")
    end

    it "allows terminology synonyms to be displayed for code list items (REQ-MDR-SY-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      wait_for_ajax
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '43.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 460)
      ui_child_search("C66742")
      find(:xpath, "//tr[contains(.,'No Yes Response')]/td/a", :text => 'Show').click
      expect(page).to have_content 'No Yes Response'
      expect(page).to have_content 'C66742'
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 3, "Yes")
      ui_check_table_cell("children_table", 4, 3, "Unknown")
    end

    it "allows to display code lists and code list items with the same synonym (REQ-MDR-SY-020)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      wait_for_ajax
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '43.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 460)
      ui_child_search("C66742")
      find(:xpath, "//tr[contains(.,'No Yes Response')]/td/a", :text => 'Show').click
      expect(page).to have_content 'No Yes Response'
      expect(page).to have_content 'C66742'
      ui_check_table_info("children_table", 1, 4, 4)
      find(:xpath, "//tr[contains(.,'C17998')]/td/a", :text => 'Show').click
      expect(page).to have_content 'XDOSFRQ (C78745)'
      expect(page).to have_content 'UNKNOWN (C17998)'
    end

    it "allows to assign a synonyms on a code list (REQ-MDR-SY-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri_identifier', with: "NEW TERM"
      fill_in 'thesauri_label', with: 'New Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      find(:xpath, "//tr[contains(.,'NEW TERM')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: NEW TERM'
      context_menu_element('history', 4, 'New Terminology', :edit)
      expect(page).to have_content 'Edit: New Terminology NEW TERM (V0.0.1, 1, Incomplete)'
      click_button 'New'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn1\n"
      expect(page).to have_content 'Syn1'
      click_button 'Close'
    end

    it "allows to assign more synonyms on a code list (REQ-MDR-SY-060)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri_identifier', with: "NEW TERM V2"
      fill_in 'thesauri_label', with: 'New Terminology V2'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      find(:xpath, "//tr[contains(.,'NEW TERM V2')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: NEW TERM V2'
      context_menu_element('history', 4, 'New Terminology V2', :edit)
      expect(page).to have_content 'Edit: New Terminology V2 NEW TERM V2 (V0.0.1, 1, Incomplete)'
      click_button 'New'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList2\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn1; Syn2\n"
      expect(page).to have_content 'Syn2'
      click_button 'Close'
    end

    it "allows to assign a synonyms on a code list item (REQ-MDR-SY-060)", js: true do
      # RESET NAMEVALUE TO 10 and 999 FIRST!
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri_identifier', with: "NEW TERM V3"
      fill_in 'thesauri_label', with: 'New Terminology V3'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      find(:xpath, "//tr[contains(.,'NEW TERM V3')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: NEW TERM V3'
      context_menu_element('history', 4, 'New Terminology V3', :edit)
      expect(page).to have_content 'Edit: New Terminology V3 NEW TERM V3 (V0.0.1, 1, Incomplete)'
      click_button 'New'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList3\t"
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CodeList3 NP000010P (V0.0.1, 1, Incomplete)'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferredTerm", "CodeListItem1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn3\n"
      expect(page).to have_content 'Syn3'
      click_button 'Close'
    end

    it "allows to assign more synonyms on a code list item (REQ-MDR-SY-060)"

    it "allows to update a synonyms on a code list (REQ-MDR-SY-060)", js:true do
      # RESET NAMEVALUE TO 10 and 999 FIRST!
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri_identifier', with: "NEW TERM V4"
      fill_in 'thesauri_label', with: 'New Terminology V4'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      find(:xpath, "//tr[contains(.,'NEW TERM V4')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: NEW TERM V4'
      context_menu_element('history', 4, 'New Terminology V4', :edit)
      expect(page).to have_content 'Edit: New Terminology V4 NEW TERM V4(V0.0.1, 1, Incomplete)'
      click_button 'New'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList4\t"
      editor_table_fill_in "DTE_Field_synonym", "CLSyn4\n"
      expect(page).to have_content 'CLSyn4'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "CLSyn5\n"
      expect(page).to have_content 'CLSyn5'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "CLSyn4; CLSyn5\n"
      expect(page).to have_content 'CLSyn 4; CLSyn5'
      click_button 'Close'
    end

    it "allows to update a synonyms on a code list item (REQ-MDR-SY-060)"

    it "allows to delete a synonyms on a code list (REQ-MDR-SY-060)", js:true do
      # RESET NAMEVALUE TO 10 and 999 FIRST!
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      fill_in 'thesauri_identifier', with: "NEW TERM V5"
      fill_in 'thesauri_label', with: 'New Terminology V5'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      find(:xpath, "//tr[contains(.,'NEW TERM V5')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: NEW TERM V5'
      context_menu_element('history', 4, 'New Terminology V5', :edit)
      expect(page).to have_content 'Edit: New Terminology V5 NEW TERM V5(V0.0.1, 1, Incomplete)'
      click_button 'New'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList5\t"
      editor_table_fill_in "DTE_Field_synonym", "CLSyn5\n"
      expect(page).to have_content 'CLSyn5'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "\n"
      expect(page).not_to have_content 'CLSyn5'
    end

    it "allows to delete a synonyms on a code list item (REQ-MDR-SY-060)"

    it "allows Preferred Term to be displayed for code lists (REQ-MDR-PT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      wait_for_ajax
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '45.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 503)
      ui_child_search("C7115")
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 4, "ECG Test Code")
      ui_check_table_cell("children_table", 4, 4, "ECG Result")
    end

    it "allows Preferred Term to be displayed for code list items (REQ-MDR-PT-010)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      wait_for_ajax
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '45.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 503)
      ui_child_search("C7115")
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 4, "ECG Test Code")
      ui_check_table_cell("children_table", 4, 4, "ECG Result")
    end

  end

end
