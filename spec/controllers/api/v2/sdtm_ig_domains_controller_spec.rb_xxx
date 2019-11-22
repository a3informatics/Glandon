require 'rails_helper'

describe Api::V2::SdtmIgDomainsController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api/v2/sdtm_ig_domains"
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
    
    it "returns a given domain" do
      set_http_request
      item = SdtmIgDomain.find("IG-CDISC_SDTMIGRS", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      get :show, id: Base64.strict_encode64(item.uri.to_s)
      result_hash = JSON.parse(response.body)
    #Xwrite_yaml_file(result_hash, sub_dir, "show_expected_1.yaml")  
      expected = read_yaml_file(sub_dir, "show_expected_1.yaml")
      expected["children"].sort_by! {|u| u["ordinal"]} # Use old results file, re-order before comparison
      expect(result_hash).to eq(expected)
      expect(response.status).to eq 200
    end

    it "returns a given domain, not found" do
      set_http_request
      get :show, id: Base64.strict_encode64("http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#D-ACME_VSDomain")
      expected_hash = {"errors"=>["Failed to find SDTM IG Domain http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#D-ACME_VSDomain"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "returns a given domain cloned items" do
      set_http_request
      item = SdtmIgDomain.find("IG-CDISC_SDTMIGDM", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
      get :clones, id: Base64.strict_encode64(item.uri.to_s)
      result_hash = JSON.parse(response.body)
    #write_yaml_file(result_hash, sub_dir, "clones_expected_1.yaml")  
      expected = read_yaml_file(sub_dir, "clones_expected_1.yaml")
      expect(response.status).to eq 200
    end

    it "returns a given domain cloned items, not found" do
      set_http_request
      get :clones, id: Base64.strict_encode64("http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#D-ACME_VSDomain")
      expected_hash = {"errors"=>["Failed to find SDTM IG Domain http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#D-ACME_VSDomain"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

  end

  describe "Unauthorized User" do
    
    it "rejects unauthorised user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, id: "aaa"
      expect(response.status).to eq 401
    end

  end

end
