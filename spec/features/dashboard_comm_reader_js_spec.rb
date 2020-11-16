require 'rails_helper'

describe "Community Dashboard JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include CdiscCtHelpers

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  def check_on_commumity_dashboard
    expect(page).to have_content 'Changes between two CDISC Terminology versions'
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(CdiscCtHelpers.version_range)
    clear_iso_concept_object
    ua_create
  end

    before :each do
      ua_comm_reader_login
      check_on_commumity_dashboard
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

  describe "Community Reader User", :type => :feature do

    it "allows the dashboard to be viewed (REQ-MDR-UD-090)", js: true do
      expect(page).to have_content 'Created Code List'
      expect(page).to have_content 'Updated Code List'
      expect(page).to have_content 'Deleted Code List'
    end

    it "allows access to CDISC history (REQ-MDR-CT-031)", js: true do
      click_browse_every_version
      expect(page).to have_content 'Item History'
      expect(page).to have_content 'Controlled Terminology'
      dates = CdiscCtHelpers.date_version_map
      expect(page).to have_content "#{dates.last} Release"
      expect(page).to have_content "#{dates[-10]} Release"
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows access to CDISC changes (REQ-MDR-CT-040)", js: true do
      click_see_changes_all_versions
      expect(page).to have_content 'Changes across versions'
      expect(page).to have_content 'Controlled Terminology'
      click_link 'Return'
      check_on_commumity_dashboard
    end

    it "allows access to CDISC submission changes (REQ-MDR-CT-050)", js: true do
      click_submission_value_changes
      expect(page).to have_content 'Submission value changes'
      expect(page).to have_content 'Controlled Terminology'
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows access to CDISC search (REQ-MDR-CT-060)", js: true do
      click_search_the_latest_version
      expect(page).to have_content 'Search Terminology'
      expect(page).to have_content 'Controlled Terminology'
      ui_check_table_info("searchTable", 0, 0, 0)
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows access to CDISC show (latest)", js: true do
      click_show_latest_version
      wait_for_ajax(20)
      dates = CdiscCtHelpers.date_version_map
      count = CdiscCtHelpers.cl_count_by_version(dates.count)
      expect(page).to have_content "Controlled Terminology"
      expect(page).to have_content "#{dates.count}.0.0"
      ui_check_table_info("children", 1, 10, count)
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows two CDISC versions to be selected and changes between versions displayed (REQ-MDR-UD-090)", js: true do
      ui_dashboard_slider("2012-08-03", "2013-04-12")
      click_link 'Display'
      wait_for_ajax(10)
      find(:xpath, "//div[@id='created_div']/a", :text => "SCTEST (C103330)")
      find(:xpath, "//div[@id='updated_div']/a", :text => "AGEU (C66781)")
      find(:xpath, "//div[@id='deleted_div']/a", :text => "AGESPAN (C66780)")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 4)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 4)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item S']", count: 8)
      #find(:xpath, "//div[@id='created_div']/a[15]").click
      find(:xpath, "//div[@id='created_div']/a", :text => "CVSLDEXT (C101850)").click
      wait_for_ajax(10)
      expect(page).to have_content 'C101850'
      expect(page).to have_content 'CDISC SDTM Coronary Vessel Disease Extent Terminology'
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'Changes'
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows two CDISC versions to be selected and creted CL between them to be filtered and displayed", js: true do
      ui_dashboard_slider("2011-12-09", "2014-09-26")
      click_link 'Display'
      wait_for_ajax(10)
      expect(page).to have_xpath("//div[@id='created_div']/a", count: 309)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item V']", count: 3)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 3)
      ui_dashboard_alpha_filter(:created, "C")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item Y']", count: 0)
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 0)
      ui_dashboard_alpha_filter(:created, "J")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item J']", count: 0)
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows two CDISC versions to be selected and updated CL between them to be filtered and displayed", js: true do
      ui_dashboard_slider("2014-06-27", "2014-09-26")
      click_link 'Display'
      wait_for_ajax(10)
      expect(page).to have_xpath("//div[@id='updated_div']/a", count: 61)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 4)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item E']", count: 3)
      ui_dashboard_alpha_filter(:updated, "Z")
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item Z']", count: 0)
      ui_dashboard_alpha_filter(:updated, "D")
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 4)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item E']", count: 0)
      find(:xpath, "//*[@id='btn_f_updated']/span[2]").click
      find(:xpath, "//*[@id='btn_f_updated']/span[2]").click
      find(:xpath, "//div[@id='updated_div']/a[34]").click
      wait_for_ajax(10)
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'C111335'
      expect(page).to have_content "CDISC Questionnaire C-SSRS Children's Baseline Test Name Terminology"
      expect(page).to have_content 'Changes'
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "allows two CDISC versions to be selected and deleted CL between them to be filtered and displayed", js: true do
      ui_dashboard_slider("2016-06-24", "2016-09-30")
      click_link 'Display'
      wait_for_ajax(20)
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 11)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item C']", count: 2)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item F']", count: 2)
      ui_dashboard_alpha_filter(:deleted, "C")
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item D']", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 0)
      find(:xpath, "//*[@id='btn_f_deleted']/span[2]").click
      find(:xpath, "//div[@id='deleted_div']/a[6]").click
      wait_for_ajax(20)
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'C114116'
      expect(page).to have_content 'CDISC SDTM Morphology Test Name Terminology'
      expect(page).to have_content 'Changes'
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "changes back / forward button bug (GLAN-811) extra test", js:true do
      click_see_changes_all_versions
      expect(page).to have_content 'Changes across versions'
      ui_click_back_button
      ui_click_forward_button
      expect(page).to have_content 'Changes across versions'
      click_link 'Home'
      check_on_commumity_dashboard
    end

    it "submission changes back / forward button bug (GLAN-811) extra test", js:true do
      click_submission_value_changes
      expect(page).to have_content 'Submission value changes'
      ui_click_back_button
      ui_click_forward_button
      expect(page).to have_content 'Submission value changes'
      click_link 'Home'
      check_on_commumity_dashboard
    end

  end

end
