require 'rails_helper'

describe EndpointsController do

  include DataHelpers
  include ControllerHelpers
  include IsoManagedHelpers
  include EndpointFactory
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/endpoints"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      endpoint1 = create_endpoint("EP1", "Endpoint 1")
      endpoint2 = create_endpoint("EP2", "Endpoint 2")
      endpoint3 = create_endpoint("EP3", "Endpoint 3")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      endpoint = Endpoint.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/EP2/V1#END"))
      get :show, params: { :id => endpoint.id}
      expect(response).to render_template("show")
    end

    it "shows the history, page" do
      endpoint = Endpoint.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/EP2/V1#END"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Endpoint).to receive(:history_pagination).with({identifier: endpoint.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([endpoint])
      get :history, params:{endpoint: {identifier: endpoint.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      fix_dates_hash(actual[:data].first, sub_dir, "history_expected_1.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(actual[:data].first, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(Endpoint).to receive(:latest).and_return(Endpoint.new)
      get :history, params:{endpoint: {identifier: "ENDPOINT", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("ENDPOINT")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end