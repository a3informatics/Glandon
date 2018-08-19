require 'rails_helper'

describe "Tokens", :type => :feature do
  
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
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Token.delete_all
    Token.set_timeout(60)
    @user1 = User.create :email => "token@example.com", :password => "12345678" 
    @user1.add_role :reader
    @user2 = User.create :email => "admin_user@example.com", :password => "12345678" 
    @user2.add_role :sys_admin
    item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item1.id = "1"
    item2 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item2.id = "2"
    item3 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item3.id = "3"
    item4 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item4.id = "4"
    token1 = Token.obtain(item1, @user1)
    token2 = Token.obtain(item2, @user1)
    token3 = Token.obtain(item3, @user1)
    token4 = Token.obtain(item4, @user1)
  end

  after :all do
    user = User.where(:email => "token@example.com").first
    user.destroy
    user = User.where(:email => "admin_user@example.com").first
    user.destroy
    Token.restore_timeout
  end

  describe "System Admin User", :type => :feature do
  
    it "allows the tokens to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'admin_user@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Edit Locks'
      expect(page).to have_content 'Index: Edit Locks'  
    end

    it "allows a lock to be released", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'admin_user@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Edit Locks'
      expect(page).to have_content 'Index: Edit Locks'  
      expect(page.all('table#main tr').count).to eq(5)
      find(:xpath, "//tr[contains(.,'http://www.assero.co.uk/MDRForms/ACME/V1#2')]/td/a", :text => 'Release').click
      ui_click_ok("Are you sure?")
      expect(page.all('table#main tr').count).to eq(4)
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#1"
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#3"
      expect(page).to have_content "http://www.assero.co.uk/MDRForms/ACME/V1#4"
      #pause
    end

    it "allows a lock to be released, rejection", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'admin_user@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Edit Locks'
      expect(page).to have_content 'Index: Edit Locks'  
      find(:xpath, "//tr[contains(.,'http://www.assero.co.uk/MDRForms/ACME/V1#3')]/td/a", :text => 'Release').click
      ui_click_cancel("Are you sure?")
    end

  end

end