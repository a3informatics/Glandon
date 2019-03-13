require 'rails_helper'

describe "Scenario 6 - CRF & aCRF", :type => :feature do

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
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
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
      load_test_temp_file_into_triple_store("ACME_BC_C100392_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100393_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100394_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100395_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100396_STD.ttl")
      load_test_temp_file_into_triple_store("ACME_BC_C100397_STD.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      load_test_temp_file_into_triple_store("ACME_QS_Domain_DFT.ttl")
      load_test_temp_file_into_triple_store("ACME_EQ5D3L_DFT.ttl")
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
      #set_screen_size(1500, 900)
      ua_curator_login
    end

    it "allows an annotated CRF to be produced", scenario: true, js: true do
      # View the form
      click_navbar_form
      expect(page).to have_content 'Index: Forms'  
      click_main_table_link "EQ-5D-3L", 'History'
      expect(page).to have_content 'History: EQ5D3L'
      click_main_table_link "0.1.0", 'View'
      expect(page).to have_content 'View: EQ-5D-3L EQ5D3L (V0.1.0, 1, Incomplete)'
      wait_for_ajax
      
      # CRF
      click_link 'CRF'
      expect(page).to have_content 'CRF: EQ-5D-3L EQ5D3L (V0.1.0, 1, Incomplete)'
      click_link 'Close'
      expect(page).to have_content 'View: EQ-5D-3L EQ5D3L (V0.1.0, 1, Incomplete)'
      wait_for_ajax

      # aCRF
      click_link 'aCRF'
      expect(page).to have_content 'Annotated CRF: EQ-5D-3L EQ5D3L (V0.1.0, 1, Incomplete)'
      click_link 'Close'
      expect(page).to have_content 'View: EQ-5D-3L EQ5D3L (V0.1.0, 1, Incomplete)'
      wait_for_ajax
      
      # Check audit trail
      csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_6_audit_trail.csv")
      check_audit_trail("scenario_6_audit_trail.csv")

    end

  end

end