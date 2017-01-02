require 'rails_helper'
require 'selenium-webdriver'

describe "SDTM User Domain Editor", :type => :feature do
  
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

=begin
  def create_form(identifier, label, new_label)
    visit '/users/sign_in'
    fill_in 'Email', with: 'domain_edit@example.com'
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
=end

  def load_domain(identifier)
    visit '/users/sign_in'
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
      expect(page).to have_content("Edit: DM Copy DM Domain (, V1, Incomplete)")
      expect(page).to have_content("Domain Details")
      expect(page).to have_content("V+")
      expect(page).to have_content("Save")
      expect(page).to have_content("Close")
      ui_click_node_key(1)
      ui_check_disabled_input('domainPrefix', "DM")
      ui_check_input('domainLabel', "DM Copy")
    end

    it "allows a domain to be defined, Domain Panel", js: true do
      load_domain("DM Domain")
      fill_in 'domainNotes', with: "Notes for *domain* that tell the whole story"
      ui_click_node_name("AGE")
      #pause
      ui_click_node_name("DM Copy")
      #pause
      ui_check_input('domainLabel', "DM Copy")
      ui_check_input('domainNotes', "Notes for *domain* that tell the whole story")
    end

    it "allows domain details to be updated"

    it "allows a variabled to be added"

    it "allows variabled detais to be updated"

    it "allows non-standard variable to be moved up and down"

    it "non-standard variabled cannot be moved above a standard variable"

    it "allows markdown for the notes and comments"

    it "allows a non standard variable to be deleted"

    it "prevents a standard variable from being deleted"

    it "check unique name of variables"

    it "validates the domain panel"

    it "validates the variable panel"

  end

end