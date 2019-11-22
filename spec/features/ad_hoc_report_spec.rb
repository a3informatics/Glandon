require 'rails_helper'

describe "Ad Hoc Reports", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PublicFileHelpers

  describe "Curator User", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)

      ua_create
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "allows access but no new or delete buttons (REQ-MDR-AR-NONE)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_no_link 'New'
      #save_and_open_page
      expect(page).to have_no_link 'Delete'
    end

    it "shoud allow a report to be run (REQ-MDR-AR-020)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 2')]/td/a", :text => 'Run').click
      #save_and_open_page
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 2")
    end

    it "should allow the results to be viewed (REQ-MDR-AR-050) - WILL CURRENTLY FAIL - Setup issue" , js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 3')]/td/a", :text => 'Results').click
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 3")
    end

  end

  describe "Content Admin", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      ua_create
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    before :each do
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "allows access and the new and delete buttons (REQ-MDR-AR-010)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_link 'New'
      expect(page).to have_link 'Delete'
    end

    it "shoud allow a report to be created (REQ-MDR-AR-010, REQ-MDR-AR-060)", js:true do
      delete_all_public_test_files
      copy_file_to_public_files("controllers", "ad_hoc_report_test_1_sparql.yaml", "upload")
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      click_link 'New'
      expect(page).to have_content 'New Ad-Hoc Report:'
      select Rails.root.join("public", "upload", "ad_hoc_report_test_1_sparql.yaml"), :from => "ad_hoc_report_files_"
      click_button 'Create'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_content 'Report was successfully created.'
    end

    it "shoud allow a report to be run (REQ-MDR-AR-020)", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 2')]/td/a", :text => 'Run').click
      #save_and_open_page
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 2")
    end

    it "should allow the results to be viewed (REQ-MDR-AR-050) - WILL CURRENTLY FAIL - Setup issue", js:true do
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 3')]/td/a", :text => 'Results').click
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 3")
    end

    it "should handle errors in import files (REQ-MDR-AR-010)", js:true do
      copy_file_to_public_files("models", "ad_hoc_report_test_err_6_sparql.yaml", "upload")
      click_navbar_ahr
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      click_link 'New'
      expect(page).to have_content 'New Ad-Hoc Report:'
      select Rails.root.join("public", "upload", "ad_hoc_report_test_err_6_sparql.yaml"), :from => "ad_hoc_report_files_"
      click_button 'Create'
      expect(page).to have_content 'Report was not created. The SPARQL file contained a syntax error.'
    end

  end

end
