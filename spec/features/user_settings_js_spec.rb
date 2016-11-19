require 'rails_helper'

describe "User Settings", :type => :feature do
  
  include PauseHelpers

  before :all do
    user = User.create :email => "curator@example.com", :password => "12345678" 
    user.add_role :curator
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "amending settings", :type => :feature do
  
    it "allows correct reader access", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Settings'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr')
      expect(tr).to have_css("a", text: "Letter")
      expect(tr).to have_css("a", text: "A4")
      expect(tr).to have_css("button", text: "A3")
      click_link 'A4'
      pause
      tr = page.find('#main tbody tr')
      expect(tr).to have_css("button", text: "A4")
      click_link 'A3'
      tr = page.find('#main tbody tr')
      expect(tr).to have_css("button", text: "A3")
      click_link 'Letter'
      tr = page.find('#main tbody tr')
      expect(tr).to have_css("button", text: "Letter")
    end

  end

end