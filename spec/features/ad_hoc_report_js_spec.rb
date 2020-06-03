require 'rails_helper'

describe "Ad Hoc Reports", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PublicFileHelpers
  include WaitForAjaxHelper
  include DownloadHelpers

  def sub_dir
    return "features/ad_hoc_report"
  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      AdHocReport.delete_all
      delete_all_public_files
      clear_downloads
      copy_file_to_public_files(sub_dir, "terminology_code_lists_sparql.yaml", "upload")
      filename = public_path("upload", "terminology_code_lists_sparql.yaml")
      files = []
      files << filename
      @ahr = AdHocReport.create_report({files: files})
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      delete_all_public_files
      ua_destroy
    end

    it "allows access but no new or delete buttons (REQ-MDR-AR-NONE)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      expect(page).to have_no_link '+ Add New'
      Capybara.ignore_hidden_elements = false
      expect(page).to have_no_link 'Delete'
      Capybara.ignore_hidden_elements = true
    end

    it "shoud allow a report to be run, parameters to be selected (REQ-MDR-AR-020)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology Code Lists", :run)
      sleep 1
      wait_for_ajax(10)
      find(:xpath, "//*[@id='index']/tbody/tr[contains(.,'Controlled Terminology')]").click
      wait_for_ajax(10)
      find(:xpath, "//*[@id='history']/tbody/tr[1]").click
      click_button "Submit and proceed"
      sleep 1
      wait_for_ajax(10)
      expect(page).to have_content("Results of Terminology Code Lists")
    end

    it "should allow the results to be viewed (REQ-MDR-AR-050)" , js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology Code Lists", :results)
      wait_for_ajax(10)
      expect(page).to have_content("Results of Terminology Code Lists")
      ui_check_table_info("results", 1, 10, 34)
      ui_check_table_cell("results", 1, 1, "C65047")
    end

  end

  describe "Content Admin", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      AdHocReport.delete_all
      delete_all_public_files
      copy_file_to_public_files(sub_dir, "terminology_code_lists_sparql.yaml", "upload")
      filename = public_path("upload", "terminology_code_lists_sparql.yaml")
      files = []
      files << filename
      @ahr = AdHocReport.create_report({files: files})
      ua_create
    end

    before :each do
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      delete_all_public_files
      ua_destroy
    end

    it "allows access and the new and delete buttons (REQ-MDR-AR-010)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      expect(page).to have_link '+ Add New'
      Capybara.ignore_hidden_elements = false
      expect(page).to have_link 'Delete'
      Capybara.ignore_hidden_elements = true
    end

    it "allows a report to be deleted (REQ-MDR-AR-070)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology Code Lists", :delete)
      ui_confirmation_dialog true
      ui_check_table_info("main", 0, 0, 0)
    end

    it "shoud allow a report to be created (REQ-MDR-AR-010, REQ-MDR-AR-060)", js:true do
      delete_all_public_test_files
      copy_file_to_public_files(sub_dir, "terminology_list_sparql.yaml", "upload")
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      click_link '+ Add New'
      expect(page).to have_content 'New Ad-Hoc Report'
      select Rails.root.join("public", "upload", "terminology_list_sparql.yaml").to_s, :from => "ad_hoc_report_files_"
      click_button 'Create report'
      expect(page).to have_content 'Ad-Hoc Reports'
      expect(page).to have_content 'Report was successfully created.'
    end

    it "shoud allow a report to be run (REQ-MDR-AR-020, REQ-MDR-AR-030)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology List", :run)
      expect(page).to have_content("Results of Terminology List")
    end

    it "should allow the results to be viewed (REQ-MDR-AR-050)" , js:true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology List", :results)
      expect(page).to have_content("Results of Terminology List")
      wait_for_ajax(10)
      ui_check_table_info("results", 1, 5, 5)
      ui_check_table_cell("results", 4, 4, "4.0.0")
    end

    it "allows a report to be exported as CSV (REQ-MDR-AR-040)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      context_menu_element("main", 5, "Terminology List", :results)
      expect(page).to have_content("Results of Terminology List")
      click_link "Export CSV"
      file = download_content
      # write_text_file_2(file, sub_dir, "ad_hoc_csv_report.csv")
      expected = read_text_file_2(sub_dir, "ad_hoc_csv_report.csv")
      expect(file).to eq(expected)
    end

    it "should handle errors in import files (REQ-MDR-AR-010)", js:true do
      copy_file_to_public_files(sub_dir, "ad_hoc_report_test_err_6_sparql.yaml", "upload")
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      click_link '+ Add New'
      expect(page).to have_content 'New Ad-Hoc Report'
      select Rails.root.join("public", "upload", "ad_hoc_report_test_err_6_sparql.yaml").to_s, :from => "ad_hoc_report_files_"
      click_button 'Create report'
      expect(page).to have_content 'Report was not created. The SPARQL file contained a syntax error.'
    end

  end

end
