require 'rails_helper'

describe ObjectivesController do

  include DataHelpers
  include ControllerHelpers
  include ObjectiveFactory
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/objectives"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      objective1 = create_objective("OB1", "Objective 1")
      objective2 = create_objective("OB2", "Objective 2")
      objective3 = create_objective("OB3", "Objective 3")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      objective = Objective.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/OB2/V1#OB"))
      get :show, params: { :id => objective.id}
      expect(response).to render_template("show")
    end

    it "shows the history, page" do
      objective = Objective.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/OB2/V1#OB"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Objective).to receive(:history_pagination).with({identifier: objective.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([objective])
      get :history, params:{objective: {identifier: objective.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(Objective).to receive(:latest).and_return(Objective.new)
      get :history, params:{objective: {identifier: "OBJECTIVE", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("OBJECTIVE")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end