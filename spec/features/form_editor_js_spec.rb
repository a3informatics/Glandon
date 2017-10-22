require 'rails_helper'
require 'selenium-webdriver'

describe "Form Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ValidationHelpers
  include FormHelpers

  before :all do
    clear_triple_store
    Token.destroy_all
    Token.set_timeout(5)
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
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("CT_ACME_V1.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    load_test_file_into_triple_store("form_crf_test_2.ttl")
    @user = User.create :email => "form_edit@example.com", :password => "12345678" 
    @user.add_role :curator
  end

  after :each do
    click_link 'logoff_button'
  end

  after :all do
    user = User.where(:email => "form_edit@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do
  
    it "has correct initial state", js: true do
      create_form("TEST INITIAL", "Initial", "Initial Layout Test") 
      expect(page).to have_content("Edit: Initial TEST INITIAL (V0.1.0, 1, Incomplete)")
      expect(page).to have_content("Form Details")
      expect(page).to have_content("G+")
      expect(page).to have_content("Save")
      expect(page).to have_content("Close")
      ui_click_node_key(1)
      ui_check_disabled_input('formIdentifier', "TEST INITIAL")
      ui_check_input('formLabel', "Initial Layout Test")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Top Level Group"
    end

    it "allows a form to be defined, Form Panel", js: true do
      create_form("TEST 1A", "Test", "Test 1") # TEST 1 -> TEST1A to avoid name clash
      fill_in 'formCompletion', with: "Completion for the form **level**"
      fill_in 'formNote', with: "Notes for *form*"
      click_button 'formAddGroup'
      ui_click_node_name("Test 1")
      ui_check_input('formLabel', "Test 1")
      ui_check_input('formCompletion', "Completion for the form **level**")
      ui_check_input('formNote', "Notes for *form*")
    end

    it "allows a group to be added, Group Panel", js: true do
      create_form("TEST 2A", "Test", "Test 2") # TEST 2 -> TEST2A to avoid name clash
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      fill_in 'groupNote', with: "Notes for group 1"
      check 'groupRepeating'
      check 'groupOptional'
      click_button 'groupAddGroup'
      fill_in 'groupLabel', with: "Group 2"
      fill_in 'groupCompletion', with: "Completion for group 2"
      fill_in 'groupNote', with: "Notes for group 2"
      ui_click_node_name("Group 1")
      ui_check_input('groupLabel', "Group 1")
      ui_check_input('groupCompletion', "Completion for group 1")
      ui_check_input('groupNote', "Notes for group 1")
      ui_check_checkbox('groupRepeating', true)
      ui_check_checkbox('groupOptional', true)
    end

    it "allows a common group to be added, Common Panel", js: true do
      create_form("TEST 3", "Test", "Test 3") 
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      ui_click_node_name("Test 3")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      fill_in 'commonLabel', with: "Common 1"
      ui_click_node_name("Group 1")
      expect(ui_get_key_by_name("Common 1")).to eq(3)
      ui_click_node_name("Common 1")
      ui_check_input('commonLabel', "Common 1")
      ui_click_node_name("Group 1")
    end

    it "allows a question to be added, Question Panel", js: true do
      create_form("TEST 4", "Test", "Test 4") 
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      ui_click_node_name("Group 1")
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      #expect(page).to have_content 'Notepad'
      fill_in 'questionLabel', with: "Q 1"
      fill_in 'questionText', with: "What is?"
      check 'questionOptional'  
      fill_in 'questionMapping', with: "[NOT SUBMITTED]"
      choose 'form_datatype_s'
      fill_in 'questionCompletion', with: "Completion for question"
      fill_in 'questionNote', with: "Notes for question"
      ui_click_node_name("Group 1")
      ui_click_node_name("Q 1")
      ui_check_input('questionLabel', "Q 1")
      ui_check_input('questionText', "What is?")
      ui_check_input('questionMapping', "[NOT SUBMITTED]")
      ui_check_input('questionCompletion', "Completion for question")
      ui_check_input('questionNote', "Notes for question")
      ui_check_checkbox('questionOptional', true)
      ui_check_radio('form_datatype_i', false)
      ui_check_radio('form_datatype_s', true)
    end

    it "allows a label to be added, Label Panel", js: true do 
      create_form("TEST 5", "Test", "Test 5") 
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      ui_click_node_name("Group 1")
      click_button 'groupAddLabelText'
      expect(page).to have_content 'Label Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'labelTextLabel', with: "LT 1"
      fill_in 'labelTextText', with: "This is a markdown label"
      ui_click_node_name("Group 1")
      ui_click_node_name("LT 1")
      ui_check_input('labelTextLabel', "LT 1")
      ui_check_input('labelTextText', "This is a markdown label")
    end

    it "allows a placeholder to be added, Placeholder Panel", js: true do 
      create_form("TEST 6", "Test", "Test 6") 
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      ui_click_node_name("Group 1")
      click_button 'groupAddPlaceholder'
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'placeholderText', with: "This is some placeholder text"
      ui_click_node_name("Group 1")
      ui_click_node_name("Placeholder 1")
      ui_check_input('placeholderText', "This is some placeholder text")
    end

    it "allows a mapping to be added, Mapping Panel", js: true do
      create_form("TEST 7", "Test", "Test 7") 
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      fill_in 'groupCompletion', with: "Completion for group 1"
      ui_click_node_name("Group 1")
      click_button 'groupAddMapping'
      expect(page).to have_content 'Mapping Details'
      fill_in 'mappingMapping', with: "XXX=YYY when EGTESTCD=TESTCODE"
      ui_click_node_name("Group 1")
      ui_click_node_name("Mapping 1")
      ui_check_input('mappingMapping', "XXX=YYY when EGTESTCD=TESTCODE")
    end

    it "Common Item Panel", js: true do
      load_form("CRF TEST 1") 
      key = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      expect(page).to have_content 'Common Item Details'
      expect(page).to have_content 'Date and Time (--DTC)'
    end

    it "allows items to be moved up and down", js: true do
      load_form("CRF TEST 1") 
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 1"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 2"]')
      ui_click_node_key(key1)
      click_button "questionDown"
      #pause
      ui_check_node_ordinal(key1, 2)
      ui_check_node_ordinal(key2, 1)
      click_button "questionUp"
      ui_check_node_ordinal(key1, 1)
      ui_check_node_ordinal(key2, 2)
      key = ui_get_key_by_path('["CRF Test Form", "Q Group", "Mapping 3"]')
      ui_click_node_key(key)
      click_button "mappingUp"
      ui_check_node_ordinal(key, 2)
      click_button "mappingDown"
      ui_check_node_ordinal(key, 3)
      key = ui_get_key_by_path('["CRF Test Form", "Q Group", "Placeholder 5"]')
      ui_click_node_key(key)
      click_button "placeholderUp"
      ui_check_node_ordinal(key, 4)
      click_button "placeholderDown"
      ui_check_node_ordinal(key, 5)
      key = ui_get_key_by_path('["CRF Test Form", "Q Group", "Label Text 4"]')
      ui_click_node_key(key)
      click_button "labelTextUp"
      ui_check_node_ordinal(key, 3)
      click_button "labelTextDown"
      ui_check_node_ordinal(key, 4)
      key = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      click_button "commonItemDown"
      ui_check_node_ordinal(key, 2)
      click_button "commonItemUp"
      ui_check_node_ordinal(key, 1)
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 1"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 2"]')
      ui_click_node_key(key1)
      click_button "questionDown"
      ui_check_node_ordinal(key1, 2)
      ui_check_node_ordinal(key2, 1)
      click_button "questionUp"
      ui_check_node_ordinal(key1, 1)
      ui_check_node_ordinal(key2, 2)
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 1"]')
      ui_click_node_key(key1)
      click_button "questionUp"
      expect(page).to have_content("You cannot move the node up.")      
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Placeholder 5"]')
      ui_click_node_key(key1)
      click_button "placeholderDown"
      expect(page).to have_content("You cannot move the node down.")      
    end

    it "allows groups to be moved up and down", js: true do
      load_form("CRF TEST 1") 
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "Q Repeating Group"]')
      ui_click_node_key(key1)
      click_button "groupDown"
      ui_check_node_ordinal(key1, 4)
      click_button "groupUp"
      ui_check_node_ordinal(key1, 3)
    end

    it "allows for BCs to be moved up and down", js: true do
    	load_form("CRF TEST 1") 
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Systolic Blood Pressure (BC C25298)"]')
      ui_click_node_key(key1)
			click_button "bcUp"
			expect(page).to have_content("You cannot move the node up.")  
			ui_check_node_ordinal(key1, 2)
			click_button "bcDown"
			ui_check_node_ordinal(key1, 3)
			click_button "bcUp"
			ui_check_node_ordinal(key1, 2)
			key1 = ui_get_key_by_path('["CRF Test Form", "BC Repeating Group", "Weight (BC C25208)"]')
      ui_click_node_key(key1)
			click_button "bcUp"
			ui_check_node_ordinal(key1, 1)
			click_button "bcDown"
			ui_check_node_ordinal(key1, 2)
			click_button "bcDown"
			ui_check_node_ordinal(key1, 3)
			click_button "bcDown"
			expect(page).to have_content("You cannot move the node down.")  
			ui_check_node_ordinal(key1, 3)
		end

    it "allows for BC Items to be moved up and down", js: true do
    	load_form("CRF TEST 1") 
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Diastolic Blood Pressure (BC C25299)", "Result Value (--ORRES)"]')
      ui_click_node_key(key1)
			click_button "itemUp"
			ui_check_node_ordinal(key1, 2)
			click_button "itemUp"
			ui_check_node_ordinal(key1, 1)
			click_button "itemUp"
			expect(page).to have_content("You cannot move the node up.")  
			ui_check_node_ordinal(key1, 1)
			click_button "itemDown"
			ui_check_node_ordinal(key1, 2)
			click_button "itemDown"
			ui_check_node_ordinal(key1, 3)
			click_button "itemDown"
			ui_check_node_ordinal(key1, 4)
			click_button "itemDown"
			expect(page).to have_content("You cannot move the node down.")  
			ui_check_node_ordinal(key1, 4)
		end

    it "shows a preview markdown and the correct panels", js: true do
      create_form("TEST 8", "Test", "Test 8")
      expect(page).to have_content("Form Details")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      expect(page).to have_content 'Biomedical Concept Selection'
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      #expect(page).to have_content 'Notepad'
      fill_in 'questionText', with: "Question text must be set"
      ui_click_node_key(2)
      wait_for_ajax(5)
      click_button 'groupAddMapping'
      expect(page).to have_content 'Mapping Details'
      fill_in 'mappingMapping', with: "Mapping text must be set"
      ui_click_node_key(2)
      wait_for_ajax(5)
      click_button 'groupAddLabelText'
      expect(page).to have_content 'Label Details'
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(2)
      wait_for_ajax
      click_button 'groupAddPlaceholder'
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(2)
      wait_for_ajax
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(3)
      wait_for_ajax
      expect(page).to have_content 'Question Details'
      #expect(page).to have_content 'Notepad'
      ui_set_focus('questionCompletion')
      expect(page).to have_content 'Markdown Preview'
    #ui_is_not_visible("#notepad_panel")
      fill_in 'questionCompletion', with: "*Hello* World! Also add soem single quotes 'like' this."
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "Hello World! Also add soem single quotes 'like' this.")
      click_button 'markdown_hide'
      #expect(page).to have_content 'Notepad'
      expect(page).to have_no_content 'Markdown Preview'
      fill_in 'questionNote', with: 'And now for smething completely different ... and some double quotes "here".'
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "And now for smething completely different ... and some double quotes \"here\".")
      click_button 'markdown_hide'
      #expect(page).to have_content 'Notepad'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(4)
      wait_for_ajax
      expect(page).to have_content 'Mapping Details'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(5)
      wait_for_ajax
      expect(page).to have_content 'Label Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'labelTextText', with: "This is **Strong**"
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "This is Strong")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
      ui_set_focus('labelTextText')
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(6)
      wait_for_ajax
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'placeholderText', with: "# Header 1\n## Header 2\n### Header 3"
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "Header 1 Header 2 Header 3")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
      ui_set_focus('placeholderText')
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(2)
      wait_for_ajax
      expect(page).to have_content 'Group Details'
      expect(page).to have_content 'Biomedical Concept Selection'
      expect(page).to have_no_content 'Markdown Preview'
      fill_in 'groupCompletion', with: "~~~~\nThis is code\n~~~~\n"
      expect(page).to have_no_content 'Biomedical Concept Selection'
      expect(page).to have_content 'Markdown Preview'
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "This is code")
      click_button 'markdown_hide'
      expect(page).to have_content 'Biomedical Concept Selection'
      expect(page).to have_no_content 'Markdown Preview'
      ui_set_focus('groupCompletion')
      expect(page).to have_content 'Markdown Preview'
      fill_in 'groupNote', with: "1. Numbered\n2. Numbered\n"
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "Numbered Numbered")
      click_button 'markdown_hide'
      expect(page).to have_content 'Biomedical Concept Selection'
      expect(page).to have_no_content 'Markdown Preview'
    end

    it "makes sure a node is selected, group", js: true do
      create_form("TEST GROUP 1", "Test", "Test Group 1")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Group 1")
      ui_click_node_name("Group 1")
      ui_clear_current_node
      click_button 'groupAddGroup'
      #pause
      expect(page).to have_content('You need to select a node.')
      click_button 'groupAddCommon'
      expect(page).to have_content('You need to select a node.')
      click_button 'groupAddBc'
      expect(page).to have_content('You need to select a node.')
      click_button 'groupAddQuestion'
      expect(page).to have_content('You need to select a node.')
      click_button 'groupAddLabelText'
      expect(page).to have_content('You need to select a node.')
      click_button 'groupAddPlaceholder'
      expect(page).to have_content('You need to select a node.')
      click_button 'groupDelete'
      expect(page).to have_content('You need to select a node.')
    end

    it "allows group delete and preventing non-empty delete", js: true do
      create_form("TEST GROUP 2", "Test", "Test Group 2")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      fill_in 'groupLabel', with: "Group 1"
      click_button 'groupAddPlaceholder'
      ui_click_node_name("Group 1")
      click_button 'groupAddMapping'
      fill_in 'mappingMapping', with: "Mapping text must be set"
      ui_click_node_name("Group 1")
      click_button 'groupDelete'
      expect(page).to have_content("You need to remove the child nodes.")
    end

    it "allows group and child group delete", js: true do
      create_form("TEST GROUP 3", "Test", "Test Group 3")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      fill_in 'groupLabel', with: "Group 1"
      click_button 'groupAddGroup'
      fill_in 'groupLabel', with: "Group 1.1"
      ui_click_node_name("Group 1")
      ui_click_node_name("Group 1.1")
      click_button 'groupAddMapping'
      fill_in 'mappingMapping', with: "MAP 1"
      ui_click_node_name("Group 1.1")
      click_button 'groupAddMapping'
      fill_in 'mappingMapping', with: "MAP 2"
      ui_click_node_name("Group 1.1")
      click_button 'groupDelete'
      expect(page).to have_content("You need to remove the child nodes.")
      ui_click_node_name("Mapping 1")
      click_button 'mappingDelete'
      ui_click_node_name("Mapping 2")
      click_button 'mappingDelete'
      ui_click_node_name("Group 1.1")
      click_button 'groupDelete'
      expect(ui_get_key_by_name("Group 1.1")).to eq(-1)
      expect(ui_get_key_by_name("Group 1")).to eq(2)
    end

    it "allows common group to be added, prevents others being added", js: true do
      create_form("TEST GROUP 4", "Test", "Test Group 4")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Group 4")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      ui_click_node_name("Common Group")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      expect(page).to have_content("Group already has a common node.")
    end

    it "allows common group to be deleted", js: true do
      create_form("TEST COMMON GROUP 1", "Test", "Test Common Group 1")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Common Group 1")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      ui_click_node_name("Group 1")
      ui_click_node_name("Common Group")
      #pause
      click_button 'commonDelete'
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      fill_in 'commonLabel', with: "Common New 1"
      ui_click_node_name("Group 1")
      ui_click_node_name("Common New 1")
      ui_check_input('commonLabel', "Common New 1")
    end

    it "allows questions to be updated, check enable and disable on the panel - WILL FAIL CURRENTLY ", js: true do
      create_form("TEST QUESTION 1", "Test", "Test Question 1")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      expect(page).to have_content 'Biomedical Concept Selection'
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      #expect(page).to have_content 'Notepad'
      ui_click_node_key(3)
      fill_in 'questionLabel', with: "Q 1"
      fill_in 'questionText', with: "What is?"
      check 'questionOptional'  
      fill_in 'questionMapping', with: "[NOT SUBMITTED]"
      choose 'form_datatype_s'
      fill_in 'questionCompletion', with: "Completion for question"
      fill_in 'questionNote', with: "Notes for question"
      ui_click_node_name("Group")
      ui_click_node_name("Q 1")
      ui_check_input('questionLabel', "Q 1")
      ui_check_input('questionText', "What is?")
      ui_check_input('questionMapping', "[NOT SUBMITTED]")
      ui_check_input('questionCompletion', "Completion for question")
      ui_check_input('questionNote', "Notes for question")
      ui_click_node_name("Group")
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details' # Wait for page to settle
      choose 'form_datatype_i'
      ui_check_input('questionFormat', "3")
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_s'
      ui_check_input('questionFormat', "20")
      ui_button_enabled('tfe_add_item')
      ui_button_enabled('tfe_delete_item')
      ui_button_enabled('tfe_delete_all_items')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_f'
      ui_check_input('questionFormat', "6.2")
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_b'
      ui_field_disabled('questionFormat')
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      choose 'form_datatype_d'
      ui_field_disabled('questionFormat')
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      ui_field_disabled('questionFormat')
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      choose 'form_datatype_d+t'
      ui_field_disabled('questionFormat')
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      #ui_button_disabled('deleteTerm')
      choose 'form_datatype_i'
      fill_in 'questionFormat', with: "5"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "5")
      choose 'form_datatype_f'
      fill_in 'questionFormat', with: "7.1"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "7.1")
      choose 'form_datatype_s'
      fill_in 'questionFormat', with: "50"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "50")  
      choose 'form_datatype_i'
      fill_in 'questionFormat', with: "5"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "5")
      choose 'form_datatype_f'
      fill_in 'questionFormat', with: "7.1"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "7.1")
      choose 'form_datatype_s'
      fill_in 'questionFormat', with: "50"
      ui_click_node_key(2)
      ui_click_node_key(3)
      ui_check_input('questionFormat', "50")  
      choose 'form_datatype_s'
      click_button 'tfe_add_item'
      expect(page).to have_content("You need to select an item.")
      ui_table_row_double_click('searchTable', 'EQ-5D-3L TEST')
      wait_for_ajax
      ui_table_row_click('searchTable', 'C100394')
      ui_click_by_id 'tfe_add_item'
      ui_click_node_key(4)
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details' # Wait for page to settle
      ui_table_row_click('searchTable', 'C100393')
      ui_click_by_id 'tfe_add_item'
      ui_click_node_key(4)
      ui_click_node_key(3)
      wait_for_ajax
      expect(page).to have_content 'Question Details' # Wait for page to settle
    
    #pause

      ui_table_row_click('tfe_item_table', 'C100394')
      ui_click_by_id 'tfe_delete_item'
      ui_click_by_id 'tfe_delete_item'
      expect(page).to have_content("You need to select an item.")
      ui_click_node_name("Q 1")
      click_button "questionDelete"
      key = ui_get_key_by_name("Q 1")
      expect(key).to eq(-1)
    end

    it "allows simple items to be deleted", js: true do
      create_form("TEST SIMPLE 1", "Test", "Test Simple 1")
      click_button 'formAddGroup'
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "LT 1"
      fill_in 'labelTextText', with: "This is a markdown label"
      ui_click_node_name("Group")
      click_button 'groupAddPlaceholder'
      fill_in 'placeholderText', with: "This is some placeholder text"
      ui_click_node_name("Group")
      click_button 'groupAddMapping'
      fill_in 'mappingMapping', with: "XXX=YYY when EGTESTCD=TESTCODE"
      ui_click_node_name("Group")
      ui_click_node_name("Placeholder 2")
      click_button "placeholderDelete"
      key = ui_get_key_by_name("Placeholder 1")
      expect(key).to eq(-1)
      ui_click_node_name("Mapping 3")
      click_button "mappingDelete"
      key = ui_get_key_by_name("Mapping 2")
      expect(key).to eq(-1)
      ui_click_node_name("LT 1")
      click_button "labelTextDelete"
      key = ui_get_key_by_name("Label Text 3")
      expect(key).to eq(-1)
    end

    it "allows BCs to be added", js: true do
      create_form("TEST BC 1", "Test", "Test BC 1")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test BC 1")
      ui_click_node_name("Group 1")
      click_button 'groupAddBc'
      expect(page).to have_content("You need to select a Biomedical Concept.")
      ui_table_row_click("bcTable", "(BC C25206)")
      click_button 'groupAddBc'
      wait_for_ajax(10)
      ui_click_node_name("Temperature (BC C25206)")
      expect(page).to have_content("Biomedical Concept Details")
      expect(page).to have_content("Temperature (BC C25206)")
      ui_click_node_name("Group 1")
      ui_table_row_click("bcTable", "(BC C25208)")
      click_button 'groupAddBc'
      wait_for_ajax(10)
      ui_click_node_name("Weight (BC C25208)")
      expect(page).to have_content("Biomedical Concept Details")
      expect(page).to have_content("Weight (BC C25208)")
      #pause
      expect(ui_get_key_by_name("Temperature (BC C25206)")).not_to eq(-1)
      expect(ui_get_key_by_name("Weight (BC C25208)")).not_to eq(-1)
      expect(ui_get_key_by_name("Kilogram")).not_to eq(-1)
      expect(ui_get_key_by_name("Pound")).not_to eq(-1)
      expect(ui_get_key_by_name("Degree Celsius")).not_to eq(-1)
    end
    
    it "allows items to be made common and restored", js: true do
      create_form("TEST BC 2", "Test", "Test BC 2")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test BC 2")
      ui_click_node_name("Group 1")
      click_button 'groupAddBc'
      expect(page).to have_content("You need to select a Biomedical Concept.")
      ui_table_row_click("bcTable", "(BC C25206)")
      click_button 'groupAddBc'
      ui_click_node_name("Temperature (BC C25206)")
      ui_click_node_name("Group 1")
      ui_table_row_click("bcTable", "(BC C25208)")
      click_button 'groupAddBc'
      wait_for_ajax(10) # Long wait for BC loading
      ui_click_node_name("Weight (BC C25208)")
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      click_button "itemCommon"
      expect(page).to have_content("A common group was not found.")
      ui_click_node_name("Group 1")
      click_button "groupAddCommon"
      ui_click_node_key(key)
      click_button "itemCommon"
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).not_to eq(-1)
      ui_click_node_key(key)
      expect(page).to have_content("Common Item Details")
      ui_scroll_to_id_2 "itemRestore"
      #page.execute_script("document.getElementById('itemRestore').scrollIntoView(false);")
      click_button "itemRestore"
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).to eq(-1)
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
    end
    
    it "allows items to be made common and restored, items moved", js: true do
      create_form("TEST BC 2A", "Test", "Test BC 2A")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test BC 2A")
      ui_click_node_name("Group 1")
      click_button 'groupAddBc'
      expect(page).to have_content("You need to select a Biomedical Concept.")
      ui_table_row_click("bcTable", "(BC C25206)")
      click_button 'groupAddBc'
      ui_click_node_name("Temperature (BC C25206)")
      ui_click_node_name("Group 1")
      ui_table_row_click("bcTable", "(BC C25208)")
      click_button 'groupAddBc'
      wait_for_ajax(15) # Long wait for BC loading
      ui_click_node_name("Weight (BC C25208)")
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      ui_scroll_to_id_2 "itemCommon"
      click_button "itemCommon"
      expect(page).to have_content("A common group was not found.")
      ui_click_node_name("Group 1")
      click_button "groupAddCommon"
      ui_click_node_key(key)
      click_button "itemCommon"
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).not_to eq(-1)
      ui_click_node_key(key)
      expect(page).to have_content("Common Item Details")
    	key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Temperature (BC C25206)"]')
      ui_click_node_key(key)
      click_button 'bcDown'
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      ui_scroll_to_id_2 "itemRestore"
      #page.execute_script("document.getElementById('itemRestore').scrollIntoView(false);")
      click_button "itemRestore"
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).to eq(-1)
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
      key = ui_get_key_by_path('["Test BC 2A", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
    end
    
    it "allows items to be made common and restored, items moved", js: true do
      create_form("TEST BC 2B", "Test", "Test BC 2B")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test BC 2B")
      ui_click_node_name("Group 1")
      click_button 'groupAddBc'
      expect(page).to have_content("You need to select a Biomedical Concept.")
      ui_table_row_click("bcTable", "(BC C25206)")
      click_button 'groupAddBc'
      ui_click_node_name("Temperature (BC C25206)")
      ui_click_node_name("Group 1")
      ui_table_row_click("bcTable", "(BC C25208)")
      click_button 'groupAddBc'
      wait_for_ajax(15) # Long wait for BC loading
      ui_click_node_name("Weight (BC C25208)")
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      ui_scroll_to_id_2 "itemCommon"
      click_button "itemCommon"
      expect(page).to have_content("A common group was not found.")
      ui_click_node_name("Group 1")
      click_button "groupAddCommon"
      ui_click_node_key(key)
      click_button "itemCommon"
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"common")
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).not_to eq(-1)
      ui_click_node_key(key)
      expect(page).to have_content("Common Item Details")
    	key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Temperature (BC C25206)", "Result Units (--ORRESU)"]')
      ui_click_node_key(key)
      click_button 'itemUp'
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      ui_click_node_key(key)
      ui_scroll_to_id_2 "itemRestore"
      #page.execute_script("document.getElementById('itemRestore').scrollIntoView(false);")
      click_button "itemRestore"
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).to eq(-1)
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
      key = ui_get_key_by_path('["Test BC 2B", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
    end
    
    it "allows items to be made common when BC added"

    it "allows common items to be moved up and down", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Date and Time (--DTC)"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Body Position (--POS)"]')
      ui_click_node_key(key1)
      click_button "commonItemDown"
      ui_check_node_ordinal(key1, 2)
      ui_check_node_ordinal(key2, 1)
      ui_click_node_key(key1)
      click_button "commonItemUp"
      ui_check_node_ordinal(key1, 1)
      ui_check_node_ordinal(key2, 2)
      ui_click_node_key(key2)
      click_button "commonItemUp"
      ui_check_node_ordinal(key1, 2)
      ui_check_node_ordinal(key2, 1)
    end

    it "allows BCs to have completion instructions and notes", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Systolic Blood Pressure (BC C25298)"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "BC Group"]')
      ui_click_node_key(key1)
      expect(page).to have_content("BC C25298")
      expect(page).to have_content("Systolic Blood Pressure (BC C25298)")
      fill_in 'bcCompletion', with: "Completion for BC"
      fill_in 'bcNote', with: "Notes for BC"
      ui_click_node_key(key2)
      ui_click_node_key(key1)
      ui_check_input('bcCompletion', "Completion for BC")
      ui_check_input('bcNote', "Notes for BC")
    end
    
    it "allows a BC property to have enabled and optional, completion instructions and notes", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Systolic Blood Pressure (BC C25298)", "Result Value (--ORRES)"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "BC Group"]')
      ui_click_node_key(key1)
      expect(page).to have_content("BC Item Details")
      fill_in 'bcItemCompletion', with: "Completion for BC Item"
      fill_in 'bcItemNote', with: "Notes for BC Item"
      check 'bcItemOptional'  
      check 'bcItemEnable'  
      ui_click_node_key(key2)
      ui_click_node_key(key1)
      expect(page).to have_content("BC Item Details")
      ui_check_input('bcItemCompletion', "Completion for BC Item")
      ui_check_input('bcItemNote', "Notes for BC Item")
      ui_check_checkbox('bcItemOptional', true)
      ui_check_checkbox('bcItemEnable', true)
      uncheck 'bcItemOptional'  
      uncheck 'bcItemEnable'  
      ui_click_node_key(key2)
      ui_click_node_key(key1)
      expect(page).to have_content("BC Item Details")
      ui_check_checkbox('bcItemOptional', false)
      ui_check_checkbox('bcItemEnable', false)
    end
    
    it "allows the CL to be moved up and down for BC common group - WILL FAIL CURRENTLY", js: true do 
      load_form("CRF TEST 1") 
      wait_for_ajax(5)
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Body Position (--POS)", "Supine Position"]')
      ui_click_node_key(key1)
      wait_for_ajax
      ui_check_node_ordinal(key1, 3)    
      #click_button "clUp"
      ui_click_by_id("clUp")
      ui_check_node_ordinal(key1, 2)    
      #click_button "clDown"
      ui_click_by_id("clDown")
      ui_check_node_ordinal(key1, 3)    
    end

    it "allows the CL to be moved up and down for BC group", js: true do 
      load_form("CRF TEST 1") 
      wait_for_ajax(5)
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Repeating Group", "Weight (BC C25208)", "Result Units (--ORRESU)", "Gram"]')
      ui_click_node_key(key1)
      ui_check_node_ordinal(key1, 3)    
      click_button "clUp"
      ui_check_node_ordinal(key1, 2)    
      click_button "clDown"
      ui_check_node_ordinal(key1, 3)    
    end

    it "displays the CL Item Panel for BCs", js: true do 
      load_form("CRF TEST 1") 
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Body Position (--POS)", "Standing"]')
      ui_click_node_key(key1)
      expect(page).to have_content("Code List Details")
      expect(page).to have_content("C62166")
      expect(page).to have_content("STANDING")
    end      

    it "allows the CL to be moved up and down for Questions, checks CL Item Panel - WILL FAIL CURRENTLY", js: true do 
      load_form("CRF TEST 1") 
      wait_for_ajax(5)
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 1"]')
      ui_click_node_key(key1)
      wait_for_ajax
      choose 'form_datatype_s'
    #ui_table_row_click('notepad_table', 'C16358')
    #click_button 'notepad_add'
      wait_for_ajax
    #ui_table_row_click('notepad_table', 'C25157')
    #click_button 'notepad_add'
      wait_for_ajax
      ui_click_node_key(key1)
      key2 = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 1", "Body Surface Area"]')
      ui_click_node_key(key2)
      expect(page).to have_content("Code List Details")
      expect(page).to have_content("C25157")
      expect(page).to have_content("BSA")
      ui_check_node_ordinal(key2, 2)    
      #click_button "clUp"
      ui_click_by_id("clUp")
      ui_check_node_ordinal(key2, 1)    
      #click_button "clDown"
      ui_click_by_id("clDown")
      ui_check_node_ordinal(key2, 2)    
    end

    it "allows a BC to be deleted", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Systolic Blood Pressure (BC C25298)"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "BC Group"]')
      ui_click_node_key(key1)
      click_button "bcDelete"
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Systolic Blood Pressure (BC C25298)"]')
      expect(key1).to eq(-1)
    end

    it "handles common when BC deleted", js: true do
      load_form("CRF TEST 2")
      wait_for_ajax
      key1 = ui_get_key_by_path('["CRF test Form 2", "Group", "Systolic Blood Pressure (BC C25298)"]')
      ui_click_node_key(key1)
      wait_for_ajax
      click_button "bcDelete"
      key1 = ui_get_key_by_path('["CRF test Form 2", "BC Group", "Systolic Blood Pressure (BC C25298)"]')
      expect(key1).to eq(-1)
    end

  
    it "loads current terminology", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      expect(page).to have_content 'Current Terminologies'
      expect(page).to have_content 'Showing 1 to 10 of 17,363 entries'
      fill_in 'searchTable_csearch_cl', with: 'C100129'
      ui_hit_return('searchTable_csearch_cl')
      wait_for_ajax
      expect(page).to have_content 'Showing 1 to 10 of 142 entries'
    end

    it "form edit timeout warnings and expiration", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (V0.0.0, 1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i - 2 # Needs to be tweaked to get in the 5 sec warnign window period
      page.find("#token_timer_1")[:class].include?("btn-warning")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer_1")[:class].include?("btn-danger")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      expect(token.timed_out?).to eq(true)
    end

    it "form edit timeout warnings and extend", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      token = tokens[0]
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (V0.0.0, 1, Incomplete)")
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Save'
      wait_for_ajax
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep 11
      page.find("#token_timer_1")[:class].include?("btn-warning")
    end

    it "edit clears token on close", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (V0.0.0, 1, Incomplete)")
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Close'
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      expect(tokens).to match_array([])
    end  

    it "edit clears token on back button", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_form("CRF TEST 1") 
      wait_for_ajax
      expect(page).to have_content("Edit: CRF Test Form CRF TEST 1 (V0.0.0, 1, Incomplete)")
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      ui_click_back_button
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_CRFTEST1")
      expect(tokens).to match_array([])
    end  

    it "allows the fields to be valdated", js: true do
      load_form("CRF TEST 1") 
      wait_for_ajax
      # Keys
      key_form = ui_get_key_by_path('["CRF Test Form"]')
      key_bc_group = ui_get_key_by_path('["CRF Test Form", "BC Group"]')
      key_common_group = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group"]')
      key_q_group = ui_get_key_by_path('["CRF Test Form", "Q Group"]')
      key_question = ui_get_key_by_path('["CRF Test Form", "Q Group", "Question 2"]')
      key_mapping = ui_get_key_by_path('["CRF Test Form", "Q Group", "Mapping 3"]')
      key_label = ui_get_key_by_path('["CRF Test Form", "Q Group", "Label Text 4"]')
      key_placeholder = ui_get_key_by_path('["CRF Test Form", "Q Group", "Placeholder 5"]')
      key_bc_temp = ui_get_key_by_path('["CRF Test Form", "BC Repeating Group", "Temperature (BC C25206)"]')
      key_bc_temp_item = ui_get_key_by_path('["CRF Test Form", "BC Repeating Group", "Temperature (BC C25206)", "Result Value (--ORRES)"]')
      key_bc_temp_item_cl = ui_get_key_by_path('["CRF Test Form", "BC Repeating Group", "Temperature (BC C25206)", "Result Units (--ORRESU)", "Degree Celsius"]')
      # Form
      ui_check_validation_error(key_form, "formLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_form, "formLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_form, "formLabel", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_form, "formNote", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_form, "formNote", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_form, "formCompletion", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_form, "formCompletion", "#{vh_all_chars}", key_bc_group)
      # Group
      ui_check_validation_error(key_q_group, "groupLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_q_group, "groupLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_q_group, "groupLabel", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_q_group, "groupNote", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_q_group, "groupNote", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_q_group, "groupCompletion", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_q_group, "groupCompletion", "#{vh_all_chars}", key_bc_group)
      # BC
      ui_check_validation_error(key_bc_temp, "bcNote", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_bc_temp, "bcNote", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_bc_temp, "bcCompletion", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_bc_temp, "bcCompletion", "#{vh_all_chars}", key_bc_group)
      # BC Item
      ui_check_validation_error(key_bc_temp_item, "bcItemNote", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_bc_temp_item, "bcItemNote", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_bc_temp_item, "bcItemCompletion", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_bc_temp_item, "bcItemCompletion", "#{vh_all_chars}", key_bc_group)
      # Question
      ui_check_validation_error(key_question, "questionLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_question, "questionLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_question, "questionLabel", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_question, "questionText", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_question, "questionText", "±±±±", vh_question_error, key_bc_group)
      ui_check_validation_ok(key_question, "questionText", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_question, "questionNote", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_question, "questionNote", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_question, "questionCompletion", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_question, "questionCompletion", "#{vh_all_chars}", key_bc_group)
      # Placeholder
      ui_check_validation_error(key_placeholder, "placeholderText", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_placeholder, "placeholderText", "#{vh_all_chars}", key_bc_group)
      # Mapping
      ui_check_validation_error(key_mapping, "mappingMapping", "±±±±", vh_mapping_error, key_bc_group)
      ui_check_validation_ok(key_mapping, "mappingMapping", "#{vh_all_chars}", key_bc_group)
      # Label
      ui_check_validation_error(key_label, "labelTextLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_label, "labelTextLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_label, "labelTextLabel", "#{vh_all_chars}", key_bc_group)
      ui_check_validation_error(key_label, "labelTextText", "±±±±", vh_markdown_error, key_bc_group)
      ui_check_validation_ok(key_label, "labelTextText", "#{vh_all_chars}", key_bc_group)
      # Common Group
      ui_check_validation_error(key_common_group, "commonLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_common_group, "commonLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_common_group, "commonLabel", "#{vh_all_chars}", key_bc_group)
      # Code List Label
      ui_check_validation_error(key_bc_temp_item_cl, "clLocalLabel", "", "This field is required.", key_bc_group)
      ui_check_validation_error(key_bc_temp_item_cl, "clLocalLabel", "±±±±", vh_label_error, key_bc_group)
      ui_check_validation_ok(key_bc_temp_item_cl, "clLocalLabel", "#{vh_all_chars}", key_bc_group)
      ui_click_close
    end

    it "allows the form to be saved", js: true do
      Token.set_timeout(100) # Just make sure
      load_form("CRF TEST 1") 
      wait_for_ajax
      fill_in 'formLabel', with: "Updated And Wonderful Label"
      ui_click_save
      wait_for_ajax
      ui_click_close
      reload_form("CRF TEST 1")
      ui_check_input('formLabel', "Updated And Wonderful Label")
      ui_click_close
    end

    it "allows the edit session to be closed", js: true do
      Token.set_timeout(100) # Just make sure
      load_form("CRF TEST 1") 
      wait_for_ajax
      fill_in 'formLabel', with: "Updated And Wonderful Label No. 2"
      ui_click_close
      wait_for_ajax
      reload_form("CRF TEST 1") 
      ui_check_input('formLabel', "Updated And Wonderful Label No. 2")
      ui_click_close
    end

    it "allows the edit session to be closed indirectly, saves data", js: true do
      set_screen_size(1500, 900)
      Token.set_timeout(100) # Just make sure
      load_form("CRF TEST 1") 
      wait_for_ajax(10)
      fill_in 'formLabel', with: "Updated And Wonderful Label No. 2, 2nd Time"
      ui_click_back_button
      wait_for_ajax(10)
      reload_form("CRF TEST 1") 
      wait_for_ajax(10)
      ui_check_input('formLabel', "Updated And Wonderful Label No. 2, 2nd Time")
      ui_click_close
    end

  end

end