require 'rails_helper'

describe "Scenario 5 - Domain Clone & BC", :type => :feature do

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
        "ACME_BC_C100396_STD.ttl", "ACME_BC_C100397_STD.ttl", "sdtm_model_and_ig.ttl"]
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

    it "allows a Sponsor Domain to be created and BCs associated", scenario: true, js: true do
      # Clone Domain
      click_navbar_ig_domain
      click_main_table_link "SDTM Implementation Guide 2013-11-26", 'Show'
      expect(page).to have_content 'Show: SDTM Implementation Guide 2013-11-26 SDTM IG (V3.2.0, 3, Standard)'
      secondary_search "QS"
      click_secondary_table_link "SDTM IG QS", 'Show'
      expect(page).to have_content 'Show: Questionnaires SDTM IG QS (V3.2.0, 3, Standard)'
      click_link 'Clone'
      expect(page).to have_content 'Cloning: Questionnaires SDTM IG QS (V3.2.0, 3, Standard)'
      ui_check_input('sdtm_user_domain_prefix', 'QS')
      fill_in 'sdtm_user_domain_label', with: 'Questionnaires'
      click_button 'Clone'
      expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
      expect(page).to have_content 'Questionnaires'

      # Add in EQ-5D-3L BCs
      click_main_table_link "QS Domain", 'History'
      click_main_table_link "0.1.0", 'Show'
      click_link 'BC+'
      expect(page).to have_content 'Add Biomedical Concepts'
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100392']").set(true)
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100393']").set(true)
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100394']").set(true)
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100395']").set(true)
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100396']").set(true)
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_BCC100397']").set(true)
      click_button 'Add'

      # Check audit trail
    #csv = AuditTrail.to_csv
    #write_text_file_2(csv, sub_dir, "scenario_5_audit_trail.csv")
      check_audit_trail("scenario_5_audit_trail.csv")

      # Export the domain
      click_navbar_sponsor_domain
      click_main_table_link 'QS', 'History'
      click_main_table_link '0.1.0', 'Show'
      click_link 'Export Turtle'
      wait_for_specific_download("ACME_QS Domain.ttl")
      rename_file("ACME_QS Domain.ttl", "ACME_QS_Domain_DFT.ttl")
      copy_file_to_db("ACME_QS_Domain_DFT.ttl")

    end

  end

end
