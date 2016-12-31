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
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BC.ttl")
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
    ui_table_row_link_click("#{label}", "History")
    expect(page).to have_content "History: #{identifier}"
    ui_table_row_link_click("#{label}", "Edit")
    fill_in 'formLabel', with: "#{new_label}"
  end

  describe "Curator User", :type => :feature do
  
    it "Basic Group and Items", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'form_edit@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms'  
      click_link 'New'
      fill_in 'form_identifier', with: 'TEST 1'
      fill_in 'form_label', with: 'Test'
      click_button 'Create'
      expect(page).to have_content 'Form was successfully created.'
      ui_table_row_link_click("Test", "History")
      expect(page).to have_content 'History: TEST 1'
      ui_table_row_link_click("Test", "Edit")
      fill_in 'formLabel', with: "New"
      
      # Group Fields and Add Group
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
      ui_click_node_name("Group 2")
      ui_check_input('groupLabel', "Group 2")
      ui_check_input('groupCompletion', "Completion for group 2")
      ui_check_input('groupNote', "Notes for group 2")
      #--pause
      
      # Common
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      ui_check_node_ordinal("Common Group", 1)
      fill_in 'commonLabel', with: "Common 1"
      ui_click_node_name("Group 1")
      ui_click_node_name("Common 1")
      ui_check_input('commonLabel', "Common 1")
      ui_click_node_name("Group 2")
      click_button 'groupAddCommon'
      expect(page).to have_content 'Group already has a common node.'
      ui_click_node_name("Common 1")
      click_button 'commonDelete'
      ui_click_node_name("Group 2")
      click_button 'groupAddCommon'
      fill_in 'commonLabel', with: "Common New 1"
      ui_click_node_name("Group 2")
      ui_click_node_name("Common New 1")
      ui_check_input('commonLabel', "Common New 1")
      
      # Question
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
      ui_click_node_name("Group 1")
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "LT 1"
      fill_in 'labelTextText', with: "* list 1\n* list 2"
      ui_click_node_name("Group 1")
      ui_check_node_ordinal("Q 1", 2)
      ui_check_node_ordinal("LT 1", 3)
      ui_click_node_name("Q 1")
      click_button "questionDown"
      #pause
      ui_check_node_ordinal("LT 1", 2)
      ui_check_node_ordinal("Q 1", 3)
      click_button "questionUp"
      ui_check_node_ordinal("Q 1", 2)
      ui_check_node_ordinal("LT 1", 3)
      ui_click_node_name("LT 1")
      click_button "labelTextDelete"
      ui_click_node_name("Q 1")
      ui_check_node_ordinal("Q 1", 2)
      #--pause
      
      # Label
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
      click_button 'markdown_preview'
      ui_check_div_text("genericCompletion", "This is a markdown label")
      ui_check_node_ordinal("LT 1", 3)
      ui_click_node_name("Group 1")
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "LT 2"
      fill_in 'labelTextText', with: "* list 1\n* list 2"
      click_button 'markdown_preview'
      ui_click_node_name("LT 1")
      ui_check_node_ordinal("LT 2", 4)
      ui_click_node_name("LT 2")
      click_button "labelTextUp"
      ui_check_node_ordinal("LT 2", 3)
      ui_check_node_ordinal("LT 1", 4)
      ui_click_node_name("LT 2")
      click_button "labelTextDelete"
      ui_click_node_name("LT 1")
      ui_check_node_ordinal("LT 1", 3)
      #--pause
            
      # Placeholder
      ui_click_node_name("Group 1")
      click_button 'groupAddPlaceholder'
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'placeholderText', with: "This is some placeholder text"
      ui_click_node_name("Group 1")
      ui_click_node_name("Placeholder 4")
      ui_check_input('placeholderText', "This is some placeholder text")
      click_button 'markdown_preview'
      ui_check_div_text("genericCompletion", "This is some placeholder text")
      ui_check_node_ordinal("Placeholder 4", 4)
      click_button "placeholderUp"
      ui_check_node_ordinal("Placeholder 4", 3)
      ui_check_node_ordinal("LT 1", 4)
      ui_click_node_name("Placeholder 4")
      click_button "placeholderDown"
      ui_check_node_ordinal("LT 1", 3)
      ui_check_node_ordinal("Placeholder 4", 4)
      click_button "placeholderDelete"
      ui_check_node_ordinal("Placeholder 4", -1)
      #pause

      # Mapping
      ui_click_node_name("Group 1")
      click_button 'groupAddMapping'
      expect(page).to have_content 'Mapping Details'
      fill_in 'mappingMapping', with: "XXX=YYY when EGTESTCD=TESTCODE"
      ui_click_node_name("Group 1")
      ui_click_node_name("Mapping 4")
      ui_check_input('mappingMapping', "XXX=YYY when EGTESTCD=TESTCODE")
      click_button "mappingUp"
      ui_check_node_ordinal("Mapping 4", 3)
      ui_check_node_ordinal("LT 1", 4)
      ui_click_node_name("Mapping 4")
      click_button "mappingDown"
      ui_check_node_ordinal("LT 1", 3)
      ui_check_node_ordinal("Mapping 4", 4)
      click_button "mappingDelete"
      ui_check_node_ordinal("Mapping 4", -1)
      #pause

    end

    it "Basic Group Delete", js: true do
      create_form("TEST 2", "T2", "Test Form No. 2")
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

    it "Basic Group and Child Group Delete", js: true do
      create_form("TEST 3", "T3", "Test Form No. 3")
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
      ui_check_node_ordinal("Group 1.1", -1)     
      ui_check_node_ordinal("Group 1", 1)     
    end

    it "allows common group to be added, prevents others being added", js: true do
      create_form("TEST 4", "T4", "Test Form No. 4")
      click_button 'formAddGroup'
      #puts ui_get_last_node
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Form No. 4")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      ui_click_node_name("Common Group")
      ui_click_node_name("Group 1")
      click_button 'groupAddCommon'
      expect(page).to have_content("Group already has a common node.")
    end

    it "allows BCs to be added", js: true do
      create_form("TEST 5", "T5", "Test Form No. 5")
      click_button 'formAddGroup'
      #puts ui_get_last_node
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Form No. 5")
      ui_click_node_name("Group 1")
      click_button 'groupAddBc'
      expect(page).to have_content("You need to select a Biomedical Concept.")
      #pause
      ui_table_row_click("bcTable", "(BC C25206)")
      click_button 'groupAddBc'
      wait_for_ajax
      ui_click_node_name("Temperature (BC C25206)")
      #pause
    end

    it "makes sure a node is selected, group", js: true do
      create_form("TEST 6", "T6", "Test Form No. 6")
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Group 1"
      ui_click_node_name("Test Form No. 5")
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

    it "shows basic screen for an empty form, makes sure form node is selected and closes with a save", js: true do
      create_form("TEST 7", "T7", "Test Form No. 7")
      expect(page).to have_content("Edit: T7 TEST 7 (, V1, Incomplete)")
      expect(page).to have_content("Form Details")
      ui_check_node_ordinal("T7", 0) 
      click_button 'clear_current_node'
      click_button 'formAddGroup'
      expect(page).to have_content('You need to select the form node.')
      ui_click_node_key(1)
      click_button 'formAddGroup'
      fill_in 'groupLabel', with: "Top Level Group"
      ui_click_node_key(1)
      click_button 'close'
      expect(page).to have_content 'History: TEST 7'
      ui_table_row_link_click("T7", "Edit")
      expect(page).to have_content("Edit: T7 TEST 7 (, V1, Incomplete)")
      ui_click_node_name("Top Level Group")
    end

    it "shows a preview markdown and the correct panels", js: true do
      create_form("TEST 8", "T8", "Test Form No. 8")
      expect(page).to have_content("Edit: T8 TEST 8 (, V1, Incomplete)")
      expect(page).to have_content("Form Details")
      ui_check_node_ordinal("T8", 0)
      expect(page).to have_content 'Form Details'
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

    it "allows questions to be updated", js: true do
      create_form("TEST 9", "T9", "Test Form No. 9")
      expect(page).to have_content("Edit: T9 TEST 9 (, V1, Incomplete)")
      expect(page).to have_content("Form Details")
      expect(page).to have_content 'Form Details'
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
      ui_click_node_name("Group 1")
      ui_click_node_name("Q 1")
      ui_check_input('questionLabel', "Q 1")
      ui_check_input('questionText', "What is?")
      ui_check_input('questionMapping', "[NOT SUBMITTED]")
      ui_check_input('questionCompletion', "Completion for question")
      ui_check_input('questionNote', "Notes for question")
      ui_click_node_name("Group 1")
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
      Notepad.create :uri_id => "CLI-C66741_C49680", :uri_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", :identifier => "C49680", 
        :useful_1 =>"FRMSIZE", :useful_2 => "Frame Size", :user_id => @user.id, :note_type => 0
      items = Notepad.where(user_id: @user.id, note_type: 0).find_each
      expect(items.count).to eq(4)
      click_button 'notepad_refresh'
      ui_click_node_key(4)
      ui_click_node_key(3)
      expect(page).to have_content 'Question Details' # Wait for page to settle
      #pause
      ui_table_row_click('questionClTable', 'C25157')
      click_button 'deleteTerm'
          
    end

  end

end