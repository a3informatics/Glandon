require 'rails_helper'

describe "Ad Hoc Reports", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include PublicFileHelpers

  describe "Curator User", :type => :feature do
  
    before :all do
      clear_triple_store
      @user = User.create :email => "curator@example.com", :password => "12345678" 
      @user.add_role :curator
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    after :each do
      click_link 'logoff_button'
    end

    it "allows access but no new or delete buttons" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_no_link 'New'
      #save_and_open_page
      expect(page).to have_no_link 'Delete'
    end

    it "shoud allow a report to be run" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 2')]/td/a", :text => 'Run').click
      #save_and_open_page
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 2")
    end
    
    it "should allow the results to be viewed" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 3')]/td/a", :text => 'Results').click
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 3")
    end

  end

  describe "Content Admin", :type => :feature do
  
    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      @user = User.create :email => "content_admin@example.com", :password => "12345678" 
      @user.add_role :content_admin
      AdHocReport.delete_all
      @ahr1 = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr2 = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      @ahr3 = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    after :each do
      click_link 'logoff_button'
    end

    it "allows access and the new and delete buttons" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_link 'New'
      expect(page).to have_link 'Delete'
    end

    it "shoud allow a report to be created" do
      delete_all_public_test_files
      copy_file_to_public_files("controllers", "ad_hoc_report_test_1_sparql.yaml", "upload")
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      click_link 'New'
      expect(page).to have_content 'New Ad-Hoc Report:'
      select "/Users/daveih/Documents/rails/Glandon/public/upload/ad_hoc_report_test_1_sparql.yaml", :from => "ad_hoc_report_files_"
      click_button 'Create'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_content 'Report was successfully created.'
    end  

    it "shoud allow a report to be run" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 2')]/td/a", :text => 'Run').click
      #save_and_open_page
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 2")
    end
    
    it "should allow the results to be viewed" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Report No. 3')]/td/a", :text => 'Results').click
      expect(page).to have_content("Ad-Hoc Report Results: Report No. 3")
    end

    it "should handle errors in import files" do
      copy_file_to_public_files("models", "ad_hoc_report_test_err_6_sparql.yaml", "upload")
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      click_link 'New'
      expect(page).to have_content 'New Ad-Hoc Report:'
      select "/Users/daveih/Documents/rails/Glandon/public/upload/ad_hoc_report_test_err_6_sparql.yaml", :from => "ad_hoc_report_files_"
      click_button 'Create'
      expect(page).to have_content 'Report was not created. The SPARQL file contained a syntax error.'
    end

  end

end