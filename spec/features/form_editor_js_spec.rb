require 'rails_helper'
require 'selenium-webdriver'

describe "Form Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper

  before :all do
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
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_crf.ttl")
    @user = User.create :email => "form_edit@example.com", :password => "12345678" 
    @user.add_role :curator
    Notepad.create :uri_id => "CLI-C66741_C25157", :uri_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :identifier => "C25157", 
      :useful_1 =>"BSA", :useful_2 => "Body Surface Area", :user_id => @user.id, :note_type => 0
    Notepad.create :uri_id => "CLI-C66741_C16358", :uri_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :identifier => "C16358", 
      :useful_1 =>"BMI", :useful_2 => "Body Mass Index", :user_id => @user.id, :note_type => 0
    Notepad.create :uri_id => "CLI-C66741_C49677", :uri_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :identifier => "C49677", 
      :useful_1 =>"HR", :useful_2 => "Heart Rate", :user_id => @user.id, :note_type => 0
  end

  after :all do
    Notepad.destroy_all
    user = User.where(:email => "form_edit@example.com").first
    user.destroy
  end

  def create_form(identifier, label, new_label)
    visit '/users/sign_in'
    fill_in 'Email', with: 'form_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Forms'
    expect(page).to have_content 'Index: Forms'  
    click_link 'New'
    fill_in 'form_identifier', with: "#{identifier}"
    fill_in 'form_label', with: "#{label}"
    click_button 'Create'
    expect(page).to have_content 'Form was successfully created.'
    ui_main_show_all
    ui_table_row_link_click("#{identifier}", "History")
    expect(page).to have_content "History: #{identifier}"
    ui_table_row_link_click("#{identifier}", "Edit")
    fill_in 'formLabel', with: "#{new_label}"
  end

  def load_form(identifier)
    visit '/users/sign_in'
    fill_in 'Email', with: 'form_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Forms'
    expect(page).to have_content 'Index: Forms'  
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
  end

  describe "Curator User", :type => :feature do
  
    it "has correct initial state", js: true do
      create_form("TEST INITIAL", "Initial", "Initial Layout Test") 
      expect(page).to have_content("Edit: Initial TEST INITIAL (, V1, Incomplete)")
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
      create_form("TEST 1", "Test", "Test 1") 
      fill_in 'formCompletion', with: "Completion for the form **level**"
      fill_in 'formNote', with: "Notes for *form*"
      click_button 'formAddGroup'
      ui_click_node_name("Test 1")
      ui_check_input('formLabel', "Test 1")
      ui_check_input('formCompletion', "Completion for the form **level**")
      ui_check_input('formNote', "Notes for *form*")
    end

    it "allows a group to be added, Group Panel", js: true do
      create_form("TEST 2", "Test", "Test 2") 
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
      expect(page).to have_content 'Notepad'
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
      load_form("CRF Test") 
      #key = ui_get_key_by_path('["CRF Test Form"]')
      #expect(key).to eq(1)
      #key = ui_get_key_by_path('["CRF Test Form", "BC Group"]')
      #expect(key).to eq(2)
      key = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Date and Time (--DTC)"]')
      #expect(key).to eq(4)
      ui_click_node_key(key)
      expect(page).to have_content 'Common Item Details'
    end

    it "allows items to be moved up and down", js: true do
      load_form("CRF Test") 
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
      load_form("CRF Test") 
      key1 = ui_get_key_by_path('["CRF Test Form", "Q Group"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "Q Repeating Group"]')
      ui_click_node_key(key1)
      click_button "groupDown"
      ui_check_node_ordinal(key1, 4)
      click_button "groupUp"
      ui_check_node_ordinal(key1, 3)
    end

    it "shows a preview markdown and the correct panels", js: true do
      create_form("TEST 8", "Test", "Test 8")
      expect(page).to have_content("Form Details")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      expect(page).to have_content 'Biomedical Concept Selection'
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      expect(page).to have_content 'Notepad'
      ui_click_node_key(2)
      click_button 'groupAddMapping'
      expect(page).to have_content 'Mapping Details'
      ui_click_node_key(2)
      click_button 'groupAddLabelText'
      expect(page).to have_content 'Label Details'
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(2)
      click_button 'groupAddPlaceholder'
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      ui_click_node_key(2)
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details'
      expect(page).to have_content 'Notepad'
      ui_set_focus('questionCompletion')
      expect(page).to have_content 'Markdown Preview'
      ui_is_not_visible("#notepad_panel")
      fill_in 'questionCompletion', with: "*Hello* World!"
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "Hello World!")
      click_button 'markdown_hide'
      expect(page).to have_content 'Notepad'
      expect(page).to have_no_content 'Markdown Preview'
      fill_in 'questionNote', with: "And now for smething completely different ..."
      click_button 'markdown_preview'
      ui_check_div_text('genericCompletion', "And now for smething completely different ...")
      click_button 'markdown_hide'
      expect(page).to have_content 'Notepad'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(4)
      expect(page).to have_content 'Mapping Details'
      expect(page).to have_no_content 'Markdown Preview'
      ui_click_node_key(5)
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
      click_button 'clear_current_node'
      click_button 'groupAddGroup'
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

    it "allows questions to be updated, check enable and disable on the panel", js: true do
      create_form("TEST QUESTION 1", "Test", "Test Question 1")
      click_button 'formAddGroup'
      expect(page).to have_content 'Group Details'
      expect(page).to have_content 'Biomedical Concept Selection'
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      expect(page).to have_content 'Notepad'
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
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_s'
      ui_check_input('questionFormat', "20")
      ui_button_enabled('notepad_add')
      ui_button_enabled('deleteTerm')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_f'
      ui_check_input('questionFormat', "6.2")
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
      ui_field_enabled('questionFormat')
      choose 'form_datatype_b'
      ui_field_disabled('questionFormat')
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
      choose 'form_datatype_d'
      ui_field_disabled('questionFormat')
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
      ui_field_disabled('questionFormat')
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
      choose 'form_datatype_d+t'
      ui_field_disabled('questionFormat')
      ui_button_disabled('notepad_add')
      ui_button_disabled('deleteTerm')
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
      click_button 'notepad_add'
      expect(page).to have_content("You need to select a notepad item.")
      ui_table_row_click('notepad_table', 'C16358')
      click_button 'notepad_add'
      ui_click_node_key(4)
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details' # Wait for page to settle
      ui_table_row_click('notepad_table', 'C25157')
      click_button 'notepad_add'
      ui_click_node_key(4)
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details' # Wait for page to settle
      ui_table_row_click('questionClTable', 'C25157')
      ui_table_row_click('questionClTable', 'C16358')
      click_button 'deleteTerm'
      click_button 'deleteTerm'
      expect(page).to have_content("You need to select a code list item.")
      ui_click_node_name("Q 1")
      #pause
      click_button "questionDelete"
      key = ui_get_key_by_name("Q 1")
      expect(key).to eq(-1)
    end

    it "allows the notepad to be refreshed", js: true do
      create_form("TEST QUESTION 2", "Test", "Test Question 2")
      click_button 'formAddGroup'
      click_button 'groupAddQuestion'
      expect(page).to have_content 'Question Details'
      expect(page).to have_content 'Notepad'
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
      Notepad.create :uri_id => "CLI-C66741_C49680", :uri_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :identifier => "C49680", 
        :useful_1 =>"FRMSIZE", :useful_2 => "Frame Size", :user_id => @user.id, :note_type => 0
      items = Notepad.where(user_id: @user.id, note_type: 0).find_each
      expect(items.count).to eq(4)
      click_button 'notepad_refresh'
      ui_click_node_key(3)
      expect(page).to have_content 'C49680' # Wait for page to settle
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
      ui_click_node_name("Temperature (BC C25206)")
      expect(page).to have_content("Biomedical Concept Details")
      expect(page).to have_content("Temperature (BC C25206)")
      ui_click_node_name("Group 1")
      ui_table_row_click("bcTable", "(BC C25208)")
      click_button 'groupAddBc'
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
      click_button "itemRestore"
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Common Group", "Date and Time (--DTC)"]')
      expect(key).to eq(-1)
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Temperature (BC C25206)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
      key = ui_get_key_by_path('["Test BC 2", "Group 1", "Weight (BC C25208)", "Date and Time (--DTC)"]')
      ui_check_node_is_common(key,"not common")
    end
    
    it "allows items to be made common when BC added"

    it "allows common items to be moved up and down", js: true do
      load_form("CRF Test") 
      key1 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Date and Time (--DTC)"]')
      key2 = ui_get_key_by_path('["CRF Test Form", "BC Group", "Common Group", "Body Position (--POS)"]')
      ui_click_node_key(key1)
      #pause
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

    it "allows BCs to have completion instructions and notes"
    
    it "allows a BC property to have enabled and optional, completion instructions and notes"
    
    it "allows the form to be saved"
      #click_button 'close'
      #expect(page).to have_content 'History: TEST INITIAL'
      #ui_table_row_link_click("TEST INITIAL", "Edit")
      #expect(page).to have_content("Edit: Initial Layout Test TEST INITIAL (, V1, Incomplete)")
      #ui_click_node_name("Top Level Group")

    it "allows the fields to be valdated"

    it "allows the CL to be moved up and down for BCs" 

    it "displays the CL Item Panel for BCs" 

    it "displays the CL Item Panel for Questions" 

    it "allows the CL to be moved up and down for Questions" 

  end

end