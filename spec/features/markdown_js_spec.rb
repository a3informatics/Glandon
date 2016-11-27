require 'rails_helper'

describe "Markdown", :type => :feature do
  
  include PauseHelpers

  before :all do
    user = User.create :email => "curator@example.com", :password => "12345678" 
    user.add_role :curator
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "valid user", :type => :feature, js: true do

    it "allows markdown" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Markdown'
      expect(page).to have_content 'Raw Markdown:'
      expect(page).to have_content 'Processed Markdown:'
      fill_in "raw_markdown", with: "Hello world I am *here*"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world I am here")
      fill_in "raw_markdown", with: "@@@@@"
      click_button "Validate"
      expect(page).to have_content 'Please enter valid markdown.'
    end

  end

end