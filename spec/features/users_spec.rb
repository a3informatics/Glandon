require 'rails_helper'

describe "Users", :type => :feature do
  
  include UserAccountHelpers
  
  def check_user_role(email, audit_count, roles)    
    expect(page).to have_content 'Index: User'
    edit_user(email)
    expect(page).to have_content "User Email:#{email}"
    expect(AuditTrail.count).to eq(audit_count)
    expect(page).to have_content "Current Roles:#{roles}"
  end

  def edit_user(email)
  	tr = page.find(:xpath, "//tr[td='#{email}']")
    tr.find(:xpath, "td[3]/a").click
  end

  describe "Login and Logout", :type => :feature do
  
    before :all do
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "allows valid credentials and logs (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      ua_reader_login
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "rejects invalid credentials - wrong password (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Log in'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "rejects invalid credentials - missing password (REQ-GENERIC-PM-020)", js: true do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      click_button 'Log in'
      pause
      expect(page).to have_content 'Log in'
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "rejects invalid credentials - wrong username (REQ-GENERIC-PM-020)" do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader1@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Log in'
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
      fill_in 'Email', with: 'reader@example.com'
      click_button 'Send me reset password instructions'
      expect(page).to have_content 'Log in'
      expect(ActionMailer::Base.deliveries.count).to eq(email_count + 1)
    	expect(ActionMailer::Base.deliveries[0].from).to eq([ENV['EMAIL_USERNAME']])
    	expect(ActionMailer::Base.deliveries[0].to).to eq(['reader@example.com'])
			expect(ActionMailer::Base.deliveries[0].subject).to eq('Reset password instructions')
    	expect(ActionMailer::Base.smtp_settings[:address]).to eq(ENV['EMAIL_SMTP'])
			expect(ActionMailer::Base.smtp_settings[:port]).to eq(ENV['EMAIL_PORT'].to_i)
			expect(ActionMailer::Base.smtp_settings[:domain]).to eq(ENV['EMAIL_DOMAIN'])
			expect(ActionMailer::Base.smtp_settings[:authentication]).to eq(ENV['EMAIL_AUTHENTICATION'])
			expect(ActionMailer::Base.smtp_settings[:user_name]).to eq(ENV['EMAIL_USERNAME'])
			expect(ActionMailer::Base.smtp_settings[:password]).to eq(ENV['EMAIL_PASSWORD'])
    end

  end

  describe "User Management", :type => :feature do
  
    before :all do
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "allows correct reader access", js: true do
    	@user_r.name = "Mr Reader"
    	@user_r.save
      ua_reader_login
      #expect(page).to have_content 'Mr Reader [Reader]'
      expect(page).to have_content 'Reader'
    end

    it "allows correct sys admin access" do
      @user_sa.name = "God!"
    	@user_sa.save
      ua_sys_admin_login
      expect(page).to have_content 'System Admin'
      click_link 'users_button'
      expect(page).to have_content 'Index: Users'
      expect(page).to have_content 'sys_admin@example.com'      
      expect(page).to have_content 'reader@example.com'      
      expect(page).to have_content 'curator@example.com'      
      expect(page).to have_content 'content_admin@example.com'      
    end



    it "allows new user to be created (REQ-GENERIC-UM-040)" do
      audit_count = AuditTrail.count
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email:', with: 'new_user@example.com'
      fill_in 'Name:', with: 'New user'
      fill_in 'Password:', with: '12345678'
      fill_in 'Password Confirmation:', with: '12345678'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      expect(page).to have_content 'new_user@example.com'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "prevents a new user with short password being created (REQ-GENERIC-PM-NONE)" do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email:', with: 'new_user_2@example.com'
      fill_in 'Name:', with: 'New user'
      fill_in 'Password:', with: '1234567'
      fill_in 'Password Confirmation:', with: '1234567'
      click_button 'Create'
      expect(page).to have_content 'User was not created.'
    end 

    it "prevents a two users with identical username being created (REQ-GENERIC-PM-030)", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email:', with: 'new_user_4@example.com'
      fill_in 'Name:', with: 'New user'
      fill_in 'Password:', with: '12345678'
      fill_in 'Password Confirmation:', with: '12345678'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email:', with: 'new_user_4@example.com'
      fill_in 'Name:', with: 'New user'
      fill_in 'Password:', with: '12345678'
      fill_in 'Password Confirmation:', with: '12345678'
      click_button 'Create'
      expect(page).to have_content 'User was not created. Email has already been taken.'
    end    

    it "allows a user's role to be modified (REQ-GENERIC-UM-110)" do
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
    end

    it "allows a user to be deleted (REQ-GENERIC-UM-090)" do
      audit_count = AuditTrail.count
      user = User.create :email => "delete@example.com", :password => "changeme" 
      user.add_role :reader
      ua_sys_admin_login
      expect(AuditTrail.count).to eq(audit_count + 2)
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      expect(AuditTrail.count).to eq(audit_count + 3)
      # Needs more here to confirm the deletion. Cannot do it without Javascript
    end
      
    it "allows a user to change their password (REQ-GENERIC-PM-050)" do
      audit_count = AuditTrail.count
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'settings_button'
      #click_link 'Password'
      #expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'changeme'
      click_button 'password_update_button'
      expect(page).to have_content 'Your account has been updated successfully.'
      expect(AuditTrail.count).to eq(audit_count + 3)
    end

    it "allows a user to change their password - incorrect current password (REQ-GENERIC-PM-050)" do
      audit_count = AuditTrail.count
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'settings_button'
      #click_link 'Password'
      #expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'newpassword'
      click_button 'password_update_button'
      expect(page).to have_content 'Edit: edit@example.com'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

  end

end