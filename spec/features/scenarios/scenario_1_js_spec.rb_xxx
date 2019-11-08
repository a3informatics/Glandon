require 'rails_helper'

describe "Scenario 1 - Terminology", :type => :feature do

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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
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

    it "allows QS Terminology to be created", scenario: true, js: true do
      click_navbar_terminology
      expect_page 'Index: Terminology'
      fill_in 'thesauri_identifier', with: 'QS TERM'
      fill_in 'thesauri_label', with: 'Questionnaire Terminology'
      click_button 'Create'
      expect_page "Terminology was successfully created."
      click_table_link 'QS TERM', 'History'
      expect_page "History: QS TERM"
      context_menu_element("history", 3, "QS Term", :edit)
      expect_page 'Edit: Questionnaire Terminology QS TERM (V0.1.0, 1, Incomplete)'
      #fill_in 'Identifier', with: 'EQ5D3L'
      click_button 'New'
      # PROBLEM: Identifier is now auto-generated!
      expect_page 'EQ5D3L'
      term_editor_row_label(1, "EQ5D 3-Level Terminology", :tab)
      term_editor_notation("EQ5D 3L EXTRA", :tab)
      term_editor_preferred_term("EQ5D3L Extra Terminology", :tab)
      term_editor_synonym("", :tab)
      term_editor_definition("Extra terminology for the EQ5D 3-Level questionnaire.", :return)
      term_editor_edit_children('EQ5D 3L EXTRA')
      term_editor_concept("EQ5D3L", "MOBILITY", "Mobility Results", "EQ5D3L MOBILITY", "Mobility", "",
        "The mobility results scale for EQ-5D-3L")
      term_editor_concept("EQ5D3L", "SELFCARE", "Self-care Results", "EQ5D3L SELF CARE", "Self Care", "",
        "The self-care results scale for EQ-5D-3L")
      term_editor_concept("EQ5D3L", "ACTIVITY", "Usual Activity Results", "EQ5D3L USUAL ACTIVITY", "Usual Activity", "",
        "The usual activity results scale for EQ-5D-3L")
      term_editor_concept("EQ5D3L", "PAIN", "Pain/Discomfort Results", "EQ5D3L PAIN DISCOMFORT", "Pain / Discomfort", "",
        "The pain discomfort results scale for EQ-5D-3L")
      term_editor_concept("EQ5D3L", "ANXIETY", "Anxiety/Depression Results", "EQ5D3L ANXIETY DEPRESSION", "Anxiety / Depression", "",
        "The anxiety / depression results scale for EQ-5D-3L")

      term_editor_edit_children('EQ5D3L.MOBILITY')
      term_editor_concept("EQ5D3L.MOBILITY", "NONE", "No problems", "I have no problems in walking about",
        "I have no problems in walking about", "", "\"I have no problems in walking about\" results.")
      term_editor_concept("EQ5D3L.MOBILITY", "SOME", "Some problems", "I have some problems in walking about",
        "I have some problems in walking about", "", "\"I have some problems in walking about\" results.")
      term_editor_concept("EQ5D3L.MOBILITY", "CONFINED", "Confined to bed", "I am confined to bed",
        "I am confined to bed", "", "\"I am confined to bed\" results.")
      click_button 'Parent'

      term_editor_edit_children('EQ5D3L.SELFCARE')
      term_editor_concept("EQ5D3L.SELFCARE", "NONE", "No problems", "I have no problems with self care",
        "I have no problems with self-care", "", "\"I have no problems with self-care\" results.")
      term_editor_concept("EQ5D3L.SELFCARE", "SOME", "Some problems", "I have some problems washing or dressing myself",
        "I have some problems washing or dressing myself", "", "\"I have some problems washing or dressing myself\" results.")
      term_editor_concept("EQ5D3L.SELFCARE", "UNABLE", "Unable to wash/dress", "I am unable to wash or dress myself",
        "I am unable to wash or dress myself", "", "\"I am unable to wash or dress myself\" results.")
      click_button 'Parent'

      term_editor_edit_children('EQ5D3L.ACTIVITY')
      term_editor_concept("EQ5D3L.ACTIVITY", "NONE", "No problems", "I have no problems with performing my usual activities",
        "I have no problems with performing my usual activities", "", "\"I have no problems with performing my usual activities\" results.")
      term_editor_concept("EQ5D3L.ACTIVITY", "SOME", "Some problems", "I have some problems with performing my usual activities",
        "I have some problems with performing my usual activities", "", "\"I have some problems with performing my usual activities\" results.")
      term_editor_concept("EQ5D3L.ACTIVITY", "UNABLE", "Unable to perform usual activities", "I am unable to perform my usual activities",
        "I am unable to perform my usual activities", "", "\"I am unable to perform my usual activities\" results.")
      click_button 'Parent'

      term_editor_edit_children('EQ5D3L.PAIN')
      term_editor_concept("EQ5D3L.PAIN", "NONE", "No pain", "I have no pain or discomfort",
        "I have no pain or discomfort", "", "\"I have no pain or discomfort\" results.")
      term_editor_concept("EQ5D3L.PAIN", "MODERATE", "Moderate", "I have moderate pain or discomfort",
        "II have moderate pain or discomfort", "", "\"I have moderate pain or discomfort\" results.")
      term_editor_concept("EQ5D3L.PAIN", "EXTREME", "Extreme", "I have extreme pain or discomfort",
        "I have extreme pain or discomfort", "", "\"I have extreme pain or discomfort\" results.")
      click_button 'Parent'

      term_editor_edit_children('EQ5D3L.ANXIETY')
      term_editor_concept("EQ5D3L.ANXIETY", "NONE", "No problems", "I am not anxious or depressed",
        "I am not anxious or depressed", "", "\"I am not anxious or depressed\" results.")
      term_editor_concept("EQ5D3L.ANXIETY", "MODERATE", "Moderate", "I am moderately anxious or depressed",
        "I am moderately anxious or depressed", "", "\"I am moderately anxious or depressed\" results.")
      term_editor_concept("EQ5D3L.ANXIETY", "EXTREME", "Extreme", "I am extremely anxious or depressed",
        "I am extremely anxious or depressed", "", "\"II am extremely anxious or depressed\" results.")
      click_button 'Parent'

      click_button 'Close'
      expect_page "History: QS TERM"

      csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_1_audit_trail.csv")
      check_audit_trail("scenario_1_audit_trail.csv")

      click_navbar_terminology
      click_table_link 'QS TERM', 'History'
      click_table_link 'QS TERM', 'Show'
      click_link 'Export Turtle'
      wait_for_download
      rename_file("ACME_QS TERM.ttl", "ACME_QS_TERM_DFT.ttl")
      copy_file_to_db("ACME_QS_TERM_DFT.ttl")

    end

  end

end
