require 'rails_helper'

describe SdtmModelDomainsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  describe "Reader User" do
  	
    login_reader

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "show" do
      params = 
      { 
        :id => "M-CDISC_SDTMMODEL_TRIAL_DESIGN", 
        sdtm_model_domain: 
        {
          :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3" 
        }
      }
      get :show, params
      expect(response).to render_template("show")
    end

    it "allows for a SDTM Model to be exported as JSON"

    it "allows for a SDTM Model to be expoerted as TTL"

  end

end