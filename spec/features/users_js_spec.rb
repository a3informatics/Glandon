require 'rails_helper'

describe "Users", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include UiHelpers

  before :all do
    ua_create
    ua_add_user email: 'delete@example.com', password: 'Changeme1#', role: :curator
    ua_add_user email: 'lock@example.com', password: 'Changeme1#', role: :curator
    # ua_add_user email: 'tst_user2@example.com', password: 'Changeme1#', current_sign_in_at: '2019-11-21 07:45:59.141587'
    User.create :email => "tst_user2@example.com", :password => "Changeme1#", :current_sign_in_at => "2019-11-21 07:45:59.141587"
  end

  after :all do
    ua_destroy
    ua_remove_user('tst_user2@example.com')
    ua_remove_user('lock@example.com')
    # No need to destroy "delete@exampe.com as the test does it"
  end

  describe "System Admin User", :type => :feature do

    it "allows a user to be deleted (REQ-GENERIC-UM-090)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      audit_count = AuditTrail.count
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      page.accept_alert
      expect(page).to have_content 'User delete@example.com was successfully deleted.'
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "prevents deletion of user if user has logged in (REQ-?????)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      audit_count = AuditTrail.count
      find(:xpath, "//*[@id='main_paginate']/ul/li[3]/a").click
      find(:xpath, "//tr[contains(.,'tst_user2@example.com')]/td/a", :text => 'Delete').click
      page.accept_alert
      expect(page).to have_content 'You cannot delete tst_user2@example.com. User has logged in!'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows a user to be locked (REQ-??????)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'lock@example.com')]/td/a", :text => 'Lock').click
      # page.accept_alert
      expect(page).to have_content 'User was successfully deactivated.'
    end

    it "allows a user to be unlocked (REQ-??????)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'lock@example.com')]/td/a", :text => 'Unlock').click
      # page.accept_alert
      expect(page).to have_content 'User was successfully activated.'
    end

    it "allows to show user login information (REQ-??????)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      ui_check_table_info("main", 1, 10, User.all.count)
      find(:xpath, "//*[@id='main']/tbody/tr[1]/td[5]/a", :text => 'Edit').click
      expect(page).to have_content 'Login Count: 0  |  Last login: Not logged in yet!  |  Days ago: Not logged in yet!'
    end

    it "allows to show user login information (REQ-??????)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      ui_check_table_info("main", 1, 10, User.all.count)
      expect(page).to have_content 'Login Count'
      expect(page).to have_content 'Last Login'
      expect(page).to have_content 'Last Login'
      ui_check_table_cell("main", 1, 3, "0")
      ui_check_table_cell("main", 1, 4, "Not logged in yet!")
    end

  end

end
