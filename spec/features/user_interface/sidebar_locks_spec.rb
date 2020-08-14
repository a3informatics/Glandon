require 'rails_helper'

describe "Sidebar Locks", :type => :feature do

  include UiHelpers
  include UserAccountHelpers

  describe "Content Admin", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
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
      ui_check_item_locked("main_nav_bct")
    end

  end
end
