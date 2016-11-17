require 'rails_helper'

describe "User Settings", :type => :feature do
  
  before :each do
    user = FactoryGirl.create(:user)
  end

  describe "amending settings", :type => :feature do
  
    it "allows correct reader access" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      click_link 'Settings'
      expect(page).to have_content 'User Settings:'
      tr = page.find('#main tbody tr')
      expect(tr).to have_css("a", text: "Letter")
      expect(tr).to have_css("a", text: "A3")
      expect(tr).to have_css("button", text: "A4")
      print page.body
      tr.find('a', :text => "A3").click
      expect(page).to have_current_path(user_settings_path())
      #click_link 'A3'
      print page.body
      #tr = page.find('#main tbody tr')
      #expect(tr).to have_css("a", text: "A4")
      #expect(tr).to have_css("a", text: "A3")
      #expect(tr).to have_css("button", text: "A3")
      #find(:xpath, "//tr/td/a", :text => 'A3').click
      #expect(page).to have_css("button.disabled", :text => "A3")
      #expect(page).to have_xpath("//td/a", :text => 'Letter')
      #expect(page).to have_selector("button", :text => 'A3')
      #expect(page).to have_css("a.btn", :text => "Letter")
      #expect(page).to have_css("a.btn", :text => "A4")
      #click_link 'A4'
      #expect(page).to have_tag("bbuttin.disabled", :text => "A4")
      #expect(page).to have_tag("a.btn", :text => "A3")
      #expect(page).to have_tag("a.btn", :text => "A4")
    end

  end

end