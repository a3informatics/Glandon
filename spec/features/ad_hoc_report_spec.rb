require 'rails_helper'

describe "Audit Trail", :type => :feature do
  
  include PauseHelpers
  include DataHelpers

  describe "Curator", :type => :feature do
  
    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      @user = User.create :email => "curator@example.com", :password => "12345678" 
      @user.add_role :curator
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    it "allows access but no new button" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad Hoc Reports'
      expect(page).to have_no_link 'New'
    end

    it "should not show the destroy button"

    it "shoud allow a report to be run"

    it "should allow the results to be viewed"

  end

  describe "Content Admin", :type => :feature do
  
    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      @user = User.create :email => "content_admin@example.com", :password => "12345678" 
      @user.add_role :content_admin
      AdHocReport.delete_all
      ahr = AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 2", sparql_file: "report_2_sparql.txt", results_file: "report_2_results.yaml", last_run: Time.now, active: false, background_id: 0)
      ahr = AdHocReport.create(label: "Report No. 3", sparql_file: "report_3_sparql.txt", results_file: "report_3_results.yaml", last_run: Time.now, active: false, background_id: 0)
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
    end

    it "allows access and the new button" do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad Hoc Reports'
      save_and_open_page
      expect(page).to have_link 'New'
    end

    it "should show the destroy button"

    it "shoud allow a report to be run"

    it "should allow the results to be viewed"

  end

end