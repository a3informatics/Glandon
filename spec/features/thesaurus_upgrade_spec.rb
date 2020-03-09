require 'rails_helper'

describe "Upgrade", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

  def wait_for_ajax_long
    wait_for_ajax(20)
  end

  def click_row_contains(table, text)
    find(:xpath, "//*[@id='#{table}']/tbody/tr[contains(.,'#{text}')]").click
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..58)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("thesaurus_sponsor1_upgrade.ttl")
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    NameValue.create(name: "thesaurus_child_identifier", value: "999")
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator user", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "upgrade", js:true do
      find(:xpath, "//tr[contains(.,'SPONSORUPGRADE')]/td/a").click
      wait_for_ajax 10
      context_menu_element('history', 4, 'SPONSORUPGRADE', :edit)
      wait_for_ajax 20
      context_menu_element_header(:upgrade)
      expect(page).to have_content 'Upgrade Code Lists SPONSORUPGRADE v0.1.0'
      expect(page).to have_content 'Baseline CDISC CT: 2017-09-29 Release. New version: 2018-12-21 Release.'
      wait_for_ajax 20
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 20
      expect(page).to have_content 'Upgrade affected items'
      expect(page).to have_content 'EPOCH (NP000123P)'
      expect(page).to have_content 'EPOCH (C99079)'
      ui_click_tab "Change Details"
      expect(page).to have_content "CDISC SDTM Epoch Terminology"
      ui_check_table_info("changes", 1, 2, 2)
      find(:xpath, "//*[@id='changes']/tbody/tr[contains(.,'Long-term')]/td/a").click
      wait_for_ajax 10
      expect(page).to have_content("Differences")
      ui_check_table_info("differences_table", 1, 4, 4)
      page.go_back
      wait_for_ajax 20
      click_row_contains("changes-cdisc-table", "Epoch")
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'Extension')]/td/button").click
      wait_for_ajax 10
      expect(page).to have_content "Item was successfully upgraded"
      expect(find(:xpath, "//tr[contains(.,'Extension')]/td/button").text).to eq("Cannot upgrade")
      find(:xpath, "//tr[contains(.,'Subset')]/td/button").click
      wait_for_ajax 10
      expect(page).to_not have_content "Error"
      expect(find(:xpath, "//tr[contains(.,'Subset')]/td/button").text).to eq("Cannot upgrade")
    end

  end

end
