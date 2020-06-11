require 'rails_helper'

describe "Audit Trail", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

  def prepare_audit_trail

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

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    ua_create
    user1 = ua_add_user email: "audit_trail_user_1@example.com"
    user2 = ua_add_user email: "audit_trail_user_2@example.com"
  end

  after :all do
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
      prepare_audit_trail
      click_navbar_at
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      expect(page).to have_button 'Filter results'
      expect(page).to have_link 'Export CSV'
    end

    it "check ordering with latest in first row", js: true do
      prepare_audit_trail
      click_navbar_at
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      ui_check_table_row("main", 1, [Timestamp.new(@now1).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I1", "1", "Create"])
      ui_check_table_row("main", 2, [Timestamp.new(@now2).to_datetime, "audit_trail_user_1@example.com", "CDISC", "I2", "1", "Create"])
    end

    it "allows searching - event", js:true do
      prepare_audit_trail
      click_navbar_at
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      select 'User', from: "audit_trail_event"
      click_button 'Filter results'
      ui_check_table_info("main", 1, 4, 4)
    end

    it "allows searching - user", js:true do
      prepare_audit_trail
      click_navbar_at
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      select 'audit_trail_user_2@example.com', from: "audit_trail_user"
      click_button 'Filter results'
      ui_check_table_info("main", 1, 2, 2)
    end

    it "allows searching - owner", js:true do
      prepare_audit_trail
      click_navbar_at
      select 'ACME', from: "audit_trail_owner"
      click_button 'Filter results'
      ui_check_table_info("main", 1, 9, 9)
    end

    it "allows searching - identifier", js:true do
      prepare_audit_trail
      click_navbar_at
      fill_in 'Identifier', with: 'T1'
      click_button 'Filter results'
      ui_check_table_info("main", 1, 3, 3)
    end

    it "allows searching - combined", js:true do
      prepare_audit_trail
      click_navbar_at
      select 'CDISC', from: "audit_trail_owner"
      fill_in 'Identifier', with: 'I2'
      click_button 'Filter results'
      expect(page.all('table#main tr').count).to eq(2)
    end

    it "correctly marks the create event of a Code List", js:true do
      prepare_audit_trail
      click_navbar_code_lists
      identifier = ui_new_code_list
      click_navbar_at
      fill_in 'Identifier', with: identifier
      click_button 'Filter results'
      ui_check_table_cell("main", 1, 6, "Create")
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
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      expect(page).to have_button 'Filter results'
      expect(page).to have_link 'Export CSV'
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
      expect(page).to have_content 'Audit Trail'
      expect(page).to have_content 'Filter Audit Trail Data'
      expect(page).to have_button 'Filter results'
      expect(page).to have_link 'Export CSV'
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
