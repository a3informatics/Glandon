require 'rails_helper'

describe "Users", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers

  before :all do
    ua_create
    user = User.create :email => "delete@example.com", :password => "Changeme1#"
    user.add_role :curator
  end

  after :all do
    ua_destroy
    # No need to destroy "delete@exampe.com as the test does it"
  end

  describe "System Admin User", :type => :feature do

    it "allows a user to be deleted", js: true do
      ua_sys_admin_login
      click_link 'users_button'
      expect(page).to have_content 'All user accounts'
      audit_count = AuditTrail.count
      find(:xpath, "//tr[contains(.,'delete@example.com')]/td/a", :text => 'Delete').click
      page.accept_alert
      expect(page).to have_content 'User delete@example.com was successfully deleted.'
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

  end

end
