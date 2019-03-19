require 'rails_helper'

describe Api::V2::BiomedicalConceptsController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api/v2/biomedical_concepts"
  end

  def set_http_request
  	# JSON and username, password
  	request.env['HTTP_ACCEPT'] = "application/json"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
  end

  describe "Read Access" do

    before :all do
    	clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end
    
    after :all do
    end
    
    it "returns domains concept linked to" do
      set_http_request
      bc = BiomedicalConcept.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
      vs_uri = UriV3.new(fragment: "D-ACME_VSDomain", namespace: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      vs = SdtmUserDomain.find(vs_uri.fragment, vs_uri.namespace)
      vs.add({bcs: ["#{bc.uri}"]})
      get :domains, id: Base64.strict_encode64(bc.uri.to_s)
      result_hash = JSON.parse(response.body)
    write_yaml_file(result_hash, sub_dir, "domains_expected_1.yaml")  
      expected = read_yaml_file(sub_dir, "domains_expected_1.yaml")
      expect(response.status).to eq 200
    end

    it "returns domains concept linked to, not found" do
      set_http_request
      get :domains, id: Base64.strict_encode64("http://www.assero.co.uk/MDRBCs/V1#BC-ACME")
      expected_hash = {"errors"=>["Failed to find Biomedical Concept http://www.assero.co.uk/MDRBCs/V1#BC-ACME"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

  end

  describe "Unauthorized User" do
    
    it "rejects unauthorised user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :domains, id: "aaa"
      expect(response.status).to eq 401
    end

  end

end
