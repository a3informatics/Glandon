require 'rails_helper'
require 'selenium-webdriver'

describe "Biomedical Concept Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  include ValidationHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("CT_ACME_V1.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
      set_screen_size(1500, 900)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

  after :each do
    click_link 'logoff_button'
  end

  def open_edit_multiple
    click_link 'main_nav_bc'
    click_link 'Edit Multiple'
    wait_for_ajax(10)
  end

  def create_bc(identifier, label, template)
    #ui_scroll_to_id("biomedical_concept_identifier")
    fill_in "biomedical_concept_identifier", with: identifier
    fill_in "biomedical_concept_label", with: label
    select template, from: "biomedical_concept_uri"
    click_button 'Create'
    wait_for_ajax(3)
    #expect(page).to have_content("The Biomedical Concept was succesfully created.") 
  end

  def scroll_to_editor_table
    page.execute_script("document.getElementById('editor_table').scrollIntoView(false);")
  end

  def scroll_to_bc_table
    page.execute_script("document.getElementById('bc_table').scrollIntoView(false);")
  end

  def scroll_to_all_bc_panel
    page.execute_script("document.getElementById('all_bc_panel').scrollIntoView(false);")
  end

  def select_panel_header(panel_id)
    find(:xpath, "//*[@id=\"bc_panel_#{panel_id}\"]/div[1]").click
  end

  def select_panel_body(panel_id)
    find(:xpath, "//*[@id=\"bc_panel_#{panel_id}\"]/div[2]").click
  end

  def panel_current(panel_id)
    expect(page).to have_css("div#bc_panel_#{panel_id}.panel-success")
  end

  def panel_not_current(panel_id)
    expect(page).to_not have_css("div#bc_panel_#{panel_id}.panel-success")
  end

  def fill_question_text(row, text)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[2]").click
    fill_in "DTE_Field_question_text", with: text
    wait_for_ajax
  end

  def fill_prompt_text(row, text)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[3]").click
    fill_in "DTE_Field_prompt_text", with: text
    wait_for_ajax
  end

  def toggle_enabled(row)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[4]").click
    wait_for_ajax
  end

  def toggle_collect(row)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[5]").click
    wait_for_ajax
  end

  def fill_format(row, text)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[7]").click
    fill_in "DTE_Field_format", with: text
    wait_for_ajax
  end

  def select_terminology(row)
    find(:xpath, "//table[@id='editor_table']/tbody/tr[#{row}]/td[9]").click
    wait_for_ajax
  end

  def fill_row (row, q_text, p_text, enabled, collect, format)
    fill_question_text(row, q_text)
    fill_prompt_text(row, p_text)
    toggle_enabled(row) if enabled
    toggle_collect(row) if collect
    fill_format(row, format)
  end

  describe "Curator User, Multiple Edit", :type => :feature do
  
    it "has correct initial state", js: true do
      open_edit_multiple
      expect(page).to have_content("Edit Multiple Biomedical Concepts")
      expect(page).to have_content("All Biomedical Concepts")
      expect(page).to have_content("Current Biomedical Concept")
      expect(page).to have_content("Current Terminologies")
      expect(page).to have_content("Terminology")
      expect(page).to have_content("New")
      expect(page).to have_content("Identifier:")
      expect(page).to have_content("Label:")
      expect(page).to have_content("Template Identifier:")
      expect(page).to have_content("Add Biomedical Concept")
      expect(page).to have_content("Showing 1 to 10 of 17,363 entries")
      ui_check_page_options("temp_table", { "5" => 5, "10" => 10, "15" => 15, "20" => 20, "25" => 25, "50" => 50, "All" => -1})
      ui_button_disabled("bc_previous")
      ui_button_disabled("bc_next")
    end

    it "allows a BC to be created", js: true do
      open_edit_multiple
      create_bc("TEST BC CD", "Test BC CD Label", "Obs CD")
      expect(page).to have_content("Test BC CD Label")
      ui_check_page_options("editor_table", { "5" => 5, "10" => 10, "15" => 15, "20" => 20, "25" => 25, "50" => 50, "All" => -1})
    end

    it "allows 4 BCs being edited and visible", js: true do
      open_edit_multiple
      create_bc("TEST BC 1", "Test BC No. 1", "Obs PQR")
      create_bc("TEST BC 2", "Test BC No. 2", "Obs PQR")
      create_bc("TEST BC 3", "Test BC No. 3", "Obs PQR")
      create_bc("TEST BC 4", "Test BC No. 4", "Obs PQR")
      expect(page).to have_content("Test BC No. 1")
      expect(page).to have_content("Test BC No. 2")
      expect(page).to have_content("Test BC No. 3")
      expect(page).to have_content("Test BC No. 4")
    end

    it "allows 8 BCs to be edited", js: true do
      open_edit_multiple
      create_bc("TEST BC 11", "Test BC No. 11", "Obs PQR")
      create_bc("TEST BC 12", "Test BC No. 12", "Obs PQR")
      create_bc("TEST BC 13", "Test BC No. 13", "Obs PQR")
      create_bc("TEST BC 14", "Test BC No. 14", "Obs PQR")
      create_bc("TEST BC 15", "Test BC No. 15", "Obs PQR")
      create_bc("TEST BC 16", "Test BC No. 16", "Obs PQR")
      create_bc("TEST BC 17", "Test BC No. 17", "Obs PQR")
      create_bc("TEST BC 18", "Test BC No. 18", "Obs PQR")

      fill_in "biomedical_concept_identifier", with: "FAIL"
      fill_in "biomedical_concept_label", with: "Fail BC"
      select "Obs PQR", from: "biomedical_concept_uri"
      click_button 'Create'
      wait_for_ajax(10)
      expect(page).to have_content("") 
    end

    it "allows BCs to be moved left and right", js: true do
      open_edit_multiple
      create_bc("TEST BC 21", "Test BC No. 21", "Obs PQR")
      create_bc("TEST BC 22", "Test BC No. 22", "Obs PQR")
      create_bc("TEST BC 23", "Test BC No. 23", "Obs PQR")
      create_bc("TEST BC 24", "Test BC No. 24", "Obs PQR")
      create_bc("TEST BC 25", "Test BC No. 25", "Obs PQR")
      expect(page).to have_content("Test BC No. 22")
      expect(page).to have_content("Test BC No. 23")
      expect(page).to have_content("Test BC No. 24")
      expect(page).to have_content("Test BC No. 25")
      scroll_to_all_bc_panel
      ui_click_by_id "bc_previous"
      wait_for_ajax(5)
      expect(page).to have_content("Test BC No. 21")
      expect(page).to have_content("Test BC No. 22")
      expect(page).to have_content("Test BC No. 23")
      expect(page).to have_content("Test BC No. 24")
      ui_click_by_id "bc_next"
      wait_for_ajax(5)
      expect(page).to have_content("Test BC No. 22")
      expect(page).to have_content("Test BC No. 23")
      expect(page).to have_content("Test BC No. 24")
      expect(page).to have_content("Test BC No. 25")
    end

    it "allows BCs to be selected", js: true do
      open_edit_multiple
      create_bc("TEST BC 31", "Test BC No. 31", "Obs PQR")
      create_bc("TEST BC 32", "Test BC No. 32", "Obs PQR")
      panel_current("2")
      panel_not_current("1")
      scroll_to_all_bc_panel
      select_panel_header(1)
      panel_current("1")
      panel_not_current("2")
      select_panel_body(2)
      panel_current("2")
      panel_not_current("1")
    end

    it "allows BCs to be closed", js: true do
      open_edit_multiple
      create_bc("TEST BC 41", "Test BC No. 41", "Obs PQR")
      create_bc("TEST BC 42", "Test BC No. 42", "Obs PQR")
      expect(page).to have_content("Test BC No. 41")
      expect(page).to have_content("Test BC No. 42")
      ui_click_by_id 'bc_panel_1'
      ui_click_by_id 'bc_close_1'
      expect(page).to_not have_content("Test BC No. 41")
      expect(page).to have_content("Test BC No. 42")
    end

    it "allows BCs to be closed, greater than 4", js: true do
      open_edit_multiple
      create_bc("TEST BC 43", "Test BC No. 43", "Obs PQR")
      create_bc("TEST BC 44", "Test BC No. 44", "Obs PQR")
      create_bc("TEST BC 45", "Test BC No. 45", "Obs CD")
      create_bc("TEST BC 46", "Test BC No. 46", "Obs PQR")
      create_bc("TEST BC 47", "Test BC No. 47", "Obs PQR")
      create_bc("TEST BC 48", "Test BC No. 48", "Obs CD")
      expect(page).to have_content("Test BC No. 45")
      expect(page).to have_content("Test BC No. 46")
      expect(page).to have_content("Test BC No. 47")
      expect(page).to have_content("Test BC No. 48")
      ui_click_by_id 'bc_close_2'
      expect(page).to_not have_content("Test BC No. 46")
      expect(page).to have_content("Test BC No. 45")
      expect(page).to have_content("Test BC No. 47")
      expect(page).to have_content("Test BC No. 48")
      ui_click_by_id "bc_previous"
      expect(page).to have_content("Test BC No. 44")
      expect(page).to have_content("Test BC No. 45")
      expect(page).to have_content("Test BC No. 47")
      expect(page).to have_content("Test BC No. 48")
      ui_click_by_id 'bc_close_4'
      expect(page).to_not have_content("Test BC No. 48")
      expect(page).to have_content("Test BC No. 44")
      expect(page).to have_content("Test BC No. 45")
      expect(page).to have_content("Test BC No. 47")
    end

    
    it "allows a property to be updated", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 51", "Test BC No. 51", "Obs PQR")
      scroll_to_editor_table
      fill_row(1, "Q1\t", "P1\n", true, true, "7.2\n")
      fill_row(2, "Q2\t", "P2\n", true, true, "7.3\n")
      fill_row(3, "Q3\t", "P3\n", true, true, "8.4\n")
      fill_row(4, "Q4\t", "P4\n", true, true, "9.0\n")
    end

    it "ensures updates are saved", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 61", "Test BC No. 61", "Obs PQR")
      scroll_to_editor_table
      fill_row(1, "BC 61 Question Text\t", "P1\n", true, true, "7.2\n")
      fill_row(4, "Q4\t", "P4\n", true, true, "9.0\n")
      create_bc("TEST BC 62", "Test BC No. 62", "Obs CD")
      scroll_to_editor_table
      fill_row(2, "62 QTEXT\t", "P2\n", true, true, "7.3\n")
      fill_row(3, "Q3\t", "P3\n", true, true, "8.4\n")
      scroll_to_all_bc_panel
      select_panel_header(1)
      wait_for_ajax
      expect(page).to have_content("BC 61 Question Text")
      select_panel_header(2)
      wait_for_ajax
      expect(page).to have_content("62 QTEXT")
    end

    it "selects the terminology panel", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 71", "Test BC No. 71", "Obs CD")
      scroll_to_editor_table
      fill_row(2, "Coded Question 1\t", "P2\n", true, true, "")
      fill_row(5, "Coded Question 2\t", "P4\n", true, true, "")
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      select_terminology(5)
      wait_for_ajax
      expect(page).to have_content("Terminology: Laterality (--LAT)")
      ui_button_enabled('tfe_add_item')
      ui_button_enabled('tfe_delete_item')
      ui_button_enabled('tfe_delete_all_items')
      select_terminology(2)
      wait_for_ajax
      expect(page).to have_content("Terminology: Body Position (--POS)")
      select_terminology(3)
      wait_for_ajax
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
    end

    it "allows terminology to be added", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 81", "Test BC No. 81", "Obs CD")
      scroll_to_editor_table
      fill_row(5, "Coded Question 1\t", "P1\n", true, true, "")
      select_terminology(5)
      wait_for_ajax
      expect(page).to have_content("Terminology: Laterality (--LAT)")
      ui_button_enabled('tfe_add_item')
      ui_button_enabled('tfe_delete_item')
      ui_button_enabled('tfe_delete_all_items')
      select_terminology(4)
      expect(page).to have_content("Terminology: No Field Selected")
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
      select_terminology(5)
      wait_for_ajax
      expect(page).to have_content("Terminology: Laterality (--LAT)")
      ui_button_enabled('tfe_add_item')
      ui_button_enabled('tfe_delete_item')
      ui_button_enabled('tfe_delete_all_items')
      select_terminology(6)
      expect(page).to have_content("Terminology: No Field Selected")
      ui_button_disabled('tfe_add_item')
      ui_button_disabled('tfe_delete_item')
      ui_button_disabled('tfe_delete_all_items')
    end

    it "does not allow terminology to be added for non-coded properties", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 82", "Test BC No. 82", "Obs CD")
      scroll_to_editor_table
      fill_row(5, "Coded Question 1\t", "P1\n", true, true, "")
      select_terminology(5)
      click_button 'tfe_add_item'
      expect(page).to have_content("You need to select an item.")
      ui_table_row_double_click('searchTable', 'EQ-5D-3L TEST')
      wait_for_ajax
      ui_table_row_click('searchTable', 'C100394')
      ui_click_by_id 'tfe_add_item'
      wait_for_ajax
    end

    it "allows BC creation, form validation", js: true do
      open_edit_multiple
      fill_in "biomedical_concept_identifier", with: ''
      fill_in "biomedical_concept_label", with: 'Well this is not going well'
      select "Obs PQR", from: "biomedical_concept_uri"
      click_button 'Create'
      expect(page).to have_content 'The form is not valid. Please correct the errors.'
      expect(page).to have_content 'This field is required.'
      
      fill_in "biomedical_concept_identifier", with: 'A12345 XXX§'
      fill_in "biomedical_concept_label", with: 'Well this is not going well'
      select "Obs PQR", from: "biomedical_concept_uri"
      click_button 'Create'
      expect(page).to have_content 'The form is not valid. Please correct the errors.'
      expect(page).to have_content 'Please enter a valid identifier. Upper and lower case alphanumeric and space characters only.'
      
      fill_in 'Identifier', with: 'A12345'
      click_button 'Create'
      expect(page).to have_content 'The Biomedical Concept was succesfully created.'
      
      fill_in "biomedical_concept_identifier", with: 'A12346'
      fill_in "biomedical_concept_label", with: ''
      select "Obs PQR", from: "biomedical_concept_uri"
      click_button 'Create'
      expect(page).to have_content 'This field is required.'
      
      fill_in "biomedical_concept_label", with: '±±±'
      click_button 'Create'
      expect(page).to have_content vh_label_error
      
      fill_in "biomedical_concept_label", with: vh_all_chars
      click_button 'Create'
      expect(page).to have_content "The Biomedical Concept was succesfully created."
      
      scroll_to_all_bc_panel
      click_button 'close_button'
    end

    it "allows BC creation, form validation", js: true do
      open_edit_multiple
      create_bc("TEST BC 91", "Test BC No. 91", "Obs CD")
      scroll_to_editor_table
      fill_question_text(2, "±±±±\n")
      wait_for_ajax
      expect(page).to have_content("contains invalid characters")
      fill_in "DTE_Field_question_text", with: "good stuff\n"
      wait_for_ajax
      fill_prompt_text(2, "±±±±\t")
      expect(page).to have_content("contains invalid characters")
      fill_in "DTE_Field_prompt_text", with: "some really good stuff\n"
      wait_for_ajax
      fill_format(2, "1.0\n")
      #fill_in "DTE_Field_format", with: "1.0\n"
      wait_for_ajax
      fill_format(4, "vv\t")
      expect(page).to have_content("contains invalid characters")
      fill_in "DTE_Field_format", with: "1.0\t"
      wait_for_ajax
    end

    it "allows the edit session to be closed", js: true do
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 92", "Test BC No. 92", "Obs CD")
      scroll_to_all_bc_panel
      click_button 'close_button'
      expect(page).to have_content("Index: Biomedical Concepts")
    end

    it "edit clears token on close", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 101", "Test BC No. 101", "Obs CD")
      create_bc("TEST BC 102", "Test BC No. 102", "Obs CD")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC101")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      page.find("#token_timer_2")[:class].include?("btn-warning")
      scroll_to_all_bc_panel
      click_button 'close_button'
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC101")
      expect(tokens).to match_array([])
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC102")
      expect(tokens).to match_array([])
    end  

    it "edit clears token on back button", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 103", "Test BC No. 103", "Obs CD")
      create_bc("TEST BC 104", "Test BC No. 104", "Obs CD")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC103")
      token = tokens[0]
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      page.find("#token_timer_2")[:class].include?("btn-warning")
      ui_click_back_button
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC103")
      expect(tokens).to match_array([])
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_TESTBC104")
      expect(tokens).to match_array([])
    end 

    it "edit timeout warnings", js: true do
      Token.set_timeout(@user_c.edit_lock_warning.to_i + 10)
      set_screen_size(1500, 900)
      open_edit_multiple
      create_bc("TEST BC 105", "Test BC No. 105", "Obs CD")
      create_bc("TEST BC 106", "Test BC No. 106", "Obs CD")
      scroll_to_all_bc_panel
      # Initial state
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      ui_button_disabled('token_timer_2')
      page.find("#token_timer_1")[:class].include?("btn-success")
      page.find("#token_timer_2")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      # Warning state
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      page.find("#token_timer_2")[:class].include?("btn-warning")
      click_button 'bc_save'
      # Initial state
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      ui_button_disabled('token_timer_2')
      page.find("#token_timer_1")[:class].include?("btn-success")
      page.find("#token_timer_2")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      # Warning state
      sleep Token.get_timeout - @user_c.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      page.find("#token_timer_2")[:class].include?("btn-warning")
      # Danger state
      sleep (@user_c.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer_1")[:class].include?("btn-danger")
      page.find("#token_timer_2")[:class].include?("btn-danger")
      sleep (@user_c.edit_lock_warning.to_i / 2)
      ui_button_label("token_timer_1", "00:00")
      ui_button_label("token_timer_2", "00:00")
      click_button 'close_button'
    end  
    
  end

end