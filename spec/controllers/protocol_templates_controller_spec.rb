require 'rails_helper'

describe ProtocolTemplatesController do

  include DataHelpers
  include UserAccountHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/protocol_templates"
  end

  describe "Simple actions" do
  	
    login_curator

    before :all do
      data_files = ["hackathon_protocol_templates.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "index, JSON" do  
      byebug
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history, JSON" do
      protocol_template = ProtocolTemplate.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/PARALLEL_SIMPLE/V1#PRT"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(ProtocolTemplate).to receive(:history_pagination).with({identifier: protocol_template.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([protocol_template])
      get :history, params:{protocol_template: {identifier: protocol_template.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjVFJBTlNDRUxFUkFURQ==", count: 20, offset: 0}}
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
