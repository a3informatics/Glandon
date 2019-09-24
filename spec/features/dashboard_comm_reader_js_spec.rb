require 'rails_helper'

describe "Community Dashboard JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end
  
  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..59)
    clear_iso_concept_object
    ua_create
  end

    before :each do
      ua_comm_reader_login
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

  describe "Community Reader User", :type => :feature do

    it "allows the dashboard to be viewed (REQ-MDR-UD-090)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      expect(page).to have_content 'Created Code List'
      expect(page).to have_content 'Updated Code List'
      expect(page).to have_content 'Deleted Code List'
    end

    it "allows access to CDISC history (REQ-MDR-CT-031)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'btn-browse-cdisc'
      expect(page).to have_content 'Item History'
      expect(page).to have_content 'Controlled Terminology'
      expect(page).to have_content '2019-06-28 Release'
      expect(page).to have_content '2017-09-29 Release'
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows access to CDISC changes (REQ-MDR-CT-040)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'See the changes across versions'
      expect(page).to have_content 'Changes across versions'
      expect(page).to have_content 'Controlled Terminology'
      fill_in 'Search:', with: 'C67154'
      ui_check_table_info("changes", 1, 1, 1)
      click_link 'Return'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows access to CDISC submission changes (REQ-MDR-CT-050)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'See submission value changes across versions'
      expect(page).to have_content 'Submission value changes'
      expect(page).to have_content 'Controlled Terminology'
      fill_in 'Search:', with: 'Calcium'
      ui_check_table_info("changes", 1, 1, 1)
      click_link 'Start'
      wait_for_ajax_v_long
      ui_check_table_info("changes", 1, 9, 9)
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows access to CDISC search (REQ-MDR-CT-060)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'Search the latest version of CDISC CT'
      expect(page).to have_content 'Search: Controlled Terminology CT '
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows to clear all CDISC search areas (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      click_link 'Search the latest version of CDISC CT'
      ui_check_breadcrumb('Terminology', 'CT', 'Search: V59.0.0', '')
      expect(page).to have_content 'Search: Controlled Terminology CT ' 
      ui_check_table_info("searchTable", 0, 0, 0)
      fill_in 'searchTable_csearch_cl', with: 'C' 
      fill_in 'searchTable_csearch_item', with: 'C' 
      fill_in 'searchTable_csearch_submission_value', with: 'TEST' 
      fill_in 'searchTable_csearch_preferred_term', with: 'TEST' 
      fill_in 'searchTable_csearch_synonym', with: 'TEST CODE' 
      ui_hit_return('searchTable_csearch_synonym')
      wait_for_ajax_v_long
      ui_check_table_info("searchTable", 1, 10, 307)
      click_button 'clearbutton'
      expect(find('#searchTable_csearch_cl')).to have_content('')
      expect(find('#searchTable_csearch_item')).to have_content('')
      expect(find('#searchTable_csearch_submission_value')).to have_content('')
      expect(find('#searchTable_csearch_preferred_term')).to have_content('')
      expect(find('#searchTable_csearch_synonym')).to have_content('')
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows two CDISC versions to be selected and changes between versions displayed (REQ-MDR-UD-090)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      ui_dashboard_slider("2012-08-03", "2013-04-12")
      click_link 'Display'
      find(:xpath, "//div[@id='created_div']/a", :text => "CCINVCTYP (C102575)")
      find(:xpath, "//div[@id='updated_div']/a", :text => "AGEU (C66781)")
      find(:xpath, "//div[@id='deleted_div']/a", :text => "AGESPAN (C66780)")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 4)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 3)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item S']", count: 6)
      find(:xpath, "//div[@id='created_div']/a[2]").click
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'C102584'
      expect(page).to have_content 'Reason For Treatment'
      expect(page).to have_content 'Changes'
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows two CDISC versions to be selected and creted CL between them to be filtered and displayed", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      ui_dashboard_slider("2011-12-09", "2014-09-26")
      click_link 'Display'
      expect(page).to have_xpath("//div[@id='created_div']/a", count: 328)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item Y']", count: 2)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 19)
      ui_dashboard_alpha_filter(:created, "Y")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item Y']", count: 2)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 0)
      ui_dashboard_alpha_filter(:created, "J")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item J']", count: 0)
    end

    it "allows two CDISC versions to be selected and updated CL between them to be filtered and displayed", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      ui_dashboard_slider("2014-06-27", "2014-09-26")
      click_link 'Display'
      expect(page).to have_xpath("//div[@id='updated_div']/a", count: 227)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 11)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item E']", count: 13)
      ui_dashboard_alpha_filter(:updated, "Z")
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item Z']", count: 0)
      ui_dashboard_alpha_filter(:updated, "D")
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 11)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item E']", count: 0)
      find(:xpath, "//div[@id='updated_div']/a[13]").click
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'C111109'
      expect(page).to have_content 'Device Events Category'
      expect(page).to have_content 'Changes'
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

    it "allows two CDISC versions to be selected and deleted CL between them to be filtered and displayed", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      ui_dashboard_slider("2013-04-12", "2013-06-28")
      click_link 'Display'
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 15)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item D']", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 4)
      ui_dashboard_alpha_filter(:deleted, "E")
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item D']", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 4)
      find(:xpath, "//div[@id='deleted_div']/a[6]").click
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'C101817'
      expect(page).to have_content 'European Quality of Life Five Dimension Five Level Scale Test Name'
      expect(page).to have_content 'Changes'
    end

    it "changes back / forward button bug (GLAN-811) extra test", js:true do
      click_see_changes_all_versions
      expect(page).to have_content 'Changes across versions'
      ui_click_back_button
      ui_click_forward_button
      expect(page).to have_content 'Changes across versions'
    end

    it "submission changes back / forward button bug (GLAN-811) extra test", js:true do
      click_submission_value_changes
      expect(page).to have_content 'Submission value changes'
      ui_click_back_button
      ui_click_forward_button
      expect(page).to have_content 'Submission value changes'
      ui_check_breadcrumb('CDISC Terminology', 'Changes', '', '')
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'Changes'
      click_link 'Home'
      expect(page).to have_content 'Changes in CDISC Terminology versions'
    end

  end

end
