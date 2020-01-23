require 'rails_helper'

describe "Thesauri Synonyms and Prefered Terms", :type => :feature do

  # NOTE: Needs to be run as one single run due to dynamic identifiers

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

  def wait_for_ajax_long
    wait_for_ajax(10)
  end

  def editor_table_fill_in(input, text)
    expect(page).to have_css("##{input}", wait: 15)
    fill_in "#{input}", with: "#{text}"
    wait_for_ajax(5)
  end

  def editor_table_click(row, col)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[#{col}]").click
  end

  def new_term_modal(identifier, label)
    # Leave this sleep here. Seems there is an issue with the modal and fade 
    # that causes inconsistent entry of text using fill_in.
    sleep 2 
    fill_in 'thesauri_identifier', with: identifier
    fill_in 'thesauri_label', with: label
    click_button 'Submit'
  end

  describe "The Content Admin User can", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..47)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      nv_destroy
      nv_create(parent: "10", child: "999")
      Token.destroy_all
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
      wait_for_ajax_long
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '44.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 504)
      ui_child_search("C6674")
      ui_check_table_info("children_table", 1, 2, 2)
      ui_check_table_cell("children_table", 1, 1, "C66742")
      ui_check_table_cell("children_table", 1, 3, "CDISC SDTM Yes No Unknown or Not Applicable Response Terminology")
      ui_check_table_cell("children_table", 2, 1, "C66741")
      ui_check_table_cell("children_table", 2, 3, "CDISC SDTM Vital Sign Test Code Terminology")
    end

    it "allows terminology synonyms to be displayed for code list items (REQ-MDR-SY-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '44.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 504)
      ui_child_search("C66742")
      find(:xpath, "//tr[contains(.,'No Yes Response')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      expect(page).to have_content 'No Yes Response'
      expect(page).to have_content 'C66742'
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 3, "Yes")
      ui_check_table_cell("children_table", 4, 3, "Unknown")
    end

    it "allows to display code lists and code list items with the same synonym (REQ-MDR-SY-020)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      context_menu_element('history', 5, '2015-06-26 Release', :show)
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '44.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 504)
      ui_child_search("C66742")
      find(:xpath, "//tr[contains(.,'No Yes Response')]/td/a", :text => 'Show').click
      expect(page).to have_content 'No Yes Response'
      expect(page).to have_content 'C66742'
      ui_check_table_info("children_table", 1, 4, 4)
      find(:xpath, "//tr[contains(.,'C17998')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Shared Synonyms'
      expect(page).to have_xpath("//div[@id='linkspanel']/div/div/div/a/div/div", :text => 'FREQ (C71113)')
      expect(page).to have_xpath("//div[@id='linkspanel']/div/div/div/a/div/div", :text => 'XDOSFRQ (C78745)')
    end

    # Needs code list edit added
    it "allows to assign a synonyms on a code list (REQ-MDR-SY-030)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM", "New Terminology")
    #   wait_for_ajax
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   find(:xpath, "//tr[contains(.,'NEW TERM')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'NEW TERM\''
    #   context_menu_element('history', 4, 'New Terminology', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'New Terminology'
    #   expect(page).to have_content 'NEW TERM'
    #   expect(page).to have_content '0.1.0'
    #   expect(page).to have_content 'Incomplete'
    #   click_button 'New'
    #   wait_for_ajax
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList1\t"
    #   editor_table_fill_in "DTE_Field_synonym", "Syn1\n"
    #   expect(page).to have_content 'Syn1'
    #   click_link 'Return'
    # end

    # Needs code list edit added
    it "allows to assign more synonyms on a code list (REQ-MDR-SY-030)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM V2", "New Terminology V2")
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   find(:xpath, "//tr[contains(.,'NEW TERM V2')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'NEW TERM V2\''
    #   context_menu_element('history', 4, 'New Terminology V2', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'New Terminology V2'
    #   expect(page).to have_content 'NEW TERM V2'
    #   expect(page).to have_content '0.1.0'
    #   expect(page).to have_content 'Incomplete'
    #   click_button 'New'
    #   wait_for_ajax_long
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList2\t"
    #   editor_table_fill_in "DTE_Field_synonym", "Syn1; Syn2\n"
    #   expect(page).to have_content 'Syn1; Syn2'
    #   click_link 'Return'
    # end

    it "allows to assign a synonyms on a code list item (REQ-MDR-SY-030)", js: true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000010P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000010P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00000999C'
      editor_table_click(1,2)
      editor_table_fill_in "DTE_Field_notation", "SUBMISSION 999C\t"
      editor_table_fill_in "DTE_Field_preferred_term", "The PT 999C\n"
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "Syn3\n"
      expect(page).to have_content 'Syn3'
      editor_table_click(1,5)
      editor_table_fill_in "DTE_Field_definition", "We never fill this in, too tricky 999C!\n"
      click_link 'Return'
    end

    it "allows to assign more synonyms on a code list item (REQ-MDR-SY-030)", js:true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000011P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000011P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00001000C'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeListItem1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn4a; Syn4b\n"
      expect(page).to have_content 'Syn4a; Syn4b'
      click_link 'Return'
    end

    # Needs code list edit added
    it "allows to update a synonyms on a code list (REQ-MDR-SY-030)" #, js:true do
    #   click_navbar_terminology
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM V5", "New Terminology V5")
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   find(:xpath, "//tr[contains(.,'NEW TERM V5')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'NEW TERM V5\''
    #   context_menu_element('history', 4, 'New Terminology V5', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'New Terminology V5'
    #   click_button 'New'
    #   wait_for_ajax_long
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList5\t"
    #   editor_table_fill_in "DTE_Field_synonym", "CLSyn5\n"
    #   expect(page).to have_content 'CLSyn5'
    #   editor_table_click(1,4)
    #   editor_table_fill_in "DTE_Field_synonym", "NewCLSyn5\n"
    #   expect(page).to have_content 'NewCLSyn5'
    #   editor_table_click(1,4)
    #   editor_table_fill_in "DTE_Field_synonym", "CLSyn5; NewCLSyn5\n"
    #   expect(page).to have_content 'CLSyn5; NewCLSyn5'
    #   click_link 'Return'
    # end

    it "allows to update a synonyms on a code list item (REQ-MDR-SY-030)", js:true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000012P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000012P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00001001C'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeListItem1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn6\n"
      expect(page).to have_content 'Syn6'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "NewCLSyn6\n"
      expect(page).to have_content 'NewCLSyn6'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "CLSyn6; NewCLSyn6\n"
      expect(page).to have_content 'CLSyn6; NewCLSyn6'
      click_link 'Return'
    end

    # Needs code list edit added
    it "allows to delete a synonyms on a code list (REQ-MDR-SY-030)" #, js:true do
    #   click_navbar_terminology
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM V7", "New Terminology V7")
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   find(:xpath, "//tr[contains(.,'NEW TERM V7')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'NEW TERM V7\''
    #   context_menu_element('history', 4, 'New Terminology V7', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'New Terminology V7'
    #   click_button 'New'
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList7\t"
    #   editor_table_fill_in "DTE_Field_synonym", "CLSyn7\n"
    #   expect(page).to have_content 'CLSyn7'
    #   editor_table_click(1,4)
    #   editor_table_fill_in "DTE_Field_synonym", "\n"
    #   expect(page).not_to have_content 'CLSyn7'
    # end

    it "allows to delete a synonyms on a code list item (REQ-MDR-SY-030)", js:true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000013P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000013P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00001002C'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeListItem1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn8\n"
      expect(page).to have_content 'Syn8'
      editor_table_click(1,4)
      editor_table_fill_in "DTE_Field_synonym", "\n"
      expect(page).not_to have_content 'CLSyn8'
      click_link 'Return'
    end

    # Needs code list edit added
    it "allows to assign a preferred term on a code list (REQ-MDR-PT-030)" #, js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM V9", "New Terminology V9")
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   find(:xpath, "//tr[contains(.,'NEW TERM V9')]/td/a").click
    #   expect(page).to have_content 'Version History of \'NEW TERM V9\''
    #   context_menu_element('history', 4, 'New Terminology V9', :edit)
    #   wait_for_ajax_long
    #   expect(page).to have_content 'New Terminology V9'
    #   click_button 'New'
    #   wait_for_ajax_long
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList9\t"
    #   editor_table_fill_in "DTE_Field_synonym", "Syn1; Syn2\n"
    #   expect(page).to have_content 'CodeList9'
    #   click_link 'Return'
    # end

    it "allows to assign a preferred term on a code list item (REQ-MDR-SY-030)", js: true do
      click_navbar_code_lists
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000014P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000014P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00001003C'
      wait_for_ajax_long
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeListItem1\t"
      editor_table_fill_in "DTE_Field_synonym", "Syn10\n"
      expect(page).to have_content 'CodeListItem1'
    end

    # Needs code list edit added
    it "allows to delete a preferred term on a code list (REQ-MDR-PT-030)" #, js:true do
    #   click_navbar_terminology
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Index: Terminology'
    #   click_link 'new_terminology'
    #   new_term_modal("NEW TERM V11", "New Terminology V11")
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Terminology was successfully created.'
    #   ui_table_search("main", "V11")
    #   find(:xpath, "//tr[contains(.,'NEW TERM V11')]/td/a").click
    #   wait_for_ajax_long
    #   expect(page).to have_content 'Version History of \'NEW TERM V11\''
    #   context_menu_element('history', 4, 'New Terminology V11', :edit)
    #   wait_for_ajax_long
    #   click_button 'New'
    #   wait_for_ajax_long
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", "CodeList11\n"
    #   expect(page).to have_content 'CodeList11'
    #   editor_table_click(1,3)
    #   editor_table_fill_in "DTE_Field_preferred_term", ""
    #   expect(page).not_to have_content 'CodeList11'
    #   click_link "Return"
    # end

    it "allows to delete a preferred term on a code list item (REQ-MDR-PT-030)", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      expect(page).to have_content 'Index: Code Lists'
      click_link 'New Code List'
      wait_for_ajax_long
      expect(page).to have_content 'NP000015P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000015P', :edit)
      wait_for_ajax_long
      click_button 'New'
      wait_for_ajax_long
      expect(page).to have_content 'NC00001004C'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeList12\t"
      click_link "Return"
      expect(page).to have_content 'NP000015P' 
      wait_for_ajax_long
      context_menu_element('history', 4, 'NP000015P', :edit)
      wait_for_ajax_long
      expect(page).to have_content 'NP000015P'
      click_button 'New'
      expect(page).to have_content 'NC00001005C'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", "CodeListItem1\t"
      expect(page).to have_content 'CodeListItem1'
      editor_table_click(1,3)
      editor_table_fill_in "DTE_Field_preferred_term", ""
      expect(page).not_to have_content 'CodeListItem1'
      click_link "Return"
    end

    # Preferred Terms
    it "allows Preferred Term to be displayed for CDISC code lists (REQ-MDR-PT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 561)
      ui_child_search("C7115")
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 4, "ECG Test Code")
      ui_check_table_cell("children_table", 4, 4, "ECG Result")
    end

    it "allows Preferred Term to be displayed for CDISC code list items (REQ-MDR-PT-010)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 561)
      ui_child_search("C7115")
      ui_check_table_info("children_table", 1, 4, 4)
      ui_check_table_cell("children_table", 1, 4, "ECG Test Code")
      ui_check_table_cell("children_table", 4, 4, "ECG Result")
    end

    it "allows to display code lists and code list items with the same preferred term (REQ-MDR-PT-020)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'History'
      expect(page).to have_content 'Controlled Terminology'
      context_menu_element('history', 5, '2016-03-25 Release', :show)
      wait_for_ajax(20)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '47.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 572)
      ui_child_search("unit")
      find(:xpath, "//tr[contains(.,'PKUNIT')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      expect(page).to have_content 'Definition: Units of measure for pharmacokinetic data and parameters.'
      expect(page).to have_content 'C85494'
      ui_check_table_info("children_table", 1, 10, 671)
      find(:xpath, "//tr[contains(.,'C85754')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      expect(page).to have_content 'Shared Preferred Terms'
      expect(page).to have_xpath("//div[@id='preferred_term']/div/div/div/a/div/div", :text => 'UNIT (C71620)')
    end

    #tags
    it "allows Tags to be displayed, table, thesaurus level (REQ-MDR-??????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 561)
      ui_child_search("C99075")
      ui_check_table_info("children_table", 1, 1, 1)
      ui_check_table_cell("children_table", 1, 7, "SDTM\nSEND")
    end

    it "allows Tags to be displayed, table, managed concept level (REQ-MDR-??????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      expect(page).to have_content 'Standard'
      ui_check_table_info("children_table", 1, 10, 561)
      ui_child_search("C99075")
      ui_check_table_cell("children_table", 1, 7, "SDTM\nSEND")
      ui_check_table_info("children_table", 1, 1, 1)
      find(:xpath, "//tr[contains(.,'C99075')]/td/a", :text => 'Show').click
      expect(page).to have_content 'PORTOT'
      expect(page).to have_content 'C99075'
      ui_check_table_cell("children_table", 1, 6, "SDTM\nSEND")
    end

    it "allows Tags to be displayed, header (REQ-MDR-??????)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      # Thesaurus - level
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      expect(page).to have_content 'Show more'
      ui_show_more_tags_th
      expect(page).to have_content 'Tags: ADaM CDASH SDTM SEND'
      find(:xpath, "//tr[contains(.,'C99074')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      # Managed concept - level
      expect(page).to have_content 'DIR'
      expect(page).to have_content 'C99074'
      expect(page).to have_content 'Show more'
      #find(:xpath, '//*[@id="main_area"]/div[4]/div/div/div/div[2]/div[5]/div[2]/span[2]', :text => 'Show more').click
      #find(:xpath, '//*[@id="imh_header"]/div/div/div[2]/div[5]/div[2]/span[2]', :text => 'Show more').click
      ui_show_more_tags_cl
      expect(page).to have_content 'Tags: SDTM SEND'
      find(:xpath, "//tr[contains(.,'C90069')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      # Unmanaged concept - level
      expect(page).to have_content 'TIP'
      expect(page).to have_content 'C90069'
      expect(page).to have_content 'Show more'
      #find(:xpath, '//*[@id="main_area"]/div[4]/div/div/div/div[2]/div[5]/div[2]/span[2]', :text => 'Show more').click
      ui_show_more_tags_cli
      wait_for_ajax_long
      expect(page).to have_content 'Tags: SDTM SEND'
    end

    it "checks for correct display of shared PTs or Ss, unmanaged concepts", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content 'History'
      context_menu_element('history', 5, '2015-12-18 Release', :show)
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '46.0.0'
      ui_child_search("sex")
      ui_check_table_info("children_table", 1, 3, 3)
      find(:xpath, "//tr[contains(.,'C66731')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      expect(page).to have_content 'C66731'
      expect(page).to have_content 'Preferred term: CDISC SDTM Sex of Individual Terminology'
      ui_check_table_info("children_table", 1, 4, 4)
      find(:xpath, "//tr[contains(.,'C17998')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      expect(page).to have_content 'Preferred term: Unknown'
      expect(page).to have_xpath("//div[@id='preferred_term']/div/div/div/a", count: 14)
      expect(page).to have_xpath("//div[@id='linkspanel']/div/div/div/a", count: 28)
    end

    it "checks for correct display of no shared PTs or Synonyms found, unmanaged concepts", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax_long
      expect(page).to have_content 'Controlled Terminology'
      context_menu_element('history', 5, '2015-09-25 Release', :show)
      expect(page).to have_content '45.0.0'
      find(:xpath, "//tr[contains(.,'C99079')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      expect(page).to have_content 'EPOCH'
      find(:xpath, "//tr[contains(.,'C123453')]/td/a", :text => 'Show').click
      wait_for_ajax_long
      expect(page).to have_content 'Preferred term: Induction Therapy Epoch'
      expect(page).to have_content 'No Shared Preferred Terms.'
      expect(page).to have_content 'No Shared Synonyms.'
    end

  end

  def check_tags(date, version, ct_tags, cl_tags)
    click_navbar_cdisc_terminology
    wait_for_ajax(10)
    ui_table_search("history", "#{date} Release")
    context_menu_element('history', 5, "#{date} Release", :show)
    wait_for_ajax_long
    expect(page).to have_content "#{version}"
    ui_show_more_tags_th
    expect(page).to have_content "Tags: #{ct_tags}"
    ui_table_search("children_table", "C100170")
    find(:xpath, "//tr[contains(.,'C100170')]/td/a", :text => 'Show').click
    wait_for_ajax_long
    expect(page).to have_content "C100170"
  sleep 0.5
    ui_show_more_tags_cl
  sleep 0.5
    expect(page).to have_content "Tags: #{cl_tags}"
  end

  describe "Filtered Tags", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..61)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      ua_create
      nv_destroy
      nv_create(parent: "10", child: "999")
    end

    before :each do
      ua_curator_login
    end

    after :each do
      # wait_for_ajax
      #ua_logoff
    end

    after :all do
      nv_destroy
      ua_destroy
    end

    it "Check on filtered tags", js:true do
      check_tags("2012-03-23", "30.0.0", "ADaM CDASH QS SDTM SEND", "QS SDTM")
      check_tags("2014-06-27", "39.0.0", "ADaM CDASH QS-FT SDTM SEND", "QS-FT SDTM")
      check_tags("2014-12-19", "42.0.0", "ADaM CDASH COA SDTM SEND", "SDTM")
      check_tags("2015-06-26", "44.0.0", "ADaM CDASH QRS SDTM SEND", "SDTM")
      check_tags("2015-12-18", "46.0.0", "ADaM CDASH SDTM SEND", "SDTM")
    end

  end

end
