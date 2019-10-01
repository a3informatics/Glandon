require 'rails_helper'

describe "SDTM Models", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      schema_files = ["ISO11179Types.ttl","ISO11179Identification.ttl", "ISO11179Registration.ttl","ISO11179Concepts.ttl", "thesaurus.ttl",
        "CDISCBiomedicalConcept.ttl", "BusinessOperational.ttl", "BusinessDomain.ttl"]
      data_files = ["iso_registration_authority_real.ttl", "iso_namespace_real.ttl", "BCT.ttl", "BC.ttl", "sdtm_model_and_ig.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
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

    it "allows the history page to be viewed (REQ-MDR-MIT-015)" do
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      #save_and_open_page
    end

    it "history allows the show page to be viewed" do
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'SDTM Model 2013-11-26')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: SDTM Model 2013-11-26 SDTM MODEL (V1.4.0, 3, Standard)'
    end

    it "history allows the status page to be viewed" do
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'SDTM Model 2013-11-26')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: SDTM Model 2013-11-26 SDTM MODEL (V1.4.0, 3, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC SDTM Model'
    end

  end

end
