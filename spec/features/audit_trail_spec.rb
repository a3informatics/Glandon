require 'rails_helper'

describe "Audit Trail", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  
  before :all do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    ua_create
    user1 = User.create :email => "audit_trail_user_1@example.com", :password => "changeme" 
    user2 = User.create :email => "audit_trail_user_2@example.com", :password => "changeme" 
    AuditTrail.delete_all
    @now1 = Time.now
    @now2 = Time.now - 10
    ar = AuditTrail.create(date_time: @now1, user: "audit_trail_user_1@example.com", owner: "CDISC", identifier: "I1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: @now2, user: "audit_trail_user_1@example.com", owner: "CDISC", identifier: "I2", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 20, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 30, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 40, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 50, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 60, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 70, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 80, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 90, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 100, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 110, user: "audit_trail_user_1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now - 120, user: "audit_trail_user_1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
    ar = AuditTrail.create(date_time: Time.now - 130, user: "audit_trail_user_2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now - 140, user: "audit_trail_user_2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
  end

  after :all do
    ua_destroy
    user = User.where(:email => "audit_trail_user_1@example.com").first
    user.destroy
    user = User.where(:email => "audit_trail_user_2@example.com").first
    user.destroy
  end

  describe "curator allowed access to audit", :type => :feature do
  
    it "allows viewing" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      #save_and_open_page
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
    end

    it "check ordering with latest in first row", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      ui_check_table_row("main", 1, [Timestamp.new(@now1).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I1", "1", "Create"])
      ui_check_table_row("main", 2, [Timestamp.new(@now2).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I2", "1", "Create"])
    end

    it "allows searching - event" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'User', from: "audit_trail_event"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(7) # Note, these counts are records expected + 1 for the header row. Also include logins in the tests (3)
    end

    it "allows searching - user" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
      select 'audit_trail_user_2@example.com', from: "audit_trail_user"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(3)
    end

    it "allows searching - owner" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
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
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
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
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
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

  describe "content admin allowed access to audit", :type => :feature do
  
    it "allows viewing" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
    end

  end

  describe "system admin allowed access to audit", :type => :feature do
  
    it "allows viewing" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Audit Trail'
      expect(page).to have_content 'Index: Audit Trail'
    end

  end

  describe "reader not allowed access to audit", :type => :feature do
  
    it "does not allow viewing" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      expect(page).to have_no_link 'Audit Trail'
    end

  end

end