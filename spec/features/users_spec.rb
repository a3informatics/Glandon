require 'rails_helper'

describe "Users", :type => :feature do
  
  before :each do
    user = FactoryGirl.create(:user)
  end

  describe "Login and Logout", :type => :feature do
  
    it "allows valid credentials" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    it "rejects invalid credentials" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234x'
      click_button 'Log in'
      expect(page).to have_content 'Log in'
    end

  end

  describe "Reader User", :type => :feature do
  
    it "allows correct reader access" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      expect(page).to have_link 'Settings'
      expect(page).to have_no_link 'Users'
      expect(page).to have_no_link 'Registration Authorities'
      expect(page).to have_no_link 'Namespaces'
      expect(page).to have_no_link 'Scoped Identifiers'
      expect(page).to have_no_link 'Registration States'
      expect(page).to have_no_link 'Audit Trail'
      expect(page).to have_no_link 'Upload'
      expect(page).to have_no_link 'Background Jobs'
      expect(page).to have_link 'Classifications (tags)'
    end

    it "allows correct admin access" do
      user = User.create :email => "admin@example.com", :password => "changeme" 
      user.add_role :sys_admin
      visit '/users/sign_in'
      fill_in 'Email', with: 'admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      expect(page).to have_link 'Settings'
      expect(page).to have_link 'Users'
      expect(page).to have_link 'Registration Authorities'
      expect(page).to have_link 'Namespaces'
      expect(page).to have_link 'Scoped Identifiers'
      expect(page).to have_link 'Registration States'
      expect(page).to have_link 'Audit Trail'
      expect(page).to have_no_link 'Upload'
      expect(page).to have_no_link 'Background Jobs'
      expect(page).to have_link 'Classifications (tags)'
      click_link 'Users'
      expect(page).to have_content 'Index: Users'
      expect(page).to have_content 'sys_admin@example.com'      
      expect(page).to have_content 'user@example.com'      
      expect(page).to have_content 'admin@example.com'      
    end

    it "allows new user to be created" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Users'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email', with: 'new_user@example.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      click_button 'Create'
      expect(page).to have_content 'User was successfully created.'
      expect(page).to have_content 'new_user@example.com'
    end

    it "prevents a new user with short password being created" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Users'
      expect(page).to have_content 'Index: User'
      click_link 'New'
      expect(page).to have_content 'New: User'
      fill_in 'Email', with: 'new_user_2@example.com'
      fill_in 'Password', with: '1234567'
      fill_in 'Password confirmation', with: '1234567'
      click_button 'Create'
      expect(page).to have_content 'User was not created.'
    end    

    it "allows a user's details to edited" do
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Users'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'edit@example.com')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: edit@example.com'
    end

    it "allows a user to be deleted" do
      user = User.create :email => "delete@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Users'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      
      #find(:xpath, "//tr[contains(.,'edit@example.com')]/td/a", :text => 'Delete').click
      #page.accept_confirm { click_button "OK" }
      #expect(page).to have_content 'Index: Users'
      #expect(page).to not_have_content 'edit@example.com'
    end

    it "allows a user to change their password" do
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Settings'
      click_link 'Password'
      expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'changeme'
      click_button 'Update'
      expect(page).to have_content 'Your account has been updated successfully.'
    end

    it "allows a user to change their password" do
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Settings'
      click_link 'Password'
      expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'changeme'
      click_button 'Update'
      expect(page).to have_content 'Your account has been updated successfully.'
    end

    it "allows a user to change their password" do
      user = User.create :email => "edit@example.com", :password => "changeme" 
      user.add_role :reader
      visit '/users/sign_in'
      fill_in 'Email', with: 'edit@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      click_link 'Settings'
      click_link 'Password'
      expect(page).to have_content 'Edit: edit@example.com'
      fill_in 'user_password', with: 'newpassword'
      fill_in 'user_password_confirmation', with: 'newpassword'
      fill_in 'Current Password', with: 'newpassword'
      click_button 'Update'
      expect(page).to have_content 'Edit: edit@example.com'
    end

  end

end