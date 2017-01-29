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

  def next_link(link, title, crumb_1, crumb_2, crumb_3)
    click_link link
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3)    
  end

  def next_link_crumb(index, title, crumb_1, crumb_2, crumb_3)
    ui_click_breadcrumb(index)
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3)    
  end

  def next_link_table(row_content, row_link, title, crumb_1, crumb_2, crumb_3)
    find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :text => "#{row_link}").click
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3)    
  end

  describe "check all breadcrumbs", :type => :feature do
  
    it "has dashboard breadcrumbs" do
      next_link('Dashboard', "Registration Status Counts", "Dashboard", "", "")
    end

    it "has Registration Authorities breadcrumbs" do
      next_link('Registration Authorities', 'Registration Authorities', "Registration Authorities", "", "")
      next_link('New Authority', 'New Registration Authority', "Registration Authorities", "New", "")
    end

    it "has Namespaces breadcrumbs" do
      next_link('Namespaces', 'Namespaces', "Namespaces", "", "")
      next_link('New', 'New Namespace', "Namespaces", "New", "")
    end

    it "has Edit Locks breadcrumbs" do
      next_link('Edit Locks', 'Index: Edit Locks', "Edit Locks", "", "")
    end

    it "has Upload breadcrumbs" do
      next_link('Upload', 'File Upload', "Upload", "", "")
    end

    it "has Background Jobs breadcrumbs" do
      next_link('Background Jobs', 'Show: Background Jobs', "Background", "", "")
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

    it "has Classifications (tags) breadcrumbs"
    
    it "has Notepad breadcrumbs" do
      next_link('Notepad', 'Index: Notepad', "Notepad", "", "")
    end

    it "has Markdown breadcrumbs" do
      next_link('Markdown', 'Markdown', "Markdown", "", "")
    end

    it "has Terminology breadcrumbs"
    it "has CDISC Terminology breadcrumbs"
    it "has Biomedical Concept Templates breadcrumbs"
    it "has Biomedical Concepts breadcrumbs"
    it "has Forms breadcrumbs"
    
    it "has CDISC SDTM Model breadcrumbs" do 
      next_link('CDISC SDTM Model', 'History: CDISC SDTM Model', "CDISC SDTM Models", "", "")
      #save_and_open_page
      #next_link_table("SDTM Model 2012-07-16", "Show", "Show: SDTM Model 2012-07-16", "CDISC SDTM Model", "V0.0.0", "")
    end
    
    it "has CDISC SDTM IGs breadcrumbs"
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