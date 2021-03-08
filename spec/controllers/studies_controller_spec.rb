require 'rails_helper'

describe StudiesController do

  include DataHelpers
  include UserAccountHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/studies"
  end

  describe "Simple actions" do
  	
    login_curator

    before :all do
      data_files = ["study_history.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history, JSON" do
      study = Study.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/STUDY_ONE/V1#ST"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Study).to receive(:history_pagination).with({identifier: study.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([study])
      get :history, params:{study: {identifier: study.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjVFJBTlNDRUxFUkFURQ==", count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history, HTML" do
      params = {}
      expect(Study).to receive(:latest).and_return(Study.new)
      get :history, params:{study: {identifier: "STUDYONE", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjVFJBTlNDRUxFUkFURQ=="}}
      expect(assigns(:identifier)).to eq("STUDYONE")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjVFJBTlNDRUxFUkFURQ==")
      expect(response).to render_template("history")
    end

  end

end
