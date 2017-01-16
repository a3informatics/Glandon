require 'rails_helper'
require 'selenium-webdriver'

describe "Biomedical Concept Editor", :type => :feature do
  
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

  after :each do
    click_link 'logoff_button'
  end

  def load_bc(identifier)
    #visit '/users/sign_in'
    #expect(page).to have_content 'Log in'  
    #fill_in 'Email', with: 'domain_edit@example.com'
    #fill_in 'Password', with: '12345678'
    #click_button 'Log in'
    #expect(page).to have_content 'Signed in successfully'  
    #click_link 'Domains'
    #expect(page).to have_content 'Index: Domains'
    #find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    #expect(page).to have_content 'History:'
    #find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    #expect(page).to have_content 'Edit:'  
  end

  def reload_bc(identifier)
    #click_link 'Domains'
    #expect(page).to have_content 'Index: Domains'
    #find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    #expect(page).to have_content 'History:'
    #find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    #expect(page).to have_content 'Edit:'  
  end

  describe "Curator User", :type => :feature do
  
    it "has correct initial state"

    it "allows the edit session to be saved"

    it "allows the edit session to be closed"

    it "allows the edit session to be closed indirectly, saves data"
    
  end

end