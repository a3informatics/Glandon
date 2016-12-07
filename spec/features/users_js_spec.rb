require 'rails_helper'

describe "Users", :type => :feature do
  
  include PauseHelpers
  
  before :all do
    user = User.create :email => "delete@example.com", :password => "12345678" 
    user.add_role :curator
  end

  describe "Reader User", :type => :feature do

    it "allows a user to be deleted", js: true do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'sys_admin@example.com'
      fill_in 'Password', with: 'changeme'
      click_button 'Log in'
      #pause
      click_link 'users_button'
      expect(page).to have_content 'Index: User'
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      page.accept_alert
      click_link 'Audit Trail'
      expect(AuditTrail.count).to eq(audit_count + 2)
    end

  end

end