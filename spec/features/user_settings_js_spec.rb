require 'rails_helper'

describe "User Settings", :type => :feature do
  
  include PauseHelpers

  before :all do
    user = User.create :email => "curator@example.com", :password => "12345678" 
    user.add_role :curator
    user = User.create :email => "reader@example.com", :password => "12345678" 
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
    user = User.where(:email => "reader@example.com").first
    user.destroy
  end

  describe "amending settings", :type => :feature do
  
    it "allows paper size to be amended", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Paper Size')
      #sleep 1
      #pause
      expect(tr).to have_css("a", text: "Letter")
      expect(tr).to have_css("a", text: "A3")
      expect(tr).to have_css("button", text: "A4")
      click_link 'A3'
      #pause
      tr = page.find('#main tbody tr', text: 'Paper Size')
      expect(tr).to have_css("button", text: "A3")
      click_link 'A4'
      tr = page.find('#main tbody tr', text: 'Paper Size')
      expect(tr).to have_css("button", text: "A4")
      click_link 'Letter'
      tr = page.find('#main tbody tr', text: 'Paper Size')
      expect(tr).to have_css("button", text: "Letter")
    end

    it "allows table rows to be amended", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "10")
      expect(tr).to have_css("a", text: "5")
      expect(tr).to have_css("a", text: "15")
      expect(tr).to have_css("a", text: "25")
      expect(tr).to have_css("a", text: "50")
      expect(tr).to have_css("a", text: "100")
      expect(tr).to have_css("a", text: "All")
      click_link '25'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "25")
      click_link 'All'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "All")
      click_link '100'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "100")
    end

    it "settings are user specific", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "10")
      click_link '50'
      expect(tr).to have_css("button", text: "50")
      click_link 'logoff_button'
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "10")
      #pause
      click_link '25'
      expect(tr).to have_css("button", text: "25")
      click_link 'logoff_button'
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "50")
      click_link 'logoff_button'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      expect(tr).to have_css("button", text: "25")
    end

  end

end