require 'rails_helper'

describe "Ad Hoc Reports", :type => :feature do

  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include PublicFileHelpers
  include DownloadHelpers
  include UserAccountHelpers

  def sub_dir
    return "features"
  end

  describe "Content Admin User", :type => :feature do

    before :all do
      AdHocReport.destroy_all
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
        "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_dm1.ttl", "form_example_dm1_branch.ttl",
        "form_example_vs_baseline_new.ttl", "form_example_general.ttl"]
      load_files(schema_files, data_files)
      clear_downloads
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      delete_all_public_test_files
      copy_file_to_public_files("controllers", "ad_hoc_report_test_1_sparql.yaml", "upload")
      ua_content_admin_login
    end

    it "allows a report to be created (REQ-MDR-AR-010, REQ-MDR-AR-060)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      click_link '+ Add New'
      expect(page).to have_content 'New Ad-Hoc Report'
      select Rails.root.join("public", "upload", "ad_hoc_report_test_1_sparql.yaml"), :from => "ad_hoc_report_files_"
      click_button 'Create report'
      expect(page).to have_content 'Ad-Hoc Reports'
      expect(page).to have_content 'Report was successfully created.'
    end

    it "allows a report to be run (REQ-MDR-AR-020, REQ-MDR-AR-030)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Run').click
      expect(page).to have_content 'Ad-Hoc Report Results'
    end

    it "allows a report to be exported as CSV (REQ-MDR-AR-040)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Run').click
      expect(page).to have_content 'Ad-Hoc Report Results'
      click_link "Export CSV"
      file = download_content
      #write_text_file_2(file, sub_dir, "ad_hoc_csv_export.csv")
      expected = read_text_file_2(sub_dir, "ad_hoc_csv_export.csv")
      expect(file).to eq(expected)
    end

    it "allows a report to be deleted (REQ-MDR-AR-070)", js: true do
      click_navbar_ahr
      expect(page).to have_content 'Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Ad-Hoc Reports'
      expect(page).to_not have_content 'Ad Hoc Report 1'
    end

  end

end
