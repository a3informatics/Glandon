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
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
        "BusinessOperational.ttl", "BusinessForm.ttl", "BusinessDomain.ttl", "CDISCBiomedicalConcept.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl", "ACME_QS_TERM_STD.ttl",
        "ACME_BC_C100392_STD.ttl", "ACME_BC_C100393_STD.ttl", "ACME_BC_C100394_STD.ttl", "ACME_BC_C100395_STD.ttl",
        "ACME_BC_C100396_STD.ttl", "ACME_BC_C100397_STD.ttl", "sdtm_model_and_ig.ttl", "ACME_QS_Domain_DFT.ttl", "ACME_EQ5D3L_DFT.ttl"]
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
      #set_screen_size(1500, 900)
      ua_curator_login
    end

    after :each do
      ua_logoff
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
