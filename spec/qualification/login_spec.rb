require 'rails_helper'

describe "Tests validation server", :type => :feature, :remote=> true do

  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include RemoteServerHelpers

  RemoteServerHelpers.switch_to_remote

  describe "Login", :type => :feature do

    it "Login test", js: true do
      visit "/users/sign_in"
      fill_in :placeholder => "Email", :with => 'car@s-cubed.dk'
      fill_in :placeholder => "Password", :with => 'Changeme1%'
      click_button "Log in"
      expect(page).to have_content "Signed in successfully"
    end

    it "Login test - REQ12345", js: true do
    end

  end

end
