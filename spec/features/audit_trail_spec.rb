require 'rails_helper'

describe "Audit Trail", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("MDRIdentificationACME.ttl")
  end 

  before :each do
    user = FactoryGirl.create(:user)
    user.add_role :sys_admin
    user1 = User.create :email => "user1@example.com", :password => "changeme" 
    user2 = User.create :email => "user2@example.com", :password => "changeme" 
    AuditTrail.delete_all
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "CDISC", identifier: "I1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "CDISC", identifier: "I2", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
    ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
  end

  describe "valid user", :type => :feature do
  
    it "allows viewing" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
    end

    it "allows searching - event" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'User', from: "audit_trail_event"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(6) # Note, these counts are records expected + 1 for the header row
    end

    it "allows searching - user" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'user2@example.com', from: "audit_trail_user"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(3)
    end

    it "allows searching - owner" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'ACME', from: "audit_trail_owner"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(10)
    end

    it "allows searching - identifier" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      fill_in 'Identifier', with: 'T1'
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(4)
    end

    it "allows searching - combined" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'CDISC', from: "audit_trail_owner"
      fill_in 'Identifier', with: 'I2'
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(2)
    end

  end

end