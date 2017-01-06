require 'rails_helper'

describe "SDTM Model Domains", :type => :feature do
  
  include DataHelpers

  describe "Basic Operations", :type => :feature do
  
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
    end

    before :each do
      user = FactoryGirl.create(:user)
      user.add_role :curator
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
    end

    it "allows the show page to be viewed" do
      visit '/sdtm_models/history'
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'SDTM Model 2013-11-26')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: SDTM Model 2013-11-26 SDTM MODEL (1.4, V3, Standard)'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'SDTMMODEL_INTERVENTIONS')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Interventions SDTMMODEL_INTERVENTIONS (1.4, V3, Standard)'  
    end

    it "allows for a SDTM Model to be exported as JSON"

    it "allows for a SDTM Model to be expoerted as TTL"

  end

end