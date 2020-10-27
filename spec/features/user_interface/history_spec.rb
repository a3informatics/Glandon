require 'rails_helper'

describe "History", :type => :feature do

  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl"]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    ua_create

  end

  after :all do
    ua_destroy
  end

  after :each do
    ua_logoff
  end

  describe "Check Views", :type => :feature, js:true do

    it "reader"  do
      ua_reader_login
      click_navbar_forms
      wait_for_ajax 10
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'FN000150')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "Height (Pilot)")
      ui_check_table_cell("history", 1, 7, "Incomplete")
    end

    it "curator"  do
      ua_curator_login
      click_navbar_forms
      wait_for_ajax 10
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'FN000150')]/td/a", :text => 'History').click
      expect(page).to have_content 'Version History of \'FN000150\''
      wait_for_ajax 10
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "Height (Pilot)")
      ui_check_table_cell("history", 1, 7, "Incomplete")
    end

  end

end
