require 'rails_helper'

describe "Sidebar Locks", :type => :feature do

  include UiHelpers
  include UserAccountHelpers

  describe "Content Admin", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      ua_create
    end

    before :each do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "prevents access to specific menu items", js:true do
      ui_check_item_locked("main_nav_e")
      ui_check_item_locked("main_nav_aig")
      ui_check_item_locked("main_nav_sd")
      ui_check_item_locked("main_nav_sig")
      ui_check_item_locked("main_nav_sm")
      ui_check_item_locked("main_nav_f")
      ui_check_item_locked("main_nav_bc")
      ui_check_item_locked("main_nav_bct")
    end

  end
end
