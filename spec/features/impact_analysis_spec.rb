require 'rails_helper'

describe "Impact Analysis", :type => :feature do

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
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                    "thesaurus.ttl", "BusinessOperational.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..62)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("thesaurus_sponsor5_impact.ttl")
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    NameValue.create(name: "thesaurus_child_identifier", value: "999")
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator user (sponsor code list level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "impact analysis", js:true do
      find(:xpath, "//tr[contains(.,'SPONSORTHTEST2')]/td/a").click
      wait_for_ajax_long
      context_menu_element('history', 4, 'SPONSORTHTEST2', :edit)
      wait_for_ajax_long
      page.find('.card-with-tabs .show-more-btn').click
      sleep 0.2
      ui_dashboard_single_slider '2018-03-30'
      click_button 'Submit selected version'
      wait_for_ajax 50
      click_link 'Return'
      wait_for_ajax 20
      context_menu_element('history', 4, 'SPONSORTHTEST2', :impact_analysis)
      sleep 1
      ui_dashboard_single_slider '2013-06-28'
      click_button 'Select'
      wait_for_ajax 20
      expect(page).to have_content 'You must choose a CDISC release newer than 2013-06-28 Release to view Impact Analysis.'
      context_menu_element('history', 4, 'SPONSORTHTEST2', :impact_analysis)
      sleep 1
      ui_dashboard_single_slider '2019-12-20'
      click_button 'Select'
      wait_for_ajax 20
      expect(page).to have_content 'Impact Analysis SPONSORTHTEST2 v0.1.0'
      expect(page).to have_content 'Impact Analysis SPONSORTHTEST2 v0.1.0'
      expect(page).to have_content 'CDISC CT update from: 2018-03-30 Release - to: 2019-12-20 Release.'
      find(:xpath, "//*[@id='changes-cdisc-table']/tbody/tr/td[2]/div[1]").click
      wait_for_ajax 20
      expect(page).to have_content 'Items affected by the CDISC Code List change'
      expect(page).to have_content '(SPONSORTHTEST2)'
      expect(page).to have_content 'ACN_01 (NP000123P)'
      expect(page).to have_content 'ACN_03 (NP000124C)'
      expect(page).to have_content 'ACN (C66767)'
      find(:xpath, "//*[@id='tab-changes']/div").click
      expect(page).to have_content 'Differences summary'
      expect(page).to have_content 'Changes summary'
      ui_check_table_info("changes",1,2,2)
      find(:xpath, "//*[@id='tab-graph']/div").click
      expect(page).to have_content "The graph's scope is limited to items included in this Terminology."
    end

  end

  

end
