require 'rails_helper'

describe "Users", :type => :feature do
  
  include UserAccountHelpers
  
  describe "Login and Logout", :type => :feature do
  
    before :all do
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "allows valid credentials and logs" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "rejects invalid credentials" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Log in'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows logout and logs" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'logoff_button'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

    it "allows password reset email to be sent" do
      email_count = ActionMailer::Base.deliveries.count
      visit '/users/sign_in'
      click_link 'Forgot your password?'
      fill_in 'Email', with: 'reader@example.com'
      click_button 'Send me reset password instructions'
      expect(page).to have_content 'Log in'
      expect(ActionMailer::Base.deliveries.count).to eq(email_count + 1)
    end

  end

  describe "User Management", :type => :feature do
  
    before :all do
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "allows correct reader access" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      expect(page).to have_link 'settings_button'
      expect(page).to have_no_link 'users_button'
      expect(page).to have_no_link 'Registration Authorities'
      expect(page).to have_no_link 'Namespaces'
      expect(page).to have_no_link 'Scoped Identifiers'
      expect(page).to have_no_link 'Registration States'
      expect(page).to have_no_link 'Audit Trail'
      expect(page).to have_no_link 'Upload'
      expect(page).to have_no_link 'Background Jobs'
      expect(page).to have_link 'Classifications (tags)'
    end

    it "allows correct sys admin access" do
      user = User.create :email => "admin@example.com", :password => "changeme" 
      user.add_role :sys_admin
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_link 'settings_button'
      expect(page).to have_link 'users_button'
      expect(page).to have_link 'Registration Authorities'
      expect(page).to have_link 'Namespaces'
      expect(page).to have_link 'Scoped Identifiers'
      expect(page).to have_link 'Registration States'
      expect(page).to have_link 'Audit Trail'
      expect(page).to have_no_link 'Upload'
      expect(page).to have_no_link 'Background Jobs'
      expect(page).to have_link 'Classifications (tags)'
      click_link 'users_button'
      expect(page).to have_content 'Index: Users'
      expect(page).to have_content 'sys_admin@example.com'      
      expect(page).to have_content 'user@example.com'      
      expect(page).to have_content 'admin@example.com'      
    end

    it "allows new user to be created" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email', with: 'new_user@example.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      expect(page).to have_content 'new_user@example.com'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "prevents a new user with short password being created" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email', with: 'new_user_2@example.com'
      fill_in 'Password', with: '1234567'
      fill_in 'Password confirmation', with: '1234567'
      click_button 'Create'
      expect(page).to have_content 'User was not created.'
    end    

    it "allows a user's details to be edited" do
      audit_count = AuditTrail.count
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'edit@example.com')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: edit@example.com'
      expect(AuditTrail.count).to eq(audit_count + 2)
      # Needs more here to confirm the deletion. Cannot do it without Javascript
    end

    it "allows a user to be deleted" do
      audit_count = AuditTrail.count
      user = User.create :email => "delete@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      expect(AuditTrail.count).to eq(audit_count + 3)
      # Needs more here to confirm the deletion. Cannot do it without Javascript
    end
      
    it "allows a user to change their password" do
      audit_count = AuditTrail.count
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'settings_button'
      click_link 'Password'
      expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'changeme'
      click_button 'Update'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "allows a user to change their password - incorrect current password" do
      audit_count = AuditTrail.count
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'settings_button'
      click_link 'Password'
      expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'newpassword'
      click_button 'Update'
      expect(page).to have_content 'Edit: edit@example.com'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

  end

end