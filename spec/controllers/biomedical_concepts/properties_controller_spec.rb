require 'rails_helper'

describe BiomedicalConcepts::PropertiesController do

  include DataHelpers
  include PauseHelpers
  
  describe "Reader User" do
    
    login_reader

    def sub_dir
      return "controllers/biomedical_concepts"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    after :all do
    end

    it "gets the property, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, { :id => "BC-ACME_BC_C25208_PerformedClinicalResult_baselineIndicator_BL_value", :namespace => "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file_2(response.body, sub_dir, "show.txt")
      expected = read_text_file_2(sub_dir, "show.txt")
      expect(response.body).to eq(expected)
    end

  end

end