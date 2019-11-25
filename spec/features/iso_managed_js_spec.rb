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
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
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

    it "allows the metadata graph to be viewed"#, js: true do
    #   ua_curator_login
    #   click_navbar_bc
    #   expect(page).to have_content 'Index: Biomedical Concepts'
    #   find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: BC A00003'
    #   find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'Gr-').click
    #   expect(page).to have_content 'Graph:'
    #   expect(page).to have_button('graph_focus', disabled: true)
    #   #expect(page).to have_field('concept_type', disabled: true) # No longer part of view
    #   #expect(page).to have_field('concept_label', disabled: true) # No longer part of view
    #   click_button 'graph_stop'
    #   expect(page).to have_button('graph_focus', disabled: false)
    # end

    it "allows a impact page to be displayed" #, js: true do
    # 	ua_curator_login
    #   click_navbar_bc
    #   ui_check_page_has('Index: Biomedical Concepts')
    #   ui_table_row_link_click('BC C25347', 'History')
    #   ui_check_page_has('History: BC C25347')
    #   ui_table_row_link_click('BC C25347', 'Show')
    #   ui_check_page_has('Show: Height (BC C25347)')
    #   ui_table_row_link_click('BC C25347', 'Impact')
    #   ui_check_page_has('Impact Analysis: Height (BC C25347)')
    #   wait_for_ajax(10)
    #   ui_check_table_row('managed_item_table', 1, ["BC C25347", "Height (BC C25347)", "1.0.0", "0.1"])
    #   ui_check_table_row('managed_item_table', 2, ["VS BASELINE", "Vital Signs Baseline", "0.0.0", ""])
    #   click_button 'close'
    #   ui_check_page_has('Show: Height (BC C25347)')
    #   ui_table_row_link_click('BC C25347', 'Impact')
    #   ui_check_page_has('Impact Analysis: Height (BC C25347)')
    #   #ui_table_row_link_click('VS BASELINE', 'Show')
    #   #ui_check_page_has("Show: Vital Signs Baseline")
    # end

    it "allows the show of an impact item, see above"

    it "allows a impact graph to be clicked"

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
      #pause
      ui_set_focus("iso_managed_explanatoryComment")
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
      expect(page).to have_content 'All Terminologies'
      find(:xpath, "//tr[contains(.,'Controlled Terminology')]/td/a").click
      find(:xpath, "//table[@id='comments_table']/tbody/tr[contains(.,'2015-03-27')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Comments:'
      fill_in "iso_managed_changeDescription", with: "Hello world. This is a change description."
      fill_in "iso_managed_explanatoryComment", with: "I am a comment"
      fill_in "iso_managed_origin", with: "I am the origin"
      click_button 'Submit'
      expect(page).to have_content 'Hello world. This is a change description.'
      expect(page).to have_content 'I am a comment'
      expect(page).to have_content 'I am the origin'
    end

    it "allows the status to be viewed", js: true do
      ua_curator_login
      click_navbar_cdisc_terminology
      expect(page).to have_content 'Controlled Terminology'
    end

    it "allows the status to be updated", js: true do
      ua_curator_login
      click_navbar_forms
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      find(:xpath, "//table[@id='main']/tbody/tr/td/a", :text => 'Status').click
      expect(page).to have_content 'Status:'
      fill_in "iso_scoped_identifier_versionLabel", with: "£±£±"
      click_button "version_submit"
      expect(page).to have_content "Versionlabel contains invalid characters"
      fill_in "iso_scoped_identifier_versionLabel", with: "Draft 1"
      click_button "version_submit"
      ui_check_input("iso_scoped_identifier_versionLabel", "Draft 1")
      #expect(page).to have_content "Draft 1"
      fill_in "iso_registration_state_administrativeNote", with: "£££££££££"
      fill_in "iso_registration_state_unresolvedIssue", with: "Draft 1"
      click_button "state_submit"
      expect(page).to have_content "Administrativenote contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "±§"
      click_button "state_submit"
      expect(page).to have_content "Unresolvedissue contains invalid characters"
      fill_in "iso_registration_state_administrativeNote", with: "Good text"
      fill_in "iso_registration_state_unresolvedIssue", with: "Very good text"
      click_button "state_submit"
      expect(page).to have_content "Current Status: Superseded"
    end

    it "allows the status to be updated, handles standard version", js: true do
      ua_curator_login
      click_navbar_forms
      expect(page).to have_content 'Index: Forms'
      click_link 'New'
      expect(page).to have_content 'New Form:'
      fill_in 'form[identifier]', with: 'A NEW FORM'
      fill_in 'form[label]', with: 'Test New Form'
      click_button 'Create'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test New Form'
      find(:xpath, "//tr[contains(.,'A NEW FORM')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: A NEW FORM'
      find(:xpath, "//tr[contains(.,'A NEW FORM')]/td/a", :text => 'Status').click
      ui_check_table_row("version_info", 1, ["Version:", "0.1.0"])
      ui_check_table_row("version_info", 2, ["Version Label:", ""])
      ui_check_table_row("version_info", 3, ["Internal Version:", "1"])
      fill_in "iso_scoped_identifier_versionLabel", with: "Draft Form"
      click_button "version_submit"
      ui_check_input("iso_scoped_identifier_versionLabel", "Draft Form")
      expect(page).to have_content("Current Status: Incomplete")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Candidate")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Recorded")
      click_button "state_submit"
      expect(page).to have_content("Current Status: Qualified")
      ui_check_table_row("version_info", 1, ["Version:", "0.1.0"])
      click_button "state_submit"
      expect(page).to have_content("Current Status: Standard")
      ui_check_table_row("version_info", 1, ["Version:", "1.0.0"])
      ui_check_table_row("version_info", 2, ["Version Label:", "Draft Form"])
      ui_check_table_row("version_info", 3, ["Internal Version:", "1"])
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
