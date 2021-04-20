require 'rails_helper'

describe "Sidebar Locks", :type => :feature do

  include UiHelpers
  include UserAccountHelpers

  describe "Sidebar, Content Admin", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      ua_create
      clear_cookies
    end

    before :each do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      clear_cookies
      ua_destroy
    end

    def clear_cookies
      page.driver.browser.clear_cookies
    end 

    it "prevents access to specific menu items" do
      ui_check_item_locked("main_nav_e")
      ui_check_item_locked("main_nav_bct")
    end

    it "allows to switch between MDR and SWB menu types" do
      sleep 1
      expect(page).to have_selector('.menu-type-button.active', text: 'MDR', count: 1)
      expect(page).to have_selector('.menu-type-button', text: 'SWB', count: 1)
      expect(page).to have_selector('.menu-category', text: 'Dashboard')
      expect(page).to have_selector('.menu-category', text: 'Terminology')

      find('.menu-type-button', text: 'SWB').click
      sleep 0.3
      expect(page).to have_selector('.menu-category', text: 'Dashboard')
      expect(page).to have_selector('.menu-category', text: 'Studies')
      expect(page).to_not have_selector('.menu-category', text: 'Terminology')

      find('.menu-type-button', text: 'MDR').click
      sleep 0.3
      expect(page).to have_selector('.menu-category', text: 'Dashboard')
      expect(page).to have_selector('.menu-category', text: 'Terminology')
    end

    it "persists sidebar closed & open state across pages" do
      expect( ui_navbar_collapsed? ).to eq false
      ui_navbar_toggle
      expect( ui_navbar_collapsed? ).to eq true 

      ui_refresh_page

      expect( ui_navbar_collapsed? ).to eq true 
      ui_navbar_toggle
      expect( ui_navbar_collapsed? ).to eq false

      ui_refresh_page
      expect( ui_navbar_collapsed? ).to eq false
    end

  end
end
