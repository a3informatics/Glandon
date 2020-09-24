require 'rails_helper'

describe "Forms", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features/forms"
  end

  describe "Forms", :type => :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_file_into_triple_store("forms/FN000150.ttl")
      load_test_file_into_triple_store("forms/FN000120.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    def edit_form(identifier)
      click_navbar_forms
      wait_for_ajax 20
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2 'history', identifier, :edit
      wait_for_ajax 10
      expect(page).to have_content 'Form Editor'
      page.current_window.maximize
    end

    def check_nodes_count(count)
      page.find('#d3').should have_css('g.node', count: count)
    end

    it "edit page initial state" do
      edit_form('FN000150')

      expect(page).to have_content 'Height (Pilot)'
      expect(page).to have_content 'Identifier: FN000150'
      expect(page).to have_content '0.1.0'
      check_nodes_count(9)

      find('#graph-controls').should have_css('.btn', count: 4)
      find('#graph-controls').should have_css('input', count: 1)
    end

  end

end
