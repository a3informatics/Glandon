require 'rails_helper'

describe "Secnario 2 - Life Cycle", :type => :feature do

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
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V38.ttl")
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("ACME_QS_TERM_DFT.ttl")
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

    it "allows an item to move through the lifecyle", scenario: true, js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'

      click_navbar_terminology
      expect_page 'Index: Terminology'
      click_table_link 'QS TERM', 'History'
      expect_page "History: QS TERM"
      click_table_link 'QS TERM', 'Status'
      
      expect_page "Status: Questionnaire Terminology"
      fill_in 'iso_registration_state_administrativeNote', with: 'First step in the lifecyle.'
      fill_in 'iso_registration_state_unresolvedIssue', with: 'None that we know of.'
      click_button 'state_submit'
      fill_in 'iso_scoped_identifier_versionLabel', with: '1st Draft.'
      click_button 'version_submit'
      fill_in 'iso_registration_state_administrativeNote', with: 'Next step in the lifecyle.'
      fill_in 'iso_registration_state_unresolvedIssue', with: 'Still none that we know of.'
      click_button 'state_submit'
      click_link "Close"
      expect_page 'History: QS TERM'
      
      click_secondary_table_link("0.1.0", "Edit")
      fill_in 'iso_managed_changeDescription', with: 'All initial EQ-5D-3L result values entered'
      fill_in 'iso_managed_explanatoryComment', with: 'No difficulties encountered'
      fill_in 'iso_managed_origin', with: 'See the website http://www.euroqol.org'
      click_button 'Submit'
    #pause
      expect_page 'History: QS TERM'

      click_main_table_link("0.1.0", "Edit")
      term_editor_edit_children('EQ5D 3L EXTRA')
      term_editor_update_notation("EQ5D3L.SELFCARE", "EQ5D3L SELF-CARE", :return)
      click_button 'Close'
      expect_page "History: QS TERM"

      click_main_table_link("0.2.0", "Status")
      fill_in 'iso_registration_state_administrativeNote', with: ''
      fill_in 'iso_registration_state_unresolvedIssue', with: ''
      click_button 'state_submit'
      click_link "Close"
      expect_page 'History: QS TERM'
      
      click_main_table_link("0.2.0", "Edit")
      term_editor_edit_children('EQ5D 3L EXTRA')
      term_editor_edit_children('EQ5D3L.SELFCARE')
      term_editor_update_notation("EQ5D3L.SELFCARE.NONE", "I have no problems with self-care", :return)
      click_button 'Close'
      expect_page "History: QS TERM"
      click_main_table_link("0.3.0", "Status")
      fill_in 'iso_registration_state_administrativeNote', with: ''
      fill_in 'iso_registration_state_unresolvedIssue', with: ''
      click_button 'state_submit'
      fill_in 'iso_scoped_identifier_versionLabel', with: '1st Release.'
      click_button 'version_submit'
      click_link 'Current'
      click_link "Close"
      expect_page 'History: QS TERM'

      csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_2_audit_trail.csv")
      check_audit_trail("scenario_2_audit_trail.csv")

      click_navbar_terminology
      click_main_table_link 'QS TERM', 'History'
      click_main_table_link '1.0.0', 'Show'
      click_link 'Export Turtle'
      wait_for_download
      rename_file("ACME_QS TERM.ttl", "ACME_QS_TERM_STD.ttl")
      copy_file_to_db("ACME_QS_TERM_STD.ttl")

    end

  end

end