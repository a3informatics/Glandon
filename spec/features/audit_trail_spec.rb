require 'rails_helper'

describe "Audit Trail", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)

    ua_create
    user1 = ua_add_user email: "audit_trail_user_1@example.com"
    user2 = ua_add_user email: "audit_trail_user_2@example.com"
    AuditTrail.delete_all
    @now1 = Time.now - 70
    @now2 = Time.now - 80
    ar = AuditTrail.create(date_time: @now1, user: "audit_trail_user_1@example.com", owner: "CDISC", identifier: "I1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: @now2, user: "audit_trail_user_1@example.com", owner: "CDISC", identifier: "I2", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 90, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 100, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 110, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 1, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 120, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 130, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 140, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 2, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 150, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 160, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 170, user: "audit_trail_user_1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 3, description: "description")
    ar = AuditTrail.create(date_time: Time.now - 180, user: "audit_trail_user_1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now - 190, user: "audit_trail_user_1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
    ar = AuditTrail.create(date_time: Time.now - 200, user: "audit_trail_user_2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
    ar = AuditTrail.create(date_time: Time.now - 210, user: "audit_trail_user_2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
  end

  after :all do
    ua_remove_user "audit_trail_user_1@example.com"
    ua_remove_user "audit_trail_user_2@example.com"
    ua_destroy
  end

  describe "curator allowed access to audit", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing (REQ-MDR-GENERIC-A-015)", js:true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
    end

    it "check ordering with latest in first row", js: true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
      ui_check_table_row("main", 4, [Timestamp.new(@now1).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I1", "1", "Create"])
      ui_check_table_row("main", 5, [Timestamp.new(@now2).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I2", "1", "Create"])
    end

    it "allows searching - event", js:true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
      select 'User', from: "audit_trail_event"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(10) # Note, these counts are records expected + 1 for the header row. Also include logins in the tests (3)
    end

    it "allows searching - user", js:true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
      select 'audit_trail_user_2@example.com', from: "audit_trail_user"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(3)
    end

    it "allows searching - owner", js:true do
      click_navbar_at
      select 'ACME', from: "audit_trail_owner"
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(10)
    end

    it "allows searching - identifier", js:true do
      click_navbar_at
      fill_in 'Identifier', with: 'T1'
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(4)
    end

    it "allows searching - combined", js:true do
      click_navbar_at
      select 'CDISC', from: "audit_trail_owner"
      fill_in 'Identifier', with: 'I2'
      click_button 'Submit'
      expect(page.all('table#main tr').count).to eq(2)
    end

  end

  describe "content admin allowed access to audit", :type => :feature do

    before :each do
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing", js:true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
    end

  end

  describe "system admin allowed access to audit", :type => :feature do

    before :each do
			ua_sys_admin_login
		end

    after :each do
      ua_logoff
    end

    it "allows viewing", js:true do
      click_navbar_at
      expect(page).to have_content 'Index: Audit Trail'
    end

  end

  describe "reader not allowed access to audit", :type => :feature do

    before :each do
			ua_reader_login
		end

    after :each do
      ua_logoff
    end

    it "does not allow viewing", js:true do
      ui_expand_section("main_nav_sysadmin") if !ui_section_expanded?("main_nav_sysadmin")
      expect(page).to have_no_link 'Audit Trail'
    end

  end

end
