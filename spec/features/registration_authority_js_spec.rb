require 'rails_helper'

describe "Namespace JS", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
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
      click_link 'Registration Authorities'
      expect(page).to have_content 'Registration Authorities'
      find(:xpath, "//tr[contains(.,'111111111')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content '123456789'
      expect(page).to have_no_content '111111111'
    end

  end

end