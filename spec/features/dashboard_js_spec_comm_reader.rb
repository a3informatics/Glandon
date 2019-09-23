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
    clear_triple_store
    ua_create
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_cdisc_term_versions(1..59)
    clear_iso_concept_object
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
      expect(page).to have_content 'Created Code List'
      expect(page).to have_content 'Updated Code List'
      expect(page).to have_content 'Deleted Code List'
    end

    it "allows the CDISC Terminology History page to be viewed (REQ-MDR-CT-031)", js:true do
      click_browse_every_version
      ui_check_breadcrumb('CDISC Terminology', '', '', '')
      expect(page).to have_content 'History'
      click_link 'Return'
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
    end

    it "allows access to CDISC changes (REQ-MDR-CT-040)", js: true do
      click_see_changes_all_versions
      ui_check_breadcrumb('CT', 'Changes', '', '')
      expect(page).to have_content 'Changes across versions'
      click_link 'Return'
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
    end

    it "allows access to CDISC submission changes (REQ-MDR-CT-050)", js: true do
      click_submission_value_changes
      expect(page).to have_content 'Submission value changes'
      click_link 'Return'
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
    end
    
    it "allows access to CDISC search (REQ-MDR-CT-060)", js: true do
      click_search_the_latest_version
      ui_check_breadcrumb('Terminology', 'CT', 'Search: V59.0.0', '')
      expect(page).to have_content 'Search: Controlled Terminology CT '
      click_link 'Return'
      expect(page).to have_content 'Changes between two CDISC Terminology versions'    
    end

    it "allows two CDISC versions to be selected and changes between versions displayed (REQ-MDR-UD-090)", js: true do
      ui_dashboard_slider("2012-08-03", "2013-04-12")
      click_link 'Display'
      find(:xpath, "//div[@id='created_div']/a", :text => "CCINVCTYP (C102575)")
      find(:xpath, "//div[@id='updated_div']/a", :text => "AGEU (C66781)")
      find(:xpath, "//div[@id='deleted_div']/a", :text => "AGESPAN (C66780)")
      expect(page).to have_xpath("//div[@id='created_div']/a[@class='item A']", count: 4)
      expect(page).to have_xpath("//div[@id='updated_div']/a[@class='item D']", count: 3)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item S']", count: 6)
      find(:xpath, "//div[@id='created_div']/a[2]").click
      ui_check_breadcrumb('CDISC Terminology', 'Changes', '', '')
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'Changes'
      click_link 'Return'
      expect(page).to have_content 'Changes between two CDISC Terminology versions'
    end

    it "allows two CDISC versions to be selected and creted CL between them to be filtered and displayed", js: true do
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
      expect(page).to have_content 'Changes'
    end

    it "allows two CDISC versions to be selected and deleted CL between them to be filtered and displayed", js: true do
      ui_dashboard_slider("2013-04-12", "2013-06-28")
      click_link 'Display'
      expect(page).to have_xpath("//div[@id='deleted_div']/a", count: 15)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item D']", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 4)
      ui_dashboard_alpha_filter(:deleted, "E")
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item D']", count: 0)
      expect(page).to have_xpath("//div[@id='deleted_div']/a[@class='item E']", count: 4)
      find(:xpath, "//div[@id='deleted_div']/a[6]").click
      ui_check_breadcrumb('CDISC Terminology', 'Changes', '', '')
      expect(page).to have_content 'Differences'
      expect(page).to have_content 'Changes'
    end

  end

end