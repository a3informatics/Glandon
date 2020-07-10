require 'rails_helper'

describe "Tests validation server", :type => :feature, :remote=> true do

  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include RemoteServerHelpers

  #RemoteServerHelpers.switch_to_remote

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

  describe "Login", :type => :feature do

    before :all do
      puts 'before all'
    end

    before :each do
      puts 'before each'
    end
    
    after :all do
      puts 'after all'
    end

    after :each do
      puts 'after each'
    end
    
    it "Login test - REQ12333", js: true do
      puts '12333'
    end

    it "Login test - REQ12334", js: true do
      puts '12334'
    end

  end

end
