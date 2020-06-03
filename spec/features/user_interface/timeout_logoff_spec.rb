require 'rails_helper'

describe "Login Session Timeout - automatic logoff", :type => :feature do

  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  describe "ajax logoff handle", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      ua_create
    end

    after :all do
      ua_destroy
    end

    it "search", js:true do
      ua_content_admin_login
      click_navbar_terminology
      click_link 'Search Terminologies'
      sleep 0.6
      wait_for_ajax(10)
      page.find("#select-all-latest").click
      click_button "Submit and proceed"
      expect(Devise).to receive(:timeout_in).twice.and_return(2.seconds)
      wait_for_ajax(10)
      sleep 3
      ui_term_column_search(:code_list, 'C')
      wait_for_ajax 10
      expect(page).to have_content "You need to sign in or sign up before continuing"
    end

    it "items index in modal", js:true do
      ua_content_admin_login
      click_navbar_terminology
      expect(Devise).to receive(:timeout_in).twice.and_return(2.seconds)
      sleep 3
      click_link 'Search Terminologies'
      wait_for_ajax(10)
      expect(page).to have_content "You need to sign in or sign up before continuing"
    end

    it "compare cdisc", js:true do
      ua_community_reader_login
      expect(Devise).to receive(:timeout_in).twice.and_return(2.seconds)
      sleep 3
      ui_dashboard_slider("2007-03-06", "2007-04-20")
      click_link 'Display'
      wait_for_ajax(10)
      expect(page).to have_content "You need to sign in or sign up before continuing"
    end

  end
end
