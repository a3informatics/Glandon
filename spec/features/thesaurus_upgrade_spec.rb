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
      wait_for_ajax_long
      context_menu_element('history', 4, 'SPONSORUPGRADE', :edit)
      wait_for_ajax_long
      context_menu_element_header(:upgrade)
      expect(page).to have_content 'Upgrade Code Lists SPONSORUPGRADE v0.1.0'
      expect(page).to have_content 'Baseline CDISC CT: 2017-09-29 Release. New version: 2018-12-21 Release.'
      find(:xpath, "//*[@id='changes-cdisc-table']/tbody/tr/td[2]/div[1]").click
      wait_for_ajax_long
      expect(page).to have_content 'Upgrade affected items'
      expect(page).to have_content '(SPONSORUPGRADE)'
      expect(page).to have_content 'EPOCH (NP000123P)'
      expect(page).to have_content 'EPOCH (C99079)'
      find(:xpath, "//*[@id='managed-item-icon-table']/tbody/tr[3]/td[3]/button").click
      wait_for_ajax_long
      expect(page).to have_content 'Item was successfully upgraded'
      find(:xpath, "//*[@id='managed-item-icon-table']/tbody/tr[2]/td[3]/button").click
      wait_for_ajax_long
      expect(page).to have_content 'Item was successfully upgraded'
    end

  end

end
