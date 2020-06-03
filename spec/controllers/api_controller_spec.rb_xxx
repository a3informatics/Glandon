require 'rails_helper'

describe ApiController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api"
  end

  def set_http_request
  	# JSON and username, password
  	request.env['HTTP_ACCEPT'] = "application/json"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
  end

  describe "API Access Permitted" do

    before :all do
    	clear_triple_store
	    load_schema_file_into_triple_store("ISO11179Types.ttl")
	    load_schema_file_into_triple_store("ISO11179Identification.ttl")
	    load_schema_file_into_triple_store("ISO11179Registration.ttl")
	    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
	    load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end
    
    after :all do
    end
    
    def set_http_request
  		# JSON and username, password
  		request.env['HTTP_ACCEPT'] = "application/json"
    	request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
  	end

  	it "discover" do
  		expected = 
      [
        "Form", "SDTM Sponsor Domain", "SDTM IG Domain", "SDTM Model Domain", 
        "SDTM Model", "SDTM Implementation Guide", "Biomedical Concept", 
        "Biomedical Concept Template", "Thesaurus"
      ]
      set_http_request
      get :discover
      result = JSON.parse(response.body)
      expect(result).to match_array(expected)
      expect(response.status).to eq 200
    end

    it "index" do
      set_http_request
      get :index, {label: "Form"}
      result = JSON.parse(response.body)
    #Xwrite_yaml_file(result, sub_dir, "index_expected_1.yml")
      expected = read_yaml_file(sub_dir, "index_expected_1.yml")
      expect(result).to hash_equal(expected)
      expect(response.status).to eq 200
    end

    it "index, no label" do
      expected = [["errors", ["The label  was not recognized."]]]
      set_http_request
      get :index, {type: "Form"}
      result = JSON.parse(response.body)
      expect(result).to match_array(expected)
      expect(response.status).to eq 422
    end

    it "list" do
      set_http_request
      get :list, {label: "Form"}
      result = JSON.parse(response.body)
    #Xwrite_yaml_file(result, sub_dir, "list_expected_1.yml")
      expected = read_yaml_file(sub_dir, "list_expected_1.yml")
      expect(result).to hash_equal(expected)
      expect(response.status).to eq 200
    end

    it "show" do
      set_http_request
      get :show, {id: "F-ACME_T2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      result = JSON.parse(response.body)
    #Xwrite_yaml_file(result, sub_dir, "show_expected_1.yml")
      expected = read_yaml_file(sub_dir, "show_expected_1.yml")
      expect(result).to eq(expected)
      expect(response.status).to eq 200
    end

    it "show, error" do
      expected = [["errors", ["The URI did not refer to a supported type."]]]
      set_http_request
      get :show, {id: "Form", namespace: ""}
      result = JSON.parse(response.body)
      expect(result).to match_array(expected)
      expect(response.status).to eq 422
    end

  end

  describe "Unauthorized User" do
    
    it "discover" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :discover
      expect(response.status).to eq 401
    end

    it "index" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index, { type: 'Form'}
      expect(response.status).to eq 401
    end

    it "list" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :list, { type: 'Form'}
      expect(response.status).to eq 401
    end

    it "show" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, {id: "", namespace: ""}
      expect(response.status).to eq 401
    end

  end

end
