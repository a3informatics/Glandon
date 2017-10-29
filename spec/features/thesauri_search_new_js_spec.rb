require 'rails_helper'

describe "Thesauri Search", :type => :feature do
  
  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include UiHelpers

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Current Search", :type => :feature do
  
    it "handles the all setting", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'Current Settings:'
      tr = page.find('#user_settings tbody tr', text: 'Table Rows')
      click_link '25'
      visit '/thesauri/search_current'
      wait_for_ajax(15)
      #expect(page).to have_content("Showing 25 entries")
      ui_check_page_options("searchTable", { "5" => 5, "10" => 10, "15" => 15, "25" => 25, "50" => 50, "100" => 100})
      click_link 'settings_button'
      click_link 'All'
      visit '/thesauri/search_current'
      wait_for_ajax(15)
      #expect(page).to have_content("Showing 100 entries")
      ui_check_page_options("searchTable", { "5" => 5, "10" => 10, "15" => 15, "25" => 25, "50" => 50, "100" => 100})
    end

  end

end