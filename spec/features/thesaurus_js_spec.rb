require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include PauseHelpers
  include DataHelpers

  describe "Curator User", :type => :feature do

    before :all do
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end
  
    it "allows terminology history to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
      #pause
      find(:xpath, "//a[starts-with(@href, \"/thesauri/TH-ACME_TESTtest\")]", :text => 'Edit').click
      expect(page).to have_content 'Edit: TEST test'
    end

  end

end