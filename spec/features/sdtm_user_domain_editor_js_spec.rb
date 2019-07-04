require 'rails_helper'
require 'selenium-webdriver'

describe "SDTM User Domain Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ValidationHelpers
  include DomainHelpers

  before :all do
    Token.destroy_all
    Token.set_timeout(5)
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
    clear_token_object
    @user = User.create :email => "domain_edit@example.com", :password => "12345678" 
    @user.add_role :curator
  end

  after :all do
    user = User.where(:email => "domain_edit@example.com").first
    user.destroy
    Token.restore_timeout
  end

  after :each do
    click_link 'logoff_button'
  end

  describe "Curator User", :type => :feature do
  
    it "has correct initial state", js: true do
      load_domain("DM Domain")
      expect(page).to have_content("Edit: Demographics DM Domain (V0.1.0, 1, Incomplete)")
      expect(page).to have_content("Domain Details")
      expect(page).to have_content("V+")
      expect(page).to have_content("Save")
      expect(page).to have_content("Close")
      ui_click_node_key(1)
      ui_check_disabled_input('domainPrefix', "DM")
      ui_check_input('domainLabel', "Demographics")
    end

    it "allows a domain to be defined, Domain Panel", js: true do
      load_domain("DM Domain")
      fill_in 'domainNotes', with: "Notes for *domain* that tell the whole story"
      ui_click_node_name("AGE")
      ui_click_node_name("Demographics")
      ui_check_input('domainLabel', "Demographics")
      ui_check_input('domainNotes', "Notes for *domain* that tell the whole story")
    end

    it "disables variable name, label datatype, compliance and classification for standard variables", js: true do
      load_domain("DM Domain")
      ui_click_node_name("AGE")
      ui_check_disabled_input('variableName', "AGE")
      ui_check_disabled_input('variableLabel', "Age")
      ui_check_disabled_input('variableDatatype', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_DT_NUM")
      ui_check_disabled_input('variableCompliance', "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG_C_EXPECTED")
      ui_check_disabled_input('variableClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER")
      ui_check_disabled_input('variableSubClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER_SC_RECORDQUALIFIER")
    end

    it "displays the classification and sub-classifications", js: true do
      load_domain("DM Domain")
      ui_click_node_name("AGE")
      ui_check_disabled_input('variableClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER")
      ui_check_disabled_input('variableSubClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER_SC_RECORDQUALIFIER")
      ui_click_node_name("DMDTC")
      ui_check_disabled_input('variableClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_TIMING")
      ui_check_disabled_input('variableSubClassification', "")
    end

    it "allows variable details to be updated", js: true do
      load_domain("DM Domain")
      ui_click_node_name("SITEID")
      fill_in 'variableFormat', with: "ISO 3333"
      fill_in 'variableNotes', with: "Some notes for the site id"
      fill_in 'variableComment', with: "Some comments for the site id"
      ui_click_node_name("ARMCD")
      ui_click_node_name("SITEID")
      ui_check_input('variableFormat', "ISO 3333")
      ui_check_input('variableNotes', "Some notes for the site id")
      ui_check_input('variableComment', "Some comments for the site id")
    end

    it "allows a non-standard variable to be added and deleted", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_variable = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_variable).not_to eq(-1)
      fill_in 'variableName', with: "DMNEW"
      fill_in 'variableLabel', with: "New label"
      fill_in 'variableFormat', with: "ISO 1234"
      fill_in 'variableNotes', with: "This is a new variable"
      fill_in 'variableComment', with: "Some comments for the new kid"
      select "Num", :from => "variableDatatype"         
      select "Expected", :from => "variableCompliance"         
      select "Qualifier", :from => "variableClassification"
      wait_for_ajax
      select "Grouping Qualifier", :from => "variableSubClassification"
      ui_click_node_name("ARM")
      wait_for_ajax
      ui_click_node_name("DMNEW")
      ui_check_input('variableName', "DMNEW")
      ui_check_input('variableLabel', "New label")
      ui_check_input('variableFormat', "ISO 1234")
      ui_check_input('variableNotes', "This is a new variable")
      ui_check_input('variableComment', "Some comments for the new kid")  
      ui_check_input('variableDatatype', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_DT_NUM")
      click_button 'variableDelete'
      key_variable = ui_get_key_by_path('["Demographics", "DMNEW"]')
      expect(key_variable).to eq(-1)
    end  

    it "allows non-standard variable details to be updated", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_variable = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_variable).not_to eq(-1)
      fill_in 'variableName', with: "DMNEW"
      fill_in 'variableLabel', with: "New label"
      ui_click_node_name("ARM")
      #wait_for_ajax
      ui_click_node_name("DMNEW")
      #wait_for_ajax
      ui_check_input('variableName', "DMNEW")
      ui_check_input('variableLabel', "New label")
      fill_in 'variableLabel', with: "New label updated"
      ui_click_node_name("Demographics")      
      #wait_for_ajax
      ui_click_node_name("DMNEW")
      ui_check_input('variableLabel', "New label updated")    
      click_button 'variableDelete'
      ui_click_by_id 'save'
      wait_for_ajax(10)
      ui_click_by_id 'close'
      expect(page).to have_content 'History:' # Ensure server stays around to save changes, needed for next test (bit naughty)
    end

    it "allows non-standard variable to be moved up and down and not pass a standard variable", js: true do
      load_domain("DM Domain")
      click_button "V+"
      expect(page).to have_content 'DM000029'
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).not_to eq(-1)
      ui_click_node_name("Demographics")
      click_button "V+"
      expect(page).to have_content 'DM000030'
      key_2 = ui_get_key_by_path('["Demographics", "DM000030"]')
      expect(key_2).not_to eq(-1)
      ui_click_node_name("Demographics")
      click_button "V+"
      expect(page).to have_content 'DM000031'
      key_3 = ui_get_key_by_path('["Demographics", "DM000031"]')
      ui_click_node_key(key_3)
      #wait_for_ajax
      click_button 'variableUp'
      ui_check_node_ordinal(key_1, 29)
      ui_check_node_ordinal(key_3, 30)
      ui_check_node_ordinal(key_2, 31)
      click_button 'variableUp'
      ui_check_node_ordinal(key_3, 29)
      ui_check_node_ordinal(key_1, 30)
      ui_check_node_ordinal(key_2, 31)
      click_button 'variableUp'
      expect(page).to have_content 'You cannot move the node up past a standard variable.'
      click_button 'variableDown'
      ui_check_node_ordinal(key_1, 29)
      ui_check_node_ordinal(key_3, 30)
      ui_check_node_ordinal(key_2, 31)
      click_button 'variableDown'
      ui_check_node_ordinal(key_1, 29)
      ui_check_node_ordinal(key_2, 30)
      ui_check_node_ordinal(key_3, 31)
      click_button 'variableDown'
      expect(page).to have_content 'You cannot move the node down.'
      ui_click_node_key(key_1)
      #wait_for_ajax
      click_button 'variableUp'
      expect(page).to have_content 'You cannot move the node up past a standard variable.'
    end

    it "allows markdown for the notes and comments", js: true do
      load_domain("DM Domain")
      ui_click_node_name("DTHFL")
      wait_for_ajax
      ui_check_disabled_input('variableLabel', "Subject Death Flag")
      ui_set_focus('variableNotes')
      expect(page).to have_content 'Markdown Preview'
      fill_in 'variableNotes', with: "*Hello* World! Also add soem single quotes 'like' this."
      click_button 'markdown_preview'
      wait_for_ajax
      ui_check_div_text('genericMarkdown', "Hello World! Also add soem single quotes 'like' this.")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
      fill_in 'variableComment', with: 'And now for smething completely different ... and some double quotes "here".'
      click_button 'markdown_preview'
      wait_for_ajax
      ui_check_div_text('genericMarkdown', "And now for smething completely different ... and some double quotes \"here\".")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
    end

    it "prevents a standard variable from being deleted", js: true do
      load_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "SITEID"]')
      ui_click_node_key(key_1)
      wait_for_ajax
      ui_button_disabled('variableDelete')
    end

    it "allows the fields to be valdated", js: true do
      clone_domain("XX")
      wait_for_ajax
      # Keys
      key_domain = ui_get_key_by_path('["Cloned EG"]')
      key_variable = ui_get_key_by_path('["Cloned EG", "DOMAIN"]')
      other_variable = ui_get_key_by_path('["Cloned EG", "STUDYID"]')
      # Domain
      ui_check_validation_error(key_domain, "domainLabel", "", "This field is required.", other_variable)
      ui_check_validation_error(key_domain, "domainLabel", "±±±±", vh_label_error, other_variable)
      ui_check_validation_ok(key_domain, "domainLabel", "#{vh_all_chars}", other_variable)
      ui_check_validation_error(key_domain, "domainNotes", "±±±±", vh_markdown_error, other_variable)
      ui_check_validation_ok(key_domain, "domainNotes", "#{vh_all_chars}", other_variable)
      # Group
      ui_check_validation_error(key_variable, "variableNotes", "±±±±", vh_markdown_error, other_variable)
      ui_check_validation_ok(key_variable, "variableNotes", "#{vh_all_chars}", other_variable)
      ui_check_validation_error(key_variable, "variableComment", "±±±±", vh_markdown_error, other_variable)
      ui_check_validation_ok(key_variable, "variableComment", "#{vh_all_chars}", other_variable)
    end

    it "allows the edit session to be saved", js: true do
      load_domain("DM Domain")
      click_button "V+"
      sleep 0.5
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
#puts("KEY 1: #{key_1}")
      expect(key_1).not_to eq(-1)
      ui_click_save
      #pause
      ui_click_close
      reload_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      ui_click_node_key(key_1)
      expect(key_1).not_to eq(-1)
    end

    it "allows the edit session to be closed", js: true do
      load_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "STUDYID"]')
      ui_click_node_key(key_1)
      fill_in 'variableComment', with: "Some comments for the **STUDYID** varaible"
      ui_click_close
      reload_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "STUDYID"]')
      ui_click_node_key(key_1)
      ui_check_input('variableComment', "Some comments for the **STUDYID** varaible")
    end

    it "allows the edit session to be closed indirectly, saves data", js: true do
      load_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "STUDYID"]')
      ui_click_node_key(key_1)
      fill_in 'variableComment', with: "Some comments for the **STUDYID** varaible"
      ui_click_back_button
      reload_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "STUDYID"]')
      ui_click_node_key(key_1)
      ui_check_input('variableComment', "Some comments for the **STUDYID** varaible")
    end

    it "domain edit timeout warnings and expiration", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_domain("DM Domain")
      wait_for_ajax
      expect(page).to have_content("Edit: Demographics DM Domain (V0.1.0, 1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      token = tokens[0]
      Capybara.ignore_hidden_elements = false
      ui_button_disabled('token_timer_1')
      page.find("#token_timer_1")[:class].include?("btn-success")
      Capybara.ignore_hidden_elements = true
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("The edit lock is about to timeout!")
      sleep 5
      page.find("#token_timer_1")[:class].include?("btn-danger")
      sleep (@user.edit_lock_warning.to_i / 2)
      expect(page).to have_content("00:00")
      expect(token.timed_out?).to eq(true)
    end

    it "domain edit timeout warnings and extend", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_domain("DM Domain")
      wait_for_ajax
      expect(page).to have_content("Edit: Demographics DM Domain (V0.1.0, 1, Incomplete)")
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      token = tokens[0]
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
      load_domain("DM Domain")
      wait_for_ajax
      expect(page).to have_content("Edit: Demographics DM Domain (V0.1.0, 1, Incomplete)")
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      click_button 'Close'
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      expect(tokens).to match_array([])
    end  

    it "edit clears token on back button", js: true do
      Token.set_timeout(@user.edit_lock_warning.to_i + 10)
      load_domain("DM Domain")
      wait_for_ajax
      expect(page).to have_content("Edit: Demographics DM Domain (V0.1.0, 1, Incomplete)")
      sleep Token.get_timeout - @user.edit_lock_warning.to_i + 2
      page.find("#token_timer_1")[:class].include?("btn-warning")
      ui_click_back_button
      wait_for_ajax
      tokens = Token.where(item_uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      expect(tokens).to match_array([])
    end  

  end

end