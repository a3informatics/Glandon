require 'rails_helper'

describe "SDTM Model Domains", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  describe "Basic Operations", :type => :feature, js:true do

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

    it "allows the show page to be viewed" do
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'SDTM Model 2013-11-26')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: SDTM Model 2013-11-26 SDTM MODEL (V1.4.0, 3, Standard)'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'SDTMMODEL INTERVENTIONS')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Interventions SDTMMODEL INTERVENTIONS (V1.4.0, 3, Standard)'
    end

    it "*** SDTM IMPORT SEMANTIC VERSION ***"

    it "allows for a SDTM Model to be exported as JSON"

    it "allows for a SDTM Model to be expoerted as TTL"

  end

end
