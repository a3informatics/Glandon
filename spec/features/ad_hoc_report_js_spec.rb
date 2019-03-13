require 'rails_helper'

describe "Ad Hoc Reports", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include PublicFileHelpers
  include DownloadHelpers

  def sub_dir
    return "features"
  end

  describe "Content Admin User", :type => :feature do
  
    before :all do
      AdHocReport.destroy_all
      user = User.create :email => "content_admin@example.com", :password => "12345678" 
      user.add_role :content_admin
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_dm1_branch.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      clear_downloads
    end

    after :all do
      user = User.where(:email => "content_admin@example.com").first
      user.destroy
    end

    before :each do
      delete_all_public_test_files
      copy_file_to_public_files("controllers", "ad_hoc_report_test_1_sparql.yaml", "upload")
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a report to be created", js: true do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      click_link 'New'
      expect(page).to have_content 'New Ad-Hoc Report:'
      select "/Users/daveih/Documents/rails/Glandon/public/upload/ad_hoc_report_test_1_sparql.yaml", :from => "ad_hoc_report_files_"
      click_button 'Create'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      expect(page).to have_content 'Report was successfully created.'
    end

    it "allows a report to be run", js: true do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Run').click
      expect(page).to have_content 'Results'
    end

    it "allows a report to be exported as CSV", js: true do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Run').click
      expect(page).to have_content 'Results'
      click_link "Export CSV"
      file = download_content
      #write_text_file_2(file, sub_dir, "ad_hoc_csv_export.csv")
      expected = read_text_file_2(sub_dir, "ad_hoc_csv_export.csv")
      expect(file).to eq(expected)
    end

    it "allows a report to be deleted", js: true do
      click_link 'Ad Hoc Reports'
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'Index: Ad-Hoc Reports'
      find(:xpath, "//tr[contains(.,'Ad Hoc Report 1')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Index: Ad-Hoc Reports'
    end

  end

end