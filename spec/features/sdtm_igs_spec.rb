require 'rails_helper'

describe "SDTM Models", :type => :feature do
  
  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  
  describe "Basic Operations, curator", :type => :feature do
  
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
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
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

    it "allows the history page to be viewed" do
      visit '/sdtm_igs/history'
      #save_and_open_page
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
    end

    it "history allows the show page to be viewed" do
      visit '/sdtm_igs/history'
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
      find(:xpath, "//tr[contains(.,'SDTM Implementation Guide 2013-11-26')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: SDTM Implementation Guide 2013-11-26 SDTM IG (V3.2.0, 3, Standard)'
    end

    it "history allows the status page to be viewed" do
      visit '/sdtm_igs/history'
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
      find(:xpath, "//tr[contains(.,'SDTM Implementation Guide 2013-11-26')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: SDTM Implementation Guide 2013-11-26 SDTM IG (V3.2.0, 3, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
    end

  end

end