require 'rails_helper'

describe Api::V2::ThesaurusConceptsController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api/v2/thesaurus_concepts"
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
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
    end
    
    after :all do
    end
    
    def set_http_request
      # JSON and username, password
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
    end

    it "find a thesaurus concept based on identifier" do
      tc = ThesaurusConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc.set_parent # API will do this
      set_http_request
      get :index, {identifier: "A00021"}
      #expected_hash = {"errors"=>["Failed to find study version with identifier 1"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash[0].deep_symbolize_keys!).to eq(tc.to_json)
      expect(response.status).to eq 200
    end

    it "find a thesaurus concept based on identifier and preferredTerm" do
      tc = ThesaurusConcept.find("THC-A00010", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      set_http_request
      get :index, {notation: "ETHNIC SUBGROUP", preferredTerm: "Ethnic Subgroup"}
      #expected_hash = {"errors"=>["Failed to find study version with identifier 1"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash[0].deep_symbolize_keys!).to eq(tc.to_json)
      expect(response.status).to eq 200
    end

    it "find a thesaurus concept based on identifier and preferredTerm, error" do
      set_http_request
      get :index, {notation: "ETHNIC SUBGROUPxxx", preferredTerm: "Ethnic Subgroup"}
      expected_hash = {"errors"=>["Failed to find Thesaurus Concept with {\"notation\"=>\"ETHNIC SUBGROUPxxx\"}"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "find a thesaurus concept empty request, error" do
      set_http_request
      get :index, {notationX: "ETHNIC SUBGROUP"} # Should be stripped out, key invalid
      expected_hash = {"errors"=>["Failed to find Thesaurus Concept with {}"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "find a thesaurus concept's parent, thesaurus concept" do
      set_http_request
      tc_p = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc_c = ThesaurusConcept.find("THC-A00002", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :parent, id: Base64.strict_encode64(tc_c.uri.to_s)
      result_hash = JSON.parse(response.body)
      expect(result_hash.deep_symbolize_keys!).to eq(tc_p.to_json)
      expect(response.status).to eq 200
    end

    it "find a thesaurus concept's parent, thesaurus" do
      set_http_request
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc_c = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :parent, id: Base64.strict_encode64(tc_c.uri.to_s)
      result_hash = JSON.parse(response.body)
      expect(result_hash.deep_symbolize_keys!).to eq(th.to_json)
      expect(response.status).to eq 200
    end
    
    it "find a thesaurus concept's parent, not found" do
      set_http_request
      get :parent, id: Base64.strict_encode64("http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00002xxx")
      expected_hash = {"errors"=>["Failed to find parent of Thesaurus Concept http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00002xxx"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "returns a given thesaurus concept" do
      set_http_request
      tc = ThesaurusConcept.find("THC-A00010", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :show, id: Base64.strict_encode64(tc.uri.to_s)
      result_hash = JSON.parse(response.body)
      expect(result_hash.deep_symbolize_keys!).to eq(tc.to_json)
      expect(response.status).to eq 200
    end

    it "returns a given thesaurus concept, not found" do
      set_http_request
      tc = ThesaurusConcept.find("THC-A00010", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :show, id: Base64.strict_encode64("http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00010xxx")
      expected_hash = {"errors"=>["Failed to find Thesaurus Concept http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00010xxx"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "find a child of thesaurus concept" do
      set_http_request
      tc_p = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc_c = ThesaurusConcept.find("THC-A00002", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc_c.set_parent
      get :child, {id: Base64.strict_encode64(tc_p.uri.to_s), notation: "APGAR"}
      result_hash = JSON.parse(response.body)
      expect(result_hash.deep_symbolize_keys!).to eq(tc_c.to_json)
      expect(response.status).to eq 200
    end

    it "find a child of thesaurus concept" do
      set_http_request
      tc_p = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :child, {id: Base64.strict_encode64(tc_p.uri.to_s), notation: "APGARx"}
      expected_hash = {"errors"=>["Failed to find Thesaurus Concept with {\"notation\"=>\"APGARx\"}"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

    it "find a child of thesaurus concept" do
      set_http_request
      get :child, {id: Base64.strict_encode64("http://www.assero.co.uk/MDRThesaurus/ACME/V1#XXX"), notation: "APGARx"}
      expected_hash = {"errors"=>["Failed to find Thesaurus Concept http://www.assero.co.uk/MDRThesaurus/ACME/V1#XXX"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

  end

  describe "Unauthorized User" do
    
    it "rejects unauthorised user, index" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.status).to eq 401
    end

    it "rejects unauthorised user, show" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, id: "aaa"
      expect(response.status).to eq 401
    end

    it "rejects unauthorised user, parent" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :parent, id: "aaa"
      expect(response.status).to eq 401
    end

  end

end