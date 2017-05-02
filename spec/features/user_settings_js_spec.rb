require 'rails_helper'

describe "User Settings", :type => :feature do
  
  include PauseHelpers
  include UserAccountHelpers

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "amending settings", :type => :feature do
  
    it "allows paper size to be amended", js: true do
      ua_curator_login
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
      ua_curator_login
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

    it "allows edit lock timeout to be amended", js: true do
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "1m")
      expect(tr).to have_css("a", text: "30s")
      expect(tr).to have_css("a", text: "1m 30s")
      expect(tr).to have_css("a", text: "2m")
      expect(tr).to have_css("a", text: "3m")
      expect(tr).to have_css("a", text: "5m")
      click_link '30s'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "30s")
      click_link '1m 30s'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "1m 30s")
      click_link '2m'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "2m")
      click_link '3m'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "3m")
      click_link '5m'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "5m")
      click_link '1m'
      tr = page.find('#main tbody tr', text: 'Edit Lock Warning')
      expect(tr).to have_css("button", text: "1m")
    end

    it "allows display user name to be amended", js: true do
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      expect(page).to have_content 'reader@example.com [Reader]'
      tr = page.find('#main tbody tr', text: 'Display User Name')
      expect(tr).to have_css("button", text: "Yes")
      expect(tr).to have_css("a", text: "No")
      #click_link 'No'
      find(:xpath, "//tr[contains(.,'Display User Name')]/td/a", :text => 'No').click
      expect(page).to have_no_content 'reader@example.com [Reader]'
      expect(page).to have_content '[Reader]'
      tr = page.find('#main tbody tr', text: 'Display User Name')
      expect(tr).to have_css("button", text: "No")
      #click_link 'Yes'
      find(:xpath, "//tr[contains(.,'Display User Name')]/td/a", :text => 'Yes').click
      tr = page.find('#main tbody tr', text: 'Display User Name')
      expect(tr).to have_css("button", text: "Yes")
      expect(page).to have_content 'reader@example.com [Reader]'
    end

    it "allows display user role to be amended", js: true do
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      expect(page).to have_content 'reader@example.com [Reader]'
      tr = page.find('#main tbody tr', text: 'Display User Roles')
      expect(tr).to have_css("button", text: "Yes")
      #click_link 'No'
      find(:xpath, "//tr[contains(.,'Display User Roles')]/td/a", :text => 'No').click
      expect(page).to have_no_content 'reader@example.com [Reader]'
      expect(page).to have_content 'reader@example.com'
      tr = page.find('#main tbody tr', text: 'Display User Roles')
      expect(tr).to have_css("button", text: "No")
      #click_link 'Yes'
      find(:xpath, "//tr[contains(.,'Display User Roles')]/td/a", :text => 'Yes').click
      tr = page.find('#main tbody tr', text: 'Display User Roles')
      expect(tr).to have_css("button", text: "Yes")
      expect(page).to have_content 'reader@example.com [Reader]'
    end

    it "settings are user specific", js: true do
      ua_curator_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "10")
      click_link '50'
      expect(tr).to have_css("button", text: "50")
      click_link 'logoff_button'
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "10")
      #pause
      click_link '25'
      expect(tr).to have_css("button", text: "25")
      click_link 'logoff_button'
      ua_curator_login
      expect(page).to have_content 'Signed in successfully'
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Table Rows')
      expect(tr).to have_css("button", text: "50")
      click_link 'logoff_button'
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      expect(tr).to have_css("button", text: "25")
    end

    it "allows term display count to be amended", js: true do
      ua_reader_login
      click_link 'settings_button'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr', text: 'Terminology Versions Displayed')
      expect(tr).to have_css("button", text: "8")
      expect(tr).to have_css("a", text: "4")
      expect(tr).to have_css("a", text: "12")
      click_link '4'
      tr = page.find('#main tbody tr', text: 'Terminology Versions Displayed')
      expect(tr).to have_css("button", text: "4")
      click_link '12'
      tr = page.find('#main tbody tr', text: 'Terminology Versions Displayed')
      expect(tr).to have_css("button", text: "12")
      click_link '8'
      tr = page.find('#main tbody tr', text: 'Terminology Versions Displayed')
      expect(tr).to have_css("button", text: "8")
    end

  end

end