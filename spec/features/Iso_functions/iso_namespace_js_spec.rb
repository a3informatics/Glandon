require 'rails_helper'

describe "ISO Namespace JS", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
  end 

  before :all do
    user = User.create :email => "sysadmin@example.com", :password => "12345678" 
    user.add_role :sys_admin
  end

  after :all do
    user = User.where(:email => "sysadmin@example.com").first
    user.destroy
  end

  describe "valid user", :type => :feature, js: true do

    it "deletes namespace" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sysadmin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Namespace'
      expect(page).to have_content 'Namespaces'
      find(:xpath, "//tr[contains(.,'AAA')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_no_content 'AAA Long'
      #pause
    end

  end

end