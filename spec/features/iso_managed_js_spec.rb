require 'rails_helper'

describe "ISO Managed JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include UserAccountHelpers
  include PublicFileHelpers
  include DownloadHelpers
  include SparqlHelpers

  def sub_dir
    return "features/iso_managed"
  end

  before :all do
    ua_create
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "CT_ACME_TEST.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..43)
    clear_iso_concept_object
  end

  after :all do
    ua_destroy
    delete_all_public_test_files
  end

  before :each do
    delete_all_public_test_files
    clear_downloads
  end

  after :each do
    ua_logoff
  end

  describe "Curator User", :type => :feature do

      it "allows the comments to be updated", js: true do
      ua_curator_login
      click_navbar_forms
      expect(page).to have_content 'Index: Forms'
      #pause
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      #pause
      find(:xpath, "//table[@id='secondary']/tbody/tr/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      #pause
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      click_button "Preview"
      #pause
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am the origin")
      fill_in "iso_managed_origin", with: "£±£±"
      expect(page).to have_content 'Please enter valid markdown.'
      ui_set_focus("iso_managed_explanatoryComment")
      wait_for_ajax
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("I am a comment")
      ui_set_focus("iso_managed_changeDescription")
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world. This is a change description")
      fill_in "iso_managed_origin", with: "Origin"
      click_button 'Submit'
      expect(page).to have_content 'Hello world. This is a change description'
      expect(page).to have_content 'I am a comment'
      expect(page).to have_content 'Origin'
    end

    it "allows the comments to be updated, cdisc term", js: true do
      ua_curator_login
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Controlled Terminology')]/td/a").click
      wait_for_ajax(20)
      find(:xpath, "//table[@id='comments_table']/tbody/tr[contains(.,'2015-03-27')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description."
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button 'Submit'
      wait_for_ajax(20)
      expect(page).to have_content 'Hello world. This is a change description.'
      expect(page).to have_content 'I am a comment'
      expect(page).to have_content 'I am the origin'
    end

    it "allows the status to be viewed", js: true do
      ua_curator_login
      click_navbar_cdisc_terminology
      expect(page).to have_content 'Controlled Terminology'
    end

    it "allows the semantic version to be updated", js: true do
      ua_curator_login
      click_navbar_terminology
      click_link 'New Terminology'
      sleep 1
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Submit'
      sleep 1
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax(10)
      # context_menu_element('history', 4, 'Test Terminology', :edit)
      # wait_for_ajax(10)
      # click_link 'Return'
      context_menu_element('history', 4, 'Test Terminology', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content 'Version Control'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")
      click_button "state_submit"
      expect(page).to have_content("Candidate")
      click_button "state_submit"
      expect(page).to have_content("Recorded")
      click_button "state_submit"
      expect(page).to have_content("Qualified")
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[3]").click
      find(:xpath, "//*[@id='version-edit-submit']").click
      ui_check_table_row("version_info", 1, ["Version:", "0.1.0"])
    end

    it "allows items to be exported" #, js: true do
    #   ua_content_admin_login
    #   click_navbar_export
    #   expect(page).to have_content 'Export Centre'
    #   click_link 'Export Forms'
    #   wait_for_ajax(10)
    #   expect(page).to have_content 'Exports'
    #   expect(page).to have_content 'Showing 1 to 2 of 2 entries' # New form added in previous test
    #   public_file_exists?("test", "ACME_VS BASELINE_1.ttl")
    # #Xcopy_file_from_public_files("test", "ACME_VS BASELINE_1.ttl", sub_dir) # Setup results.
    #   find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'Download File').click
    #   file = download_content
    #   write_text_file_2(file, sub_dir, "form_export_results.ttl")
    #   check_triples_fix("form_export_results.ttl", "ACME_VS BASELINE_1.ttl", {last_change_date: true})
    #   delete_data_file(sub_dir, "form_export_results.ttl")
    #   click_link 'Close'
    #   expect(page).to have_content 'Export Centre'
    #   click_link 'Export Terminologies'
    #   expect(page).to have_content 'Exports'
    #   expect(page).to have_content 'Showing 1 to 1 of 1 entries'
    #   click_link 'Close'
    #   expect(page).to have_content 'Export Centre'
    #   click_link 'Export Biomedical Concepts'
    #   wait_for_ajax(10)
    #   expect(page).to have_content 'Showing 1 to 10 of 13 entries'
    #   click_link 'Close'
    # end

  end

end
