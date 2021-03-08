require 'rails_helper'

describe ProtocolsController do

  include DataHelpers
  include UserAccountHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/protocols"
  end

  describe "Simple actions" do
  	
    login_curator

    before :all do
      data_files = ["hackathon_protocols.ttl"]
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
      protocol = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Protocol).to receive(:history_pagination).with({identifier: protocol.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([protocol])
      get :history, params:{protocol: {identifier: protocol.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjVFJBTlNDRUxFUkFURQ==", count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    # No History View exists yet

    # it "history, HTML" do
    # end

  end

end
