require 'rails_helper'

describe Api::V2::ThesauriController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api/v2/thesauri"
  end

  describe "Read Access" do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      load_test_file_into_triple_store("CT_V34.ttl")
      load_test_file_into_triple_store("CT_V35.ttl")
      clear_iso_concept_object
    end
    
    after :all do
    end
    
    def set_http_request
      # JSON and username, password
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
    end

    it "returns a given thesaurus concept" do
      set_http_request
      th =Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      get :show, id: Base64.strict_encode64(th.uri.to_s)
      result_hash = JSON.parse(response.body)
      expect(result_hash.deep_symbolize_keys!).to eq(th.to_json)
      expect(response.status).to eq 200
    end

    it "returns a given thesaurus concept, not found" do
      set_http_request
      get :show, id: Base64.strict_encode64("http://www.assero.co.uk/MDRThesaurus/ACME/V1#XXX")
      expected_hash = {"errors"=>["Failed to find Thesaurus http://www.assero.co.uk/MDRThesaurus/ACME/V1#XXX"]}
      result_hash = JSON.parse(response.body)
      expect(result_hash).to eq(expected_hash)
      expect(response.status).to eq 404
    end

  end

  describe "Unauthorized User" do
    
    it "rejects unauthorised user, show" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, id: "aaa"
      expect(response.status).to eq 401
    end

  end

end