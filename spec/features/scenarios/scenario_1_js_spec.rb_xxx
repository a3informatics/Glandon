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
  include NameValueHelpers

  def wait_for_ajax_long
    wait_for_ajax(10)
  end

  def sub_dir
    return "features/scenarios"
  end

  describe "Curator User", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
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
      nv_destroy
      nv_create(parent: "10", child: "999")
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
      ui_create_terminology('QS TERM', 'Questionnaire Terminology')
      find(:xpath, "//tr[contains(.,'Questionnaire Terminology')]/td/a").click
      wait_for_ajax_long
      context_menu_element('history', 4, 'Questionnaire Terminology', :edit)
      expect_page 'QS TERM'
      expect_page 'Questionnaire Terminology'
      expect_page 'Incomplete'
      expect_page '0.1.0'
      
      mobility = term_editor_concept_auto("EQ5D3L MOBILITY", "Mobility", "", "The mobility results scale for EQ-5D-3L")
      self_care = term_editor_concept_auto("EQ5D3L SELF CARE", "Self Care", "", "The self-care results scale for EQ-5D-3L")
      usual = term_editor_concept_auto("EQ5D3L USUAL ACTIVITY", "Usual Activity", "", "The usual activity results scale for EQ-5D-3L")
      discomfort = term_editor_concept_auto("EQ5D3L PAIN DISCOMFORT", "Pain / Discomfort", "", "The pain discomfort results scale for EQ-5D-3L")
      anxiety = term_editor_concept_auto("EQ5D3L ANXIETY DEPRESSION", "Anxiety / Depression", "", "The anxiety / depression results scale for EQ-5D-3L")

      term_editor_edit_children(mobility)
      term_editor_concept_auto("I have no problems in walking about","I have no problems in walking about", "", 
        "\"I have no problems in walking about\" results.", :child)
      term_editor_concept_auto("I have some problems in walking about","I have some problems in walking about", "", 
        "\"I have some problems in walking about\" results.", :child)
      term_editor_concept_auto("I am confined to bed","I am confined to bed", "", 
        "\"I am confined to bed\" results.", :child)
      click_link 'close'

      term_editor_edit_children(self_care)
      term_editor_concept_auto("I have no problems with self care",
        "I have no problems with self-care", "", "\"I have no problems with self-care\" results.", :child)
      term_editor_concept_auto("I have some problems washing or dressing myself",
        "I have some problems washing or dressing myself", "", "\"I have some problems washing or dressing myself\" results.", :child)
      term_editor_concept_auto("I am unable to wash or dress myself",
        "I am unable to wash or dress myself", "", "\"I am unable to wash or dress myself\" results.", :child)
      click_link 'close'

      term_editor_edit_children(usual)
      term_editor_concept_auto("I have no problems with performing my usual activities",
        "I have no problems with performing my usual activities", "", "\"I have no problems with performing my usual activities\" results.", :child)
      term_editor_concept_auto("I have some problems with performing my usual activities",
        "I have some problems with performing my usual activities", "", "\"I have some problems with performing my usual activities\" results.", :child)
      term_editor_concept_auto("I am unable to perform my usual activities",
        "I am unable to perform my usual activities", "", "\"I am unable to perform my usual activities\" results.", :child)
      click_link 'close'

      term_editor_edit_children(discomfort)
      term_editor_concept_auto("I have no pain or discomfort",
        "I have no pain or discomfort", "", "\"I have no pain or discomfort\" results.", :child)
      term_editor_concept_auto("I have moderate pain or discomfort",
        "II have moderate pain or discomfort", "", "\"I have moderate pain or discomfort\" results.", :child)
      term_editor_concept_auto("I have extreme pain or discomfort",
        "I have extreme pain or discomfort", "", "\"I have extreme pain or discomfort\" results.", :child)
      click_link 'close'

      term_editor_edit_children(anxiety)
      term_editor_concept_auto("I am not anxious or depressed",
        "I am not anxious or depressed", "", "\"I am not anxious or depressed\" results.", :child)
      term_editor_concept_auto("I am moderately anxious or depressed",
        "I am moderately anxious or depressed", "", "\"I am moderately anxious or depressed\" results.", :child)
      term_editor_concept_auto("I am extremely anxious or depressed",
        "I am extremely anxious or depressed", "", "\"II am extremely anxious or depressed\" results.", :child)
      click_link 'close'

      click_link 'close'
      expect_page 'QS TERM'
      expect_page 'Questionnaire Terminology'
      expect_page 'Incomplete'
      expect_page '0.1.0'

      csv = AuditTrail.to_csv
    #Xwrite_text_file_2(csv, sub_dir, "scenario_1_audit_trail.csv")
      check_audit_trail("scenario_1_audit_trail.csv")

      # click_navbar_terminology
      # click_table_link 'QS TERM', 'History'
      # click_table_link 'QS TERM', 'Show'
      # click_link 'Export Turtle'
      # wait_for_download
      # rename_file("ACME_QS TERM.ttl", "ACME_QS_TERM_DFT.ttl")
      # copy_file_to_db("ACME_QS_TERM_DFT.ttl")

    end

  end

end
