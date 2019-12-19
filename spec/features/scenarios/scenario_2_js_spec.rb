require 'rails_helper'

describe "Scenario 2 - Life Cycle", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include ScenarioHelpers

  def sub_dir
    return "features/scenarios"
  end

  describe "Curator User", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
        "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl", "ACME_QS_TERM_DFT.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
      Token.destroy_all
      AuditTrail.destroy_all
      clear_downloads
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows an item to move through the lifecyle", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_link 'New Terminology'
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Submit'

      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a").click
      wait_for_ajax(10)
      context_menu_element('history', 4, 'Test Terminology', :document_control)
      wait_for_ajax(10)
      expect(page).to have_content 'Manage Status'
      expect(page).to have_content("Current Status:")
      expect(page).to have_content("Incomplete")

      fill_in '[iso_managed]administrative_note', with: 'First step in the lifecyle.'
      fill_in '[iso_managed]unresolved_issue', with: 'None that we know of.'
      click_button "state_submit"
      expect(page).to have_content("Candidate")

      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: '1st Draft.'
      find(:xpath, "//*[@id='version-label-submit']").click

      fill_in '[iso_managed]administrative_note', with: 'Next step in the lifecyle.'
      fill_in '[iso_managed]unresolved_issue', with: 'Still none that we know of.'
      click_button "state_submit"
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      expect(page).to have_content("Qualified")
      click_link 'Return'
      wait_for_ajax(120)

      find(:xpath, "//*[@id='history']/tbody/tr/td[7]/span/span").click
      wait_for_ajax(120)
      expect(page).to have_css ('.icon-lock-open')
      ui_check_table_info("history", 1, 1, 1)

      context_menu_element('history', 4, 'Test Terminology', :edit)
      wait_for_ajax(120)
      click_link 'Return'

      ui_check_table_info("history", 1, 1, 1)
      find(:xpath, "//*[@id='history']/tbody/tr[1]/td[7]/span/span").click
      expect(page).to have_css ('.icon-lock')

      context_menu_element('history', 4, 'Test Terminology', :edit)
      wait_for_ajax(120)
      click_link 'Return'
      ui_check_table_info("history", 1, 2, 2)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[1]").click #Major release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '1.0.0')

      click_link 'Return'
      wait_for_ajax(120)


      context_menu_element('history', 4, 'Test Terminology', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[2]").click #Minor release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '0.1.0')
      click_link 'Return'
      wait_for_ajax(120)
      ui_check_table_info("history", 1, 3, 3)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      expect(page).to have_content("Standard")
      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :edit, 1)
      wait_for_ajax(120)
      click_link 'Return'
      ui_check_table_info("history", 1, 4, 4)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      expect(page).to have_content("Candidate")

      find(:xpath, "//*[@id='version-label-edit']").click
      fill_in 'iso_scoped_identifier[version_label]', with: 'Standard'
      find(:xpath, "//*[@id='version-label-submit']").click

      click_button "state_submit"
      expect(page).to have_content("Recorded")

      click_button "state_submit"
      expect(page).to have_content("Qualified")
      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      expect(page).to have_content 'Version Control'
      find(:xpath, "//*[@id='version-edit']").click
      find(:xpath, "//*[@id='select-release']/option[1]").click #Major release
      find(:xpath, "//*[@id='version-edit-submit']").click
      wait_for_ajax(120)
      expect(page).to have_xpath('//*[@id="imh_header"]/div/div/div[2]/div[3]/span[4]', text: '1.0.0')

      click_link 'Return'
      wait_for_ajax(120)

      context_menu_element('history', 4, 'Test Terminology', :document_control, 1)
      wait_for_ajax(120)
      click_button "state_submit"
      expect(page).to have_content("Standard")
      click_link 'Return'
      wait_for_ajax(120)

    #   click_navbar_terminology
    #   expect_page 'Index: Terminology'
    #   click_table_link 'QS TERM', 'History'
    #   expect_page "History: QS TERM"
    #   context_menu_element("history", 3, "QS Term", :document_control)
    #   #click_table_link 'QS TERM', 'Status'

    #   expect_page "Status: Questionnaire Terminology"
    #   fill_in 'iso_registration_state_administrativeNote', with: 'First step in the lifecyle.'
    #   fill_in 'iso_registration_state_unresolvedIssue', with: 'None that we know of.'
    #   click_button 'state_submit'
    #   fill_in 'iso_scoped_identifier_versionLabel', with: '1st Draft.'
    #   click_button 'version_submit'
    #   fill_in 'iso_registration_state_administrativeNote', with: 'Next step in the lifecyle.'
    #   fill_in 'iso_registration_state_unresolvedIssue', with: 'Still none that we know of.'
    #   click_button 'state_submit'
    #   click_link "Close"
    #   expect_page 'History: QS TERM'

    #   click_secondary_table_link("0.1.0", "Edit")
    #   fill_in 'iso_managed_changeDescription', with: 'All initial EQ-5D-3L result values entered'
    #   fill_in 'iso_managed_explanatoryComment', with: 'No difficulties encountered'
    #   fill_in 'iso_managed_origin', with: 'See the website http://www.euroqol.org'
    #   click_button 'Submit'
    # #pause
    # wait_for_ajax
    #   expect_page 'History: QS TERM'

    #   click_main_table_link("0.1.0", "Edit")
    #   term_editor_edit_children('EQ5D 3L EXTRA')
    # #pause
    # wait_for_ajax
    #   term_editor_update_notation("EQ5D3L.SELFCARE", "EQ5D3L SELF-CARE", :return)
    # #pause
    # wait_for_ajax
    #   click_button 'Close'
    #   expect_page "History: QS TERM"

    #   click_main_table_link("0.2.0", "Status")
    #   fill_in 'iso_registration_state_administrativeNote', with: ''
    #   fill_in 'iso_registration_state_unresolvedIssue', with: ''
    #   click_button 'state_submit'
    # #pause
    #   click_link "Close"
    #   expect_page 'History: QS TERM'

    #   click_main_table_link("0.2.0", "Edit")
    #   term_editor_edit_children('EQ5D 3L EXTRA')
    # #pause
    # wait_for_ajax
    #   term_editor_edit_children('EQ5D3L.SELFCARE')
    # #pause
    # wait_for_ajax
    #   term_editor_update_notation("EQ5D3L.SELFCARE.NONE", "I have no problems with self-care", :return)
    # #pause
    # wait_for_ajax
    #   click_button 'Close'
    #   expect_page "History: QS TERM"
    #   click_main_table_link("0.3.0", "Status")
    #   fill_in 'iso_registration_state_administrativeNote', with: ''
    #   fill_in 'iso_registration_state_unresolvedIssue', with: ''
    #   click_button 'state_submit'
    #   fill_in 'iso_scoped_identifier_versionLabel', with: '1st Release.'
    #   click_button 'version_submit'
    #   click_link 'Current'
    # #pause
    #   click_link "Close"
    #   expect_page 'History: QS TERM'

    # #csv = AuditTrail.to_csv
    # #write_text_file_2(csv, sub_dir, "scenario_2_audit_trail.csv")
    #   check_audit_trail("scenario_2_audit_trail.csv")

    #   click_navbar_terminology
    #   click_main_table_link 'QS TERM', 'History'
    #   click_main_table_link '1.0.0', 'Show'
    #   click_link 'Export Turtle'
    #   wait_for_download
    #   rename_file("ACME_QS TERM.ttl", "ACME_QS_TERM_STD.ttl")
    #   copy_file_to_db("ACME_QS_TERM_STD.ttl")

    end

  end

end
