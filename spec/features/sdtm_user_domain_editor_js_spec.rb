require 'rails_helper'
require 'selenium-webdriver'

describe "SDTM User Domain Editor", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper

  C_ALL_CHARS = "the dirty brown fox jumps over the lazy dog. " + 
    "THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>"
  C_LABEL_ERROR = "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
  C_MARKDOWN_ERROR = "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&|<> special characters and return only."
  
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
    load_schema_file_into_triple_store("BusinessDomain.ttl")
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
    @user = User.create :email => "domain_edit@example.com", :password => "12345678" 
    @user.add_role :curator
  end

  after :all do
    user = User.where(:email => "domain_edit@example.com").first
    user.destroy
  end

  def clone_domain(prefix)
    visit '/users/sign_in'
    expect(page).to have_content 'Log in'  
    fill_in 'Email', with: 'domain_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'
    visit 'sdtm_ig_domains/IG-CDISC_SDTMIGEG?sdtm_ig_domain[namespace]=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
    click_link 'Clone'
    expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (3.2, V3, Standard)'
    ui_check_input('sdtm_user_domain_prefix', 'EG')
    fill_in 'sdtm_user_domain_prefix', with: "#{prefix}"
    fill_in 'sdtm_user_domain_label', with: "Cloned EG"
    click_button 'Clone'   
    expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
    expect(page).to have_content "Cloned EG"
    find(:xpath, "//tr[contains(.,'#{prefix} Domain')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'
    find(:xpath, "//tr[contains(.,'#{prefix} Domain')]/td/a", :text => 'Edit').click
  end

  def load_domain(identifier)
    visit '/users/sign_in'
    expect(page).to have_content 'Log in'  
    fill_in 'Email', with: 'domain_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Domains'
    expect(page).to have_content 'Index: Domains'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'
    #pause
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
  end

  describe "Curator User", :type => :feature do
  
    it "has correct initial state", js: true do
      load_domain("DM Domain")
      expect(page).to have_content("Edit: Demographics DM Domain (, V1, Incomplete)")
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
      ui_check_disabled_input('variableCompliance', "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#IG-CDISC_SDTMIGDM_C_EXPECTED")
      ui_check_disabled_input('variableClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER")
      ui_check_disabled_input('variableSubClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_SC_RECORDQUALIFIER")
    end

    it "displays the classification and sub-classifications", js: true do
      load_domain("DM Domain")
      ui_click_node_name("AGE")
      ui_check_disabled_input('variableClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_C_QUALIFIER")
      ui_check_disabled_input('variableSubClassification', "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_SC_RECORDQUALIFIER")
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

    it "allows a non-standard variable to be added", js: true do
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
    end  

    it "allows non-standard variable details to be updated", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_variable = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_variable).not_to eq(-1)
      fill_in 'variableName', with: "DMNEW"
      fill_in 'variableLabel', with: "New label"
      ui_click_node_name("ARM")
      ui_click_node_name("DMNEW")
      ui_check_input('variableName', "DMNEW")
      ui_check_input('variableLabel', "New label")
      fill_in 'variableLabel', with: "New label updated"
      ui_click_node_name("Demographics")      
      ui_click_node_name("DMNEW")
      ui_check_input('variableLabel', "New label updated")
    end

    it "allows non-standard variable to be moved up and down", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).not_to eq(-1)
      ui_click_node_name("Demographics")
      click_button "V+"
      key_2 = ui_get_key_by_path('["Demographics", "DM000030"]')
      expect(key_2).not_to eq(-1)
      ui_click_node_key(key_2)
      click_button 'variableUp'
      ui_check_node_ordinal(key_2, 29)
      ui_check_node_ordinal(key_1, 30)
      click_button 'variableUp'
      expect(page).to have_content 'You cannot move the node up past a standard variable.'
      click_button 'variableDown'
      ui_check_node_ordinal(key_1, 29)
      ui_check_node_ordinal(key_2, 30)
      click_button 'variableDown'
      expect(page).to have_content 'You cannot move the node down.'
    end

    it "non-standard variabled cannot be moved above a standard variable", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).not_to eq(-1)
      click_button 'variableUp'
      expect(page).to have_content 'You cannot move the node up past a standard variable.'
    end

    it "allows markdown for the notes and comments", js: true do
      load_domain("DM Domain")
      ui_click_node_name("DTHFL")
      ui_check_disabled_input('variableLabel', "Subject Death Flag")
      ui_set_focus('variableNotes')
      expect(page).to have_content 'Markdown Preview'
      fill_in 'variableNotes', with: "*Hello* World! Also add soem single quotes 'like' this."
      click_button 'markdown_preview'
      ui_check_div_text('genericMarkdown', "Hello World! Also add soem single quotes 'like' this.")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
      fill_in 'variableComment', with: 'And now for smething completely different ... and some double quotes "here".'
      click_button 'markdown_preview'
      ui_check_div_text('genericMarkdown', "And now for smething completely different ... and some double quotes \"here\".")
      click_button 'markdown_hide'
      expect(page).to have_no_content 'Markdown Preview'
    end

    it "allows a non standard variable to be deleted", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).not_to eq(-1)
      click_button 'variableDelete'
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).to eq(-1)
    end

    it "prevents a standard variable from being deleted", js: true do
      load_domain("DM Domain")
      key_1 = ui_get_key_by_path('["Demographics", "SITEID"]')
      ui_click_node_key(key_1)
      ui_button_disabled('variableDelete')
    end

    it "check unique name of variables", js: true do
      load_domain("DM Domain")
      click_button "V+"
      key_1 = ui_get_key_by_path('["Demographics", "DM000029"]')
      expect(key_1).not_to eq(-1)
      fill_in 'variableName', with: "AGE"
      ui_click_node_name("SITEID")
      ui_check_input('variableName', "AGE")
      expect(page).to have_content 'The variable name is not valid. Check the prefix, valid characters and length.'
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
      ui_check_validation_error(key_domain, "domainLabel", "±±±±", C_LABEL_ERROR, other_variable)
      ui_check_validation_ok(key_domain, "domainLabel", "#{C_ALL_CHARS}", other_variable)
      ui_check_validation_error(key_domain, "domainNotes", "±±±±", C_MARKDOWN_ERROR, other_variable)
      ui_check_validation_ok(key_domain, "domainNotes", "#{C_ALL_CHARS}", other_variable)
      # Group
      ui_check_validation_error(key_variable, "variableNotes", "±±±±", C_MARKDOWN_ERROR, other_variable)
      ui_check_validation_ok(key_variable, "variableNotes", "#{C_ALL_CHARS}", other_variable)
      ui_check_validation_error(key_variable, "variableComment", "±±±±", C_MARKDOWN_ERROR, other_variable)
      ui_check_validation_ok(key_variable, "variableComment", "#{C_ALL_CHARS}", other_variable)
    end

    it "allows the edit session to be closed", js: true do
      load_domain("DM Domain")
      ui_click_close
      expect(page).to have_content 'History:'
    end

  end

end