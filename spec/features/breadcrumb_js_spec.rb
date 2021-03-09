require 'rails_helper'

describe "Breadcrumb", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_crf_test_1.ttl", "sdtm_model_and_ig.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..55)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_test_bc_template_and_instances
    AdHocReport.destroy_all
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_sys_and_content_admin_login
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

  def next_link_table_css_class(row_content, row_link_class, title, crumb_1, crumb_2, crumb_3, crumb_4="")
    find(:xpath, "//tr[contains(.,'#{row_content}')]/td/a", :class => "#{row_link_class}").click
    expect(page).to have_content title
    ui_check_breadcrumb(crumb_1, crumb_2, crumb_3, crumb_4)
  end

  describe "check all breadcrumbs", :type => :feature do

    it "has dashboard breadcrumbs" , js:true do
      visit 'dashboard'
      ui_check_breadcrumb("Dashboard", "", "", "")
    end

    it "has Registration Authorities breadcrumbs", js:true  do
      click_navbar_regauthorities
      ui_check_breadcrumb("Registration Authorities", "", "", "")
    end

    it "has Namespaces breadcrumbs", js:true  do
      click_navbar_namespaces
      ui_check_breadcrumb("Namespaces", "", "", "")
    end

    it "has Edit Locks breadcrumbs" , js:true do
      click_navbar_el
      ui_check_breadcrumb("Edit Locks", "", "", "")
    end

    it "has Upload breadcrumbs", js:true  do
      click_navbar_upload
      ui_check_breadcrumb("Upload", "", "", "")
    end

    it "has Background Jobs breadcrumbs", js:true  do
      click_navbar_background_jobs
      ui_check_breadcrumb("Background Jobs", "", "", "")
    end

    it "has Audit Trail breadcrumbs", js:true  do
      click_navbar_at
      ui_check_breadcrumb("Audit trail", "", "", "")
    end

    it "has Ad Hoc Reports breadcrumbs", js:true  do
      click_navbar_ahr
      ui_check_breadcrumb("Ad Hoc Reports", "", "", "")
      next_link('Add New', 'New Ad-Hoc Report', "Ad Hoc Reports", "New", "")
      next_link_crumb(1, 'Index: Ad-Hoc Reports', "Ad Hoc Reports", "", "")
    end

    it "has Tags breadcrumbs", js:true  do
      click_navbar_tags
      ui_check_breadcrumb("Tags", "", "", "")
    end

    #it "has Notepad breadcrumbs" do
    #  next_link('Notepad', 'Index: Notepad', "Notepad", "", "")
    #end

    it "has Markdown breadcrumbs", js:true  do
      click_navbar_ma
      ui_check_breadcrumb("Markdown", "", "", "")
    end

    it "has Terminology breadcrumbs", js:true  do
      click_navbar_terminology
      ui_check_breadcrumb("Terminology", "", "", "")

      # Search Terms
      click_on 'Search Terminologies'
      ui_in_modal do
        click_on 'Search in Latest'
      end
      wait_for_ajax 10 
      
      expect(page).to have_content "Search Latest"
      ui_check_breadcrumb("Terminology", "Search", "", "")
      next_link_crumb(1, 'Index: Terminology', "Terminology", "", "")

      find(:xpath, "//tr[1]/td/a").click
      expect(page).to have_content "Version History of 'CT'"
      ui_check_breadcrumb("Terminology", "CDISC, CT", "", "")
      wait_for_ajax 20
      ui_table_search('history', '2015-03-27')
      context_menu_element_v2('history', '2015-03-27 Release', :show)
      wait_for_ajax 20
      ui_check_breadcrumb("Terminology", "CDISC, CT", "V43.0.0", "")
      next_link_crumb(2, "Version History of 'CT'", "Terminology", "CDISC, CT", "")
      wait_for_ajax 20
      ui_table_search('history', '2015-03-27')
      context_menu_element_v2('history', '2015-03-27 Release', :search)
      wait_for_ajax 20
      ui_check_breadcrumb("Terminology", "CDISC, CT", "V43.0.0", "")
      next_link_crumb(2, "Version History of 'CT'", "Terminology", "CDISC, CT", "")
    end

    it "has Code list breadcrumbs", js:true  do
      click_navbar_terminology
      ui_check_breadcrumb("Terminology", "", "", "")
      find(:xpath, "//tr[contains(.,'CT')]/td/a").click
      expect(page).to have_content "Version History of 'CT'"
      ui_check_breadcrumb("Terminology", "CDISC, CT", "", "")
      wait_for_ajax(120)
      ui_table_search('history', '2015-03-27')
      context_menu_element_v2('history', '2015-03-27 Release', :show)
      wait_for_ajax(120)
      ui_check_breadcrumb("Terminology", "CDISC, CT", "V43.0.0", "")
      next_link_table("C99079", "Show", "Code List Items", "Terminology", "CDISC, C99079", "V5.0.0")
      next_link_crumb(2, "Item History", "Terminology", "CDISC, C99079", "")
    end

    it "has Code list Item breadcrumbs", js:true  do
      click_navbar_terminology
      ui_check_breadcrumb("Terminology", "", "", "")
      find(:xpath, "//tr[contains(.,'CT')]/td/a").click
      expect(page).to have_content "Version History of 'CT'"
      ui_check_breadcrumb("Terminology", "CDISC, CT", "", "")
      wait_for_ajax(120)
      ui_table_search('history', '2015-03-27')
      context_menu_element_v2('history', '2015-03-27 Release', :show)
      wait_for_ajax(120)
      ui_check_breadcrumb("Terminology", "CDISC, CT", "V43.0.0", "")
      next_link_table("C99079", "Show", "Code List Items", "Terminology", "CDISC, C99079", "V5.0.0")
      next_link_table("C99158", "Show", "FOLLOW-UP", "Terminology", "CDISC, C99079", "V5.0.0", "Show")
      next_link_crumb(3, 'EPOCH', "Terminology", "CDISC, C99079", "V5.0.0")
    end

    it "has CDISC Terminology breadcrumbs"

    # it "has Biomedical Concept Templates breadcrumbs", js:true  do
    #   click_navbar_bct
    #   ui_check_breadcrumb("Biomedical Concept Templates", "", "", "")
    #   next_link_table("Obs CD", "History", "History: Obs CD", "Biomedical Concept Templates", "CDISC, Obs CD", "")
    #   next_link_table("Obs CD", "Show", "Show: Simple Observation CD Biomedical Research Concept Template", "Biomedical Concept Templates", "CDISC, Obs CD", "V1.0.0")
    #   next_link_crumb(2, 'History', "Biomedical Concept Templates", "CDISC, Obs CD", "")
    # end

    it "has Biomedical Concepts breadcrumbs", js:true  do
      click_navbar_bc
      wait_for_ajax 20
      ui_check_breadcrumb("Biomedical Concepts", "", "", "")
      ui_table_search('index', 'HR')
      find(:xpath, "//tr[contains(.,'HR')]/td/a").click
      wait_for_ajax 20
      ui_check_breadcrumb("Biomedical Concepts", "S-cubed, HR", "", "")
      context_menu_element_v2('history', 'HR', :show)
      wait_for_ajax 20
      ui_check_breadcrumb("Biomedical Concepts", "S-cubed, HR", "V0.1.0", "")
    end

    # it "has Forms breadcrumbs", js:true  do
    #   click_navbar_forms
    #   ui_check_breadcrumb("Forms", "", "", "")
    #   next_link('New', 'New Form:', "Forms", "New", "")
    #   next_link_crumb(1, 'Forms', "Forms", "", "")
    #   next_link('New Placeholder', 'New Placeholder Form:', "Forms", "New Placeholder", "")
    #   next_link_crumb(1, 'Forms', "Forms", "", "")
    #   next_link_table("CRF TEST 1", "History", "History: CRF TEST 1", "Forms", "ACME, CRF TEST 1", "")
    #   next_link_table("CRF TEST 1", "Show", "Show: CRF Test Form", "Forms", "ACME, CRF TEST 1", "V0.0.0")
    #   next_link_crumb(2, 'History:', "Forms", "ACME, CRF TEST 1", "")
    #   next_link_table("CRF TEST 1", "Show", "Show: CRF Test Form", "Forms", "ACME, CRF TEST 1", "V0.0.0")
    #   next_link('Clone', 'Cloning:', "Forms", "ACME, CRF TEST 1", "V0.0.0", "Clone")
    #   next_link_crumb(3, 'Show:', "Forms", "ACME, CRF TEST 1", "V0.0.0")
    #   next_link_crumb(2, 'History:', "Forms", "ACME, CRF TEST 1", "")
    #   next_link_table("CRF TEST 1", "View", "View: CRF Test Form", "Forms", "ACME, CRF TEST 1", "V0.0.0")
    #   #next_link('form_view_crf', 'CRF: CRF Test Form', "Forms", "CRF TEST 1", "View: V0.0.0", "CRF")
    #   #next_link_crumb(3, 'View:', "Forms", "CRF TEST 1", "View: V0.0.0")
    #   #next_link('form_view_acrf', 'Annotated CRF: CRF Test Form', "Forms", "CRF TEST 1", "View: V0.0.0", "aCRF")
    #   #next_link_crumb(3, 'View:', "Forms", "CRF TEST 1", "View: V0.0.0")
    #   next_link_crumb(2, 'History:', "Forms", "ACME, CRF TEST 1", "")
    #   # next_link_table("CRF TEST 1", "Status", "Status: CRF Test Form", "Forms", "ACME, CRF TEST 1", "V0.0.0")
    #   # next_link_crumb(2, 'History:', "Forms", "ACME, CRF TEST 1", "")
    # end

    # it "has CDISC SDTM Model breadcrumbs", js:true  do
    #   click_navbar_sdtm_model
    #   ui_check_breadcrumb("CDISC SDTM Models", "", "", "")
    # end

    # it "has CDISC SDTM IGs breadcrumbs", js:true  do
    #   click_navbar_ig_domain
    #   ui_check_breadcrumb("CDISC SDTM IGs", "", "", "")
    #   next_link_table("SDTM Implementation Guide 2013-11-26", "Show", "Show:", "CDISC SDTM IGs", "CDISC, SDTM IG", "")
    #   next_link_crumb(1, 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
    #   next_link('import_button', 'Import CDISC SDTM Implementation Guide Version', "CDISC SDTM IGs", "Import", "")
    #   next_link_crumb(1, 'History: CDISC SDTM Implementation Guide', "CDISC SDTM IGs", "", "")
    # end

    it "has Domains breadcrumbs"

    it "has users breadcrumbs", js:true  do
      next_link('settings_button', 'User Settings', "User Settings", "", "")
    end

    it "has users breadcrumbs", js:true  do
      next_link("users_button", "Users", "", "", "")
      next_link('New', 'New User Account', "Users", "New", "")
      next_link_crumb(1, 'Users', "Users", "", "")
      next_link_table_css_class("sys_admin@example.com", "edit-user", "Set User Roles", "Users", "Edit", "")
    end

  end

end
