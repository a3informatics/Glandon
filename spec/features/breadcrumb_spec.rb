require 'rails_helper'

describe "Breadcrumb", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "BusinessDomain.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl", "form_crf_test_1.ttl", "sdtm_model_and_ig.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..43)
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_sys_admin_login
  end

  after :each do
    ua_logoff
  end

  def next_link(link, title, crumb_1, crumb_2, crumb_3, crumb_4="")
    click_link link
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3, crumb_4)
  end

  def next_link_crumb(index, title, crumb_1, crumb_2, crumb_3, crumb_4="")
    ui_click_breadcrumb(index)
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3, crumb_4)
  end

  def next_link_table(row_content, row_link, title, crumb_1, crumb_2, crumb_3, crumb_4="")
    find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{row_link}").click
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3, crumb_4)
  end

  describe "check all breadcrumbs", :type => :feature do

    it "has dashboard breadcrumbs" do
      next_link('Dashboard', "Registration Status Counts", "Dashboard", "", "")
    end

    it "has Registration Authorities breadcrumbs" do
      next_link('Registration Authorities', 'Registration Authorities', "Registration Authorities", "", "")
      next_link('New', 'New Registration Authority', "Registration Authorities", "New", "")
      next_link_crumb(1, 'Registration Authorities', "Registration Authorities", "", "")
    end

    it "has Namespaces breadcrumbs" do
      next_link('Namespaces', 'Namespaces', "Namespaces", "", "")
      next_link('New', 'New Scope Namespace', "Namespaces", "New", "")
      next_link_crumb(1, 'Namespaces', "Namespaces", "", "")
    end

    it "has Edit Locks breadcrumbs" do
      next_link('Edit Locks', 'Index: Edit Locks', "Edit Locks", "", "")
    end

    it "has Upload breadcrumbs" do
      next_link('Upload', 'File Upload', "Upload", "", "")
    end

    it "has Background Jobs breadcrumbs" do
      next_link('Background', 'Index: Background Jobs', "Background", "", "")
    end

    it "has Audit Trail breadcrumbs" do
      next_link('main_nav_at', 'Index: Audit Trail', "Audit Trail", "", "") # Two links, use ids to get both
    end

    it "has Ad Hoc Reports breadcrumbs" do
      next_link('Ad Hoc Reports', 'Index: Ad-Hoc Reports', "Ad-hoc Reports", "", "")
      next_link('New', 'New Ad-Hoc Report:', "Ad-hoc Reports", "New", "")
      next_link_crumb(1, 'Index: Ad-Hoc Reports', "Ad-hoc Reports", "", "")
    end

    it "has Tags breadcrumbs" do
      next_link('Tags', 'Tag Viewer', "", "", "")
    end

    #it "has Notepad breadcrumbs" do
    #  next_link('Notepad', 'Index: Notepad', "Notepad", "", "")
    #end

    it "has Markdown breadcrumbs" do
      next_link('Markdown', 'Markdown', "Markdown", "", "")
    end

    it "has Terminology breadcrumbs" do
      next_link('Terminology', 'Index: Terminology', "Terminology", "", "")
      next_link('New', 'New Terminology:', "Terminology", "New", "")
      next_link_crumb(1, 'Index: Terminology', "Terminology", "", "")
      next_link('Search Current', 'Search: All Current Terminology', "Terminology", "Search Current", "")
      next_link_crumb(1, 'Index: Terminology', "Terminology", "", "")
      next_link_table("CDISC Terminology 2015-12-18", "History", "History:", "Terminology", "CDISC Terminology", "")
      next_link_table("CDISC Terminology 2015-12-18", "Show", "Show:", "Terminology", "CDISC Terminology", "Show: V43.0.0")
      next_link_crumb(2, 'History:', "Terminology", "CDISC Terminology", "")
      next_link_table("CDISC Terminology 2015-12-18", "View", "View:", "Terminology", "CDISC Terminology", "View: V43.0.0")
      next_link_crumb(2, 'History:', "Terminology", "CDISC Terminology", "")
      next_link_table("CDISC Terminology 2015-12-18", "Search", "Search:", "Terminology", "CDISC Terminology", "Search: V43.0.0")
      next_link_crumb(2, 'History:', "Terminology", "CDISC Terminology", "")
    end

    it "has CDISC Terminology breadcrumbs"

    it "has Biomedical Concept Templates breadcrumbs" do
      next_link('main_nav_bct', 'Index: Biomedical Concept Templates', "Biomedical Concept Templates", "", "")
      next_link_table("Obs CD", "History", "History: Obs CD", "BC Templates", "Obs CD", "")
      next_link_table("Obs CD", "Show", "Show: Simple Observation CD Biomedical Research Concept Template", "BC Templates", "Obs CD", "Show: V1.0.0")
      next_link_crumb(2, 'History', "BC Templates", "Obs CD", "")
    end

    it "has Biomedical Concepts breadcrumbs" do
      next_link('main_nav_bc', 'Index: Biomedical Concepts', "Biomedical Concepts", "", "")
      next_link('New', 'New: Biomedical Concept', "Biomedical Concept", "New", "")
      next_link_crumb(1, 'Biomedical Concepts', "Biomedical Concepts", "", "")
      next_link_table("BC C49677", "History", "History: BC C49677", "Biomedical Concepts", "BC C49677", "")
      next_link_table("1.0.0", "Show", "Show: Heart Rate (BC C49677)", "Biomedical Concepts", "BC C49677", "Show: V1.0.0")
      next_link_crumb(2, 'History', "Biomedical Concepts", "BC C49677", "")
      next_link_table("1.0.0", "Status", "Status: Heart Rate (BC C49677)", "Biomedical Concepts", "BC C49677", "Status: V1.0.0")
      next_link_crumb(2, 'History', "Biomedical Concepts", "BC C49677", "")
      next_link_table("2016-Jan-01, 00:00", "Edit", "Comments: Heart Rate (BC C49677)", "Biomedical Concepts", "BC C49677", "Comments: V1.0.0")
      next_link_crumb(2, 'History', "Biomedical Concepts", "BC C49677", "")
    end

    it "has Forms breadcrumbs" do
      next_link('Forms', 'Index: Forms', "Forms", "", "")
      next_link('New', 'New Form:', "Forms", "New", "")
      next_link_crumb(1, 'Forms', "Forms", "", "")
      next_link('New Placeholder', 'New Placeholder Form:', "Forms", "New Placeholder", "")
      next_link_crumb(1, 'Forms', "Forms", "", "")
      next_link_table("CRF TEST 1", "History", "History: CRF TEST 1", "Forms", "CRF TEST 1", "")
      next_link_table("CRF TEST 1", "Show", "Show: CRF Test Form", "Forms", "CRF TEST 1", "Show: V0.0.0")
      next_link_crumb(2, 'History:', "Forms", "CRF TEST 1", "")
      next_link_table("CRF TEST 1", "Show", "Show: CRF Test Form", "Forms", "CRF TEST 1", "Show: V0.0.0")
      next_link('Clone', 'Cloning:', "Forms", "CRF TEST 1", "Show: V0.0.0", "Clone")
      next_link_crumb(3, 'Show:', "Forms", "CRF TEST 1", "Show: V0.0.0")
      next_link_crumb(2, 'History:', "Forms", "CRF TEST 1", "")
      next_link_table("CRF TEST 1", "View", "View: CRF Test Form", "Forms", "CRF TEST 1", "View: V0.0.0")
      #next_link('form_view_crf', 'CRF: CRF Test Form', "Forms", "CRF TEST 1", "View: V0.0.0", "CRF")
      #next_link_crumb(3, 'View:', "Forms", "CRF TEST 1", "View: V0.0.0")
      #next_link('form_view_acrf', 'Annotated CRF: CRF Test Form', "Forms", "CRF TEST 1", "View: V0.0.0", "aCRF")
      #next_link_crumb(3, 'View:', "Forms", "CRF TEST 1", "View: V0.0.0")
      next_link_crumb(2, 'History:', "Forms", "CRF TEST 1", "")
      next_link_table("CRF TEST 1", "Status", "Status: CRF Test Form", "Forms", "CRF TEST 1", "Status: V0.0.0")
      next_link_crumb(2, 'History:', "Forms", "CRF TEST 1", "")
    end

    it "has CDISC SDTM Model breadcrumbs" do
      next_link('CDISC SDTM Model', 'History: CDISC SDTM Model', "CDISC SDTM Models", "", "")
    #save_and_open_page
      #next_link_table("SDTM Model 2012-07-16", "Show", "Show: SDTM Model 2012-07-16", "CDISC SDTM Model", "V0.0.0", "")
    end

    it "has CDISC SDTM IGs breadcrumbs" do
      next_link('CDISC SDTM IGs', 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
    #save_and_open_page
      next_link_table("SDTM Implementation Guide 2013-11-26", "Show", "Show:", "CDISC SDTM IGs", "V3.2.0", "")
      next_link_crumb(1, 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
    #save_and_open_page
      next_link('import_button', 'Import CDISC SDTM Implementation Guide Version', "CDISC SDTM IGs", "Import", "")
      next_link_crumb(1, 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
    end

    it "has Domains breadcrumbs"

    it "has users breadcrumbs" do
      next_link('settings_button', 'User Settings', "User Settings", "", "")
    end

    it "has users breadcrumbs" do
      next_link('users_button', 'Users', "Users", "", "")
      next_link('New', 'New: User', "Users", "New", "")
      next_link_crumb(1, 'Users', "Users", "", "")
      next_link_table("content_admin@example.com", "Edit", "Roles For: ", "Users", "", "")
    end

  end

end
