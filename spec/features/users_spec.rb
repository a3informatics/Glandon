require 'rails_helper'

describe "Users", :type => :feature do

  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  def check_user_role(email, audit_count, roles)
    expect(page).to have_content 'All User Accounts'
    find(:xpath, "//tr[contains(.,'#{email}')]/td/a", :class => 'edit-user').click
    expect(page).to have_content "Email: #{email}"
    expect(AuditTrail.count).to eq(audit_count)
    expect(page).to have_content "Current Roles: #{roles}"
  end

  def set_user_role(role)
    click_on "Set #{ role } Role"
    ui_confirmation_dialog true
    wait_for_ajax 10
  end 

  describe "Login and Logout", :type => :feature do

    before :all do
      User.destroy_all
      ua_create
    end

    after :all do
      ua_destroy
      User.destroy_all
    end

    it "allows valid credentials and logs (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      ua_reader_login
      expect(AuditTrail.count).to eq(audit_count + 1)
      ua_logoff
    end

    it "rejects invalid credentials - wrong password (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in :placeholder => 'Email', :with => 'reader@example.com'
      fill_in :placeholder => 'Password', :with => 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Welcome'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "rejects invalid credentials - missing password (REQ-GENERIC-PM-020)", js: true do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in :placeholder => 'Email', :with => 'reader@example.com'
      click_button 'Log in'
      expect(page).to have_content 'Welcome'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "rejects invalid credentials - wrong username (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in :placeholder => 'Email', :with => 'reader1@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      click_button 'Log in'
      expect(page).to have_content 'Welcome'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows logout and logs" do
      audit_count = AuditTrail.count
      ua_reader_login
      ua_logoff
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

    it "allows password reset email to be sent (REQ-GENERIC-PM-080)" do
      email_count = ActionMailer::Base.deliveries.count
      visit '/users/sign_in'
      click_link 'Forgot your password?'
      fill_in :placeholder => 'Email', :with => 'reader@example.com'
      click_button 'Submit'
      expect(page).to have_content 'Welcome'
      expect(ActionMailer::Base.deliveries.count).to eq(email_count + 1)
    	expect(ActionMailer::Base.deliveries[0].from).to eq([ENV['EMAIL_USERNAME']])
    	expect(ActionMailer::Base.deliveries[0].to).to eq(['reader@example.com'])
			expect(ActionMailer::Base.deliveries[0].subject).to eq('Reset password instructions')
      expect(ActionMailer::Base.deliveries[0].body).to include("#{ENV['HOST_PROTOCOL']}://#{ENV['HOST_NAME']}")
      expect(ActionMailer::Base.deliveries[0].body).to include('users/password/edit?reset_password_token=')
    	expect(ActionMailer::Base.smtp_settings[:address]).to eq(ENV['EMAIL_SMTP'])
			expect(ActionMailer::Base.smtp_settings[:port]).to eq(ENV['EMAIL_PORT'].to_i)
			expect(ActionMailer::Base.smtp_settings[:domain]).to eq(ENV['EMAIL_DOMAIN'])
			expect(ActionMailer::Base.smtp_settings[:authentication]).to eq(ENV['EMAIL_AUTHENTICATION'])
			expect(ActionMailer::Base.smtp_settings[:user_name]).to eq(ENV['EMAIL_USERNAME'])
			expect(ActionMailer::Base.smtp_settings[:password]).to eq(ENV['EMAIL_PASSWORD'])
    end

    it "allows the login page welcome text to be checked" do
      visit '/users/sign_in'
      expect(page).to have_content 'Welcome text displayed here.'
    end

    it "allows to escape the password expired page (REQ-GENERIC-PM-050)" do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'usr3@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Display name', :with => 'Test User 3'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'

      ua_logoff

      fill_in :placeholder => 'Email', :with => 'usr3@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      click_button 'Log in'

      expect(page).to have_content 'Renew your password'
      click_on "Return to the Log in page"
      expect(page).to have_content "Welcome"
    end

  end

  describe "User Management", :type => :feature do

    before :all do
      User.destroy_all
      ua_create
    end

    after :all do
      ua_destroy
      User.destroy_all
    end

    after :each do
      ua_logoff
    end

    it "allows correct reader access (REQ-GENERIC-UR-010)" do
    	@user_r.name = "Mr Reader"
    	@user_r.save
      ua_reader_login
      expect(page).to have_content 'Mr Reader'
      expect(page).to have_content 'Reader'
    end

    it "allows correct sys admin access (REQ-GENERIC-UM-010, REQ-GENERIC-UR-010)" do
      @user_sa.name = "God!"
    	@user_sa.save
      ua_sys_admin_login
      expect(page).to have_content 'God!'
      expect(page).to have_content 'System Admin'
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      expect(page).to have_content 'sys_admin@example.com'
      expect(page).to have_content 'reader@example.com'
      expect(page).to have_content 'curator@example.com'
      expect(page).to have_content 'content_admin@example.com'
    end

    it "allows new user to be created (REQ-GENERIC-UM-040)", js:true do
      ua_sys_admin_login
      audit_count = AuditTrail.count
      user_count = User.all.count
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'new_user@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'
      expect(page).to have_content 'User was successfully created.'
      expect(page).to have_content 'new_user@example.com'
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(User.all.count).to eq(user_count + 1)
    end

    it "prevents a new user with short password being created (REQ-GENERIC-PM-NONE)" do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'new_user_2@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => '12345'
      fill_in :placeholder => 'Confirm password', :with => '12345'
      click_button 'Create Account'
      expect(page).to have_content 'User was not created.'
    end

    it "prevents a two users with identical username being created (REQ-GENERIC-PM-030)", js:true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      if page.has_content?('new_user_4@example.com')
        find(:xpath, "//tr[contains(.,'new_user_4@example.com')]/td/a", :text => 'Delete').click
      end
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'new_user_4@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'
      expect(page).to have_content 'User was successfully created.'
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'new_user_4@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'
      expect(page).to have_content 'User was not created. Email has already been taken.'
    end

    it "allows a user's role to be modified (REQ-GENERIC-UM-025, REQ-GENERIC-UM-110)", js:true do
      audit_count = AuditTrail.count
      ua_sys_admin_login
      click_link 'users_button'
      check_user_role("comm_reader@example.com", audit_count+1, "Community Reader")
      set_user_role 'Curator'
      # Check success flash
      expect(page).to have_content "User role for comm_reader@example.com successfully updated to: Curator."
      check_user_role("comm_reader@example.com", audit_count+2, "Curator")
      set_user_role 'Content Admin'
      check_user_role("comm_reader@example.com", audit_count+3, "Content Admin")
      set_user_role 'Curator'
      check_user_role("comm_reader@example.com", audit_count+4, "Curator")
      set_user_role 'Content Admin & System Admin'
      check_user_role("comm_reader@example.com", audit_count+5, "Content Admin, System Admin")
      set_user_role 'Terminology Reader'
      check_user_role("comm_reader@example.com", audit_count+6, "Terminology Reader")
      set_user_role 'Terminology Curator'
      check_user_role("comm_reader@example.com", audit_count+7, "Terminology Curator")
      set_user_role 'Reader'
      check_user_role("comm_reader@example.com", audit_count+8, "Reader")
      set_user_role 'Community Reader'
      check_user_role("comm_reader@example.com", audit_count+9, "Community Reader")
    end

    it "allows a user to be deleted (REQ-GENERIC-UM-090)", js: true do
      ua_add_user email: 'delete@example.com', role: :reader
      ua_sys_admin_login
      audit_count = AuditTrail.count
      user_count = User.all.count
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :class => 'delete-user').click
      ui_confirmation_dialog true
      wait_for_ajax 10
      expect(User.all.count).to eq(user_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(AuditTrail.last(1)[0].description).to eq("User delete@example.com deleted.")
    end

    it "allows a user to change their password (REQ-GENERIC-PM-050)" do
      ua_add_user email: 'edit@example.com', role: :reader
      ua_generic_login 'edit@example.com'
      audit_count = AuditTrail.count
      click_link 'settings_button'
      fill_in 'user_password', with: 'Changeme2#'
      fill_in 'user_password_confirmation', with: 'Changeme2#'
      fill_in 'user_current_password', with: 'Changeme1#'
      click_button 'password-update-btn'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "allows a user to change their password - incorrect current password (REQ-GENERIC-PM-050)" do
      ua_add_user email: 'edit2@example.com', role: :reader
      ua_generic_login 'edit2@example.com'
      audit_count = AuditTrail.count
      click_link 'settings_button'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'user_current_password', with: 'newpassword'
      click_button 'password-update-btn'
      expect(page).to have_content 'Changing the password for edit2@example.com'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows sys admin role to be deleted if another sys admin exists", js:true do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'admin2@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'

      admin_user = User.find_by(:email => "admin2@example.com")
      admin_user.add_role(:sys_admin)

      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      find(:xpath, "//tr[contains(.,'admin2@example.com')]/td/a", :class => 'edit-user').click
      expect(page).to have_content 'Set User Roles'
      expect(page).to have_content 'Email: admin2@example.com'
      click_on 'Set Curator Role'
      ui_confirmation_dialog true 
      wait_for_ajax 10 
      expect(page).to have_content 'All User Accounts'
      expect(find(:xpath, '//tr[contains(.,"admin2@example.com")]/td[2]').text).to eq("Curator")
    end

    it "assigns user a default display name if none is provided" do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'usr@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'

      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      find(:xpath, "//tr[contains(.,'usr@example.com')]/td/a", :class => 'edit-user').click
      expect(page).to have_content 'Set User Roles'
      expect(page).to have_content 'Email: usr@example.com'
      expect(page).to have_content 'Anonymous'

      ua_remove_user "usr@example.com"
    end

    it "forces first-login password reset when a new user is added, display name blank" do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'usr@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'

      ua_logoff

      fill_in :placeholder => 'Email', :with => 'usr@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      click_button 'Log in'

      expect(page).to have_content 'Renew your password'
      fill_in :placeholder => 'Current password', :with => 'Changeme1#'
      fill_in :placeholder => 'New password', :with => 'Changeme2#'
      fill_in :placeholder => 'Confirm new password', :with => 'Changeme2#'
      click_button 'Change'
      expect(page).to have_content 'Your new password is saved'

      ua_logoff

      fill_in :placeholder => 'Email', :with => 'usr@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme2#'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    it "forces first-login password reset when a new user is added, using display name (GLAN-925)" do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      click_link '+ New User'
      expect(page).to have_content 'New User Account'
      fill_in :placeholder => 'Email', :with => 'usr2@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Display name', :with => 'Test User 2'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create Account'

      ua_logoff

      fill_in :placeholder => 'Email', :with => 'usr2@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      click_button 'Log in'

      expect(page).to have_content 'Renew your password'
      fill_in :placeholder => 'Current password', :with => 'Changeme1#'
      fill_in :placeholder => 'New password', :with => 'Changeme2#'
      fill_in :placeholder => 'Confirm new password', :with => 'Changeme2#'
      click_button 'Change'
      expect(page).to have_content 'Your new password is saved'

      ua_logoff

      fill_in :placeholder => 'Email', :with => 'usr2@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme2#'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    it "prevents last sys admin to be deleted", js:true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      find(:xpath, "//tr[contains(.,'sys_content_admin@example.com')]/td/a", :class => 'edit-user').click
      expect(page).to have_content 'Email: sys_content_admin@example.com'
      click_on 'Set Curator Role'
      ui_confirmation_dialog true 
      wait_for_ajax 10 
      click_link 'users_button'
      expect(page).to have_content 'All User Accounts'
      find(:xpath, "//tr[contains(.,'sys_admin@example.com')]/td/a", :class => 'edit-user').click
      expect(page).to have_content 'Set User Roles'
      expect(page).to have_content 'Email: sys_admin@example.com'
      click_on 'Set Curator Role'
      ui_confirmation_dialog true 
      wait_for_ajax 10 
      expect(page).to have_content 'You cannot remove the last system administrator.'
    end

  end

end
