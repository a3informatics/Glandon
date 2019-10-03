require 'rails_helper'

describe "Users", :type => :feature do

  include UserAccountHelpers

  def check_user_role(email, audit_count, roles)
    expect(page).to have_content 'All user accounts'
    edit_user(email)
    expect(page).to have_content "Email: #{email}"
    expect(AuditTrail.count).to eq(audit_count)
    expect(page).to have_content "Current Roles: #{roles}"
  end

  def edit_user(email)
  	tr = page.find(:xpath, "//tr[td='#{email}']")
    tr.find(:xpath, "td[3]/a").click
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
      expect(page).to have_content 'All user accounts'
      expect(page).to have_content 'sys_admin@example.com'
      expect(page).to have_content 'reader@example.com'
      expect(page).to have_content 'curator@example.com'
      expect(page).to have_content 'content_admin@example.com'
    end

    it "allows new user to be created (REQ-GENERIC-UM-040)", js:true do
      audit_count = AuditTrail.count
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'new_user@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      expect(page).to have_content 'new_user@example.com'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "prevents a new user with short password being created (REQ-GENERIC-PM-NONE)" do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'new_user_2@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => '12345'
      fill_in :placeholder => 'Confirm password', :with => '12345'
      click_button 'Create'
      expect(page).to have_content 'User was not created.'
    end

    it "prevents a two users with identical username being created (REQ-GENERIC-PM-030)", js:true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      if page.has_content?('new_user_4@example.com')
        find(:xpath, "//tr[contains(.,'new_user_4@example.com')]/td/a", :text => 'Delete').click
      end
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'new_user_4@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'new_user_4@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create'
      expect(page).to have_content 'User was not created. Email has already been taken.'
    end

    it "allows a user's role to be modified (REQ-GENERIC-UM-025, REQ-GENERIC-UM-110)" do
      audit_count = AuditTrail.count
      ua_sys_admin_login
      click_link 'users_button'
      check_user_role("reader@example.com", audit_count+1, "Reader")
      click_link 'Set Curator Role'
      check_user_role("reader@example.com", audit_count+2, "Curator")
      click_link 'Set Content Admin Role'
      check_user_role("reader@example.com", audit_count+3, "Content Admin")
      click_link 'Set Curator Role'
      check_user_role("reader@example.com", audit_count+4, "Curator")
      click_link 'Set Content Admin & System Admin Role'
      check_user_role("reader@example.com", audit_count+5, "Content Admin, System Admin")
      click_link 'Set Terminology Reader Role'
      check_user_role("reader@example.com", audit_count+6, "Terminology Reader")
      click_link 'Set Terminology Curator Role'
      check_user_role("reader@example.com", audit_count+7, "Terminology Curator")
      click_link 'Set Reader Role'
      check_user_role("comm_reader@example.com", audit_count+8, "Community Reader")
      click_link 'Set Community Reader Role'
    end

    it "allows a user to be deleted (REQ-GENERIC-UM-090)" do
      audit_count = AuditTrail.count
      ua_add_user email: 'delete@example.com', role: :reader
      ua_sys_admin_login
      expect(AuditTrail.count).to eq(audit_count + 2)
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      expect(AuditTrail.count).to eq(audit_count + 3)
      # Needs more here to confirm the deletion. Cannot do it without Javascript
    end

    it "allows a user to change their password (REQ-GENERIC-PM-050)" do
      audit_count = AuditTrail.count
      ua_add_user email: 'edit@example.com', role: :reader
      ua_generic_login 'edit@example.com'
      click_link 'settings_button'
      #click_link 'Password'
      #expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'Changeme2#'
      fill_in 'user_password_confirmation', with: 'Changeme2#'
      fill_in 'user_current_password', with: 'Changeme1#'
      click_button 'password_update_button'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "allows a user to change their password - incorrect current password (REQ-GENERIC-PM-050)" do
      audit_count = AuditTrail.count
      ua_add_user email: 'edit@example.com', role: :reader
      ua_generic_login 'edit@example.com'
      click_link 'settings_button'
      #click_link 'Password'
      #expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'user_current_password', with: 'newpassword'
      click_button 'password_update_button'
      expect(page).to have_content 'Changing the password for edit@example.com'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

    it "prevents last sys admin to be deleted", js:true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'sys_admin@example.com')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Set user roles for:'
      expect(page).to have_content 'Email: sys_admin@example.com'
      click_link 'Set Curator Role'
      expect(page).to have_content 'You cannot remove the last system administrator.'
    end

    it "allows sys admin role to be deleted if another sys admin exists", js:true do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'admin2@example.com'
      fill_in :placeholder => 'Display name', :with => 'New user'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create'

      admin_user = User.find_by(:email => "admin2@example.com")
      admin_user.add_role(:sys_admin)

      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'admin2@example.com')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Set user roles for:'
      expect(page).to have_content 'Email: admin2@example.com'
      click_link 'Set Curator Role'
      expect(page).to have_content 'All user accounts'
      expect(find(:xpath, '//tr[contains(.,"admin2@example.com")]/td[2]').text).to eq("Curator")
    end

    it "assigns user a default display name if none is provided" do
      ua_sys_admin_login
      # Manually create user
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      click_link 'New'
      expect(page).to have_content 'New user account'
      fill_in :placeholder => 'Email', :with => 'usr@example.com'
      fill_in :placeholder => 'Password', :with => 'Changeme1#'
      fill_in :placeholder => 'Confirm password', :with => 'Changeme1#'
      click_button 'Create'

      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      find(:xpath, "//tr[contains(.,'usr@example.com')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Set user roles for:'
      expect(page).to have_content 'Email: usr@example.com'
      expect(page).to have_content 'Anonymous'
    end

  end

end
