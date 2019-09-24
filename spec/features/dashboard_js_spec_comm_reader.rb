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
    end

    it "allows access to CDISC changes (REQ-MDR-CT-040)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'See the changes across versions'
      expect(page).to have_content 'Changes across versions'
      expect(page).to have_content 'Controlled Terminology'
      fill_in 'Search:', with: 'C67154'
      ui_check_table_info("changes", 1, 1, 1)
    end

    it "allows access to CDISC submission changes (REQ-MDR-CT-050)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'See submission value changes across versions'
      expect(page).to have_content 'Submission value changes'
      expect(page).to have_content 'Controlled Terminology'
    end

    it "allows access to CDISC search (REQ-MDR-CT-060)", js: true do
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
      click_link 'Search the latest version of CDISC CT'
      expect(page).to have_content 'Search: Controlled Terminology CT '
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

  end

end
