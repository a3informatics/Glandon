require 'rails_helper'

describe "Scenario 3 - Biomedical Concepts", :type => :feature do

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
      load_test_temp_file_into_triple_store("ACME_QS_TERM_STD.ttl")
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
      set_screen_size(1500, 900)
      ua_curator_login
    end

    it "allows Biomedical Concepts to be created", scenario: true, js: true do
      click_navbar_bc
      expect_page 'Index: Biomedical Concepts'
      click_link 'New'
      expect_page 'New: Biomedical Concept'
      fill_in 'biomedical_concept_identifier', with: 'BC C100392'
      fill_in 'biomedical_concept_label', with: 'EQ-5D-3L Mobility'
      ui_table_row_click("ims_list_table", "Obs CD")
      ui_click_by_id("ims_add_button")
      click_button 'Create'
      expect_page "Biomedical Concept was successfully created."
      click_main_table_link 'BC C100392', 'History'
      expect_page "History: BC C100392"
      click_main_table_link 'BC C100392', 'Edit'
      expect_page 'Edit: EQ-5D-3L Mobility BC C100392 (V0.1.0, 1, Incomplete)'
      wait_for_ajax(10) # Wait for everything to load

      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100392" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100392" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value_coded("Mobility\n", 
        [ { cl: "EQ5D3L.MOBILITY", cli: "EQ5D3L.MOBILITY.NONE" }, 
          { cl: "EQ5D3L.MOBILITY", cli: "EQ5D3L.MOBILITY.SOME" },
          { cl: "EQ5D3L.MOBILITY", cli: "EQ5D3L.MOBILITY.CONFINED" }
        ])

      bc_create("BC C100393", "EQ-5D-3L Self-Care", "Obs CD (V1.0.0)")
      bc_scroll_to_editor_table
      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100393" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100393" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value_coded("Self-Care\n", 
        [ { cl: "EQ5D3L.SELFCARE", cli: "EQ5D3L.SELFCARE.NONE" }, 
          { cl: "EQ5D3L.SELFCARE", cli: "EQ5D3L.SELFCARE.SOME" },
          { cl: "EQ5D3L.SELFCARE", cli: "EQ5D3L.SELFCARE.UNABLE" }
        ])

      bc_create("BC C100394", "EQ-5D-3L Usual Activities", "Obs CD (V1.0.0)")
      bc_scroll_to_editor_table
      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100394" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100394" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value_coded("Usual Activities (e.g. work, study, housework, family or leisure activities)\n", 
        [ { cl: "EQ5D3L.ACTIVITY", cli: "EQ5D3L.ACTIVITY.NONE" }, 
          { cl: "EQ5D3L.ACTIVITY", cli: "EQ5D3L.ACTIVITY.SOME" },
          { cl: "EQ5D3L.ACTIVITY", cli: "EQ5D3L.ACTIVITY.UNABLE" }
        ])

      bc_create("BC C100395", "EQ-5D-3L Pain/Discomfort", "Obs CD (V1.0.0)")
      bc_scroll_to_editor_table
      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100395" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100395" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value_coded("Pain / Discomfort\n", 
        [ { cl: "EQ5D3L.PAIN", cli: "EQ5D3L.PAIN.NONE" }, 
          { cl: "EQ5D3L.PAIN", cli: "EQ5D3L.PAIN.MODERATE" },
          { cl: "EQ5D3L.PAIN", cli: "EQ5D3L.PAIN.EXTREME" }
        ])

      bc_create("BC C100396", "EQ-5D-3L Anxiety/Depression", "Obs CD (V1.0.0)")
      bc_scroll_to_editor_table
      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100396" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100396" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value_coded("Anxiety / Depression\n", 
        [ { cl: "EQ5D3L.ANXIETY", cli: "EQ5D3L.ANXIETY.NONE" }, 
          { cl: "EQ5D3L.ANXIETY", cli: "EQ5D3L.ANXIETY.MODERATE" },
          { cl: "EQ5D3L.ANXIETY", cli: "EQ5D3L.ANXIETY.EXTREME" }
        ])

      bc_create("BC C100397", "EQ-5D-3L Visual Analogue Scale", "Obs PQR (V1.0.0)")
      bc_scroll_to_editor_table
      bc_set_cat([{ cl: "C100129", cli: "C66957" }])
      bc_scroll_to_editor_table
      bc_set_test_code([{ cl: "C100136", cli: "C100396" }])
      bc_scroll_to_editor_table
      bc_set_test_name([{ cl: "C100135", cli: "C100396" }])
      bc_scroll_to_editor_table
      bc_set_date_and_time("Date & Time\n")
      bc_scroll_to_editor_table
      bc_set_result_value("Value\n", "3\n")

      bc_scroll_to_all_bc_panel
      click_button 'close_button'
      expect_page "History: BC C100392"

      csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_3_audit_trail.csv")
      check_audit_trail("scenario_3_audit_trail.csv")

      bc_export_ttl("C100392", "DFT")
      bc_export_ttl("C100393", "DFT")
      bc_export_ttl("C100394", "DFT")
      bc_export_ttl("C100395", "DFT")
      bc_export_ttl("C100396", "DFT")
      bc_export_ttl("C100397", "DFT")

    end

  end

end