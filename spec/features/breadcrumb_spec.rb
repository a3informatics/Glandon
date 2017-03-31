require 'rails_helper'

describe "Breadcrumb", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  
  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    ua_create
    @user_sa.add_role :content_admin # Ensure access to everything, sys & content admin
  end

  after :all do
    ua_destroy
  end

  before :each do
    visit '/users/sign_in'
    fill_in 'Email', with: 'sys_admin@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
  end

  after :each do
    click_link 'logoff_button'
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
      next_link('New Authority', 'New Registration Authority', "Registration Authorities", "New", "")
      next_link_crumb(1, 'Registration Authorities', "Registration Authorities", "", "")
    end

    it "has Namespaces breadcrumbs" do
      next_link('Namespaces', 'Namespaces', "Namespaces", "", "")
      next_link('New', 'New Namespace', "Namespaces", "New", "")
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
      next_link('main_nav_at1', 'Index: Audit Trail', "Audit Trail", "", "") # Two links, use ids to get both
      next_link('main_nav_at2', 'Index: Audit Trail', "Audit Trail", "", "")
    end
    
    it "has Ad Hoc Reports breadcrumbs" do
      next_link('Ad Hoc Reports', 'Index: Ad-Hoc Reports', "Ad-hoc Reports", "", "")
      next_link('New', 'New Ad-Hoc Report:', "Ad-hoc Reports", "New", "")
      next_link_crumb(1, 'Index: Ad-Hoc Reports', "Ad-hoc Reports", "", "")
    end

    it "has Classifications (tags) breadcrumbs" do
      next_link('Classifications (tags)', 'Classifications', "Classifications", "", "")
      next_link('New', 'New Classification', "Classifications", "New", "")
      next_link_crumb(1, 'Classifications', "Classifications", "", "")
      next_link('View', 'Tag Viewer', "Classifications", "View", "")
      next_link_crumb(1, 'Classifications', "Classifications", "", "")
      next_link('New', "New Classification", "Classifications", "New", "", "")
      expect(page).to have_content("New Classification")
      fill_in 'iso_concept_system_label', with: 'XXXX'
      fill_in 'iso_concept_system_description', with: 'XXXX Description'
      click_button 'Create'
    #save_and_open_page
      next_link_table("XXXX", "Show", "Classification:", "Classifications", "Show", "", "")
      next_link('New', "New Tag", "Classifications", "New Tag", "", "")
      expect(page).to have_content("New Tag")
      fill_in 'iso_concept_system_label', with: 'XXXX_1'
      fill_in 'iso_concept_system_description', with: 'XXXX_1 Description'
      click_button 'Create'
      next_link_table("XXXX_1", "Show", "Tag:", "Classifications", "XXXX", "Show", "")
      next_link('New', 'New Tag', "Classifications", "XXXX", "", "")
    sleep 1 # Not sure why this is required but without it get nasty error
      expect(page).to have_content("New Tag")
      fill_in 'iso_concept_system_label', with: 'XXXX_1_1'
      fill_in 'iso_concept_system_description', with: 'XXXX_1_1 Description'
      click_button 'Create'
      next_link_table("XXXX_1_1", "Show", "Tag:", "Classifications", "XXXX", "XXXX_1", "Show")
    #save_and_open_page
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
      next_link('New', 'New Biomedical Concept:', "Biomedical Concept", "New", "")
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
      next_link_table("SDTM Implementation Guide 2013-11-26", "Show", "Show:", "CDISC SDTM IGs", "V0.0.0", "")
      next_link_crumb(1, 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
      next_link('Import', 'Import CDISC SDTM Implementation Guide Version', "CDISC SDTM IGs", "Import", "")
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
      #save_and_open_page
      next_link_table("curator@example.com", "Edit", "Edit User:", "Users", "", "")
    end

  end

end