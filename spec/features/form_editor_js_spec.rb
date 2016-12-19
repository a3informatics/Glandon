require 'rails_helper'
require 'selenium-webdriver'

describe "Form Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    @user = User.create :email => "form_edit@example.com", :password => "12345678" 
    @user.add_role :curator
    #Capybara.current_driver = :selenium
  end

  after :all do
    user = User.where(:email => "form_edit@example.com").first
    user.destroy
    #Capybara.use_default_driver
  end

  describe "Curator User", :type => :feature do
  
    it "Form Editing, Group", js: true do
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
      ui_table_row_link_clink("Test", "History")
      expect(page).to have_content 'History: TEST 1'
      ui_table_row_link_clink("Test", "Edit")
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
      #--pause
      ui_click_node("Group 1")
      ui_check_input('groupLabel', "Group 1")
      ui_check_input('groupCompletion', "Completion for group 1")
      ui_check_input('groupNote', "Notes for group 1")
      ui_click_node("Group 2")
      ui_check_input('groupLabel', "Group 2")
      ui_check_input('groupCompletion', "Completion for group 2")
      ui_check_input('groupNote', "Notes for group 2")
      #--pause
      
      # Common
      click_button 'groupAddCommon'
      expect(page).to have_content 'Common Group Details'
      ui_check_node_ordinal("Common", 1)
      fill_in 'commonLabel', with: "Common 1"
      ui_click_node("Group 1")
      ui_click_node("Common 1")
      ui_check_input('commonLabel', "Common 1")
      ui_click_node("Group 2")
      click_button 'groupAddCommon'
      expect(page).to have_content 'Group already has a common node.'
      ui_click_node("Common 1")
      click_button 'commonDelete'
      ui_click_node("Group 2")
      click_button 'groupAddCommon'
      fill_in 'commonLabel', with: "Common New 1"
      ui_click_node("Group 2")
      ui_click_node("Common New 1")
      ui_check_input('commonLabel', "Common New 1")
      #--pause
      
      # Question
      ui_click_node("Group 1")
      click_button 'groupAddQuestion'
      #pause
      expect(page).to have_content 'Question Details'
      expect(page).to have_content 'Notepad'
      fill_in 'questionLabel', with: "Q 1"
      fill_in 'questionText', with: "What is?"
      check 'questionOptional'  
      fill_in 'questionMapping', with: "[NOT SUBMITTED]"
      choose 'form_datatype_s'
      fill_in 'questionCompletion', with: "Completion for question"
      fill_in 'questionNote', with: "Notes for question"
      ui_click_node("Group 1")
      #pause
      ui_click_node("Q 1")
      ui_check_input('questionLabel', "Q 1")
      ui_check_input('questionText', "What is?")
      ui_check_input('questionMapping', "[NOT SUBMITTED]")
      ui_check_input('questionCompletion', "Completion for question")
      ui_check_input('questionNote', "Notes for question")
      #pause
      ui_click_node("Group 1")
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "LT 1"
      fill_in 'labelTextText', with: "* list 1\n* list 2"
      ui_click_node("Group 1")
      #pause
      ui_check_node_ordinal("Q 1", 2)
      ui_check_node_ordinal("LT 1", 3)
      ui_click_node("Q 1")
      click_button "questionDown"
      ui_check_node_ordinal("LT 1", 2)
      ui_check_node_ordinal("Q 1", 3)
      click_button "questionUp"
      ui_check_node_ordinal("Q 1", 2)
      ui_check_node_ordinal("LT 1", 3)
      #pause
      ui_click_node("LT 1")
      click_button "labelTextDelete"
      #pause
      ui_click_node("Q 1")
      ui_check_node_ordinal("Q 1", 2)
      #--pause
      
      # Label
      ui_click_node("Group 1")
      click_button 'groupAddLabelText'
      expect(page).to have_content 'Label Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'labelTextLabel', with: "LT 1"
      fill_in 'labelTextText', with: "This is a markdown label"
      ui_click_node("Group 1")
      ui_click_node("LT 1")
      ui_check_input('labelTextLabel', "LT 1")
      ui_check_input('labelTextText', "This is a markdown label")
      click_button 'markdown_preview'
      ui_check_div_text("genericCompletion", "This is a markdown label")
      pause
      ui_check_node_ordinal("LT 1", 3)
      pause
      ui_click_node("Group 1")
      click_button 'groupAddLabelText'
      fill_in 'labelTextLabel', with: "LT 2"
      fill_in 'labelTextText', with: "* list 1\n* list 2"
      click_button 'markdown_preview'
      ui_click_node("LT 1")
      #pause
      ui_check_node_ordinal("LT 2", 4)
      ui_click_node("LT 2")
      #pause
      click_button "labelTextUp"
      #pause
      ui_check_node_ordinal("LT 2", 3)
      ui_check_node_ordinal("LT 1", 4)
      #pause
      ui_click_node("LT 2")
      click_button "labelTextDelete"
      #pause
      ui_click_node("LT 1")
      ui_check_node_ordinal("LT 1", 3)
      #--pause
            
      # Placeholder
      ui_click_node("Group 1")
      click_button 'groupAddPlaceholder'
      expect(page).to have_content 'Placeholder Details'
      expect(page).to have_content 'Markdown Preview'
      fill_in 'placeholderText', with: "This is some placeholder text"
      ui_click_node("Group 1")
      ui_click_node("Placeholder 4")
      #pause
      ui_check_input('placeholderText', "This is some placeholder text")
      click_button 'markdown_preview'
      ui_check_div_text("genericCompletion", "This is some placeholder text")
      ui_check_node_ordinal("Placeholder 4", 4)
      #pause
      click_button "placeholderUp"
      #pause
      ui_check_node_ordinal("Placeholder 4", 3)
      ui_check_node_ordinal("LT 1", 4)
      ui_click_node("Placeholder 4")
      #pause
      click_button "placeholderDown"
      ui_check_node_ordinal("LT 1", 3)
      ui_check_node_ordinal("Placeholder 4", 4)
      #pause
      click_button "placeholderDelete"
      #pause
      ui_check_node_ordinal("Placeholder 4", -1)
      #pause

      # Mapping
      ui_click_node("Group 1")
      click_button 'groupAddMapping'
      expect(page).to have_content 'Mapping Details'
      fill_in 'mappingMapping', with: "XXX=YYY when EGTESTCD=TESTCODE"
      ui_click_node("Group 1")
      ui_click_node("Mapping 4")
      #pause
      ui_check_input('mappingMapping', "XXX=YYY when EGTESTCD=TESTCODE")
      click_button "mappingUp"
      #pause
      ui_check_node_ordinal("Mapping 4", 3)
      ui_check_node_ordinal("LT 1", 4)
      ui_click_node("Mapping 4")
      #pause
      click_button "mappingDown"
      ui_check_node_ordinal("LT 1", 3)
      ui_check_node_ordinal("Mapping 4", 4)
      #pause
      click_button "mappingDelete"
      #pause
      ui_check_node_ordinal("Mapping 4", -1)
      #pause
    end

  end

end