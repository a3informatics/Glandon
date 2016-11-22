require 'rails_helper'

describe "ISO Scoped identifier JS", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
    load_test_file_into_triple_store("IsoScopedIdentifier.ttl")
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

    it "deletes scoped identifier" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'sysadmin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Scoped Identifiers'
      expect(page).to have_content 'Scoped Identifiers'
      pause
      find(:xpath, "//tr[contains(.,'SI-TEST_3-3')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content 'SI-TEST_1-1'
      expect(page).to have_content 'SI-TEST_2-2'
      expect(page).to have_content 'SI-TEST_3-4'
      expect(page).to have_content 'SI-TEST_3-5'
      expect(page).to have_no_content 'SI-TEST_3-3'
      pause
    end

  end

end