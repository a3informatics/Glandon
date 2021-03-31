require 'rails_helper'

describe TherapeuticAreasController do

  include DataHelpers
  include ControllerHelpers
  include TherapeuticAreaFactory
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/therapeutic_areas"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      ta1 = create_therapeutic_area("TA1", "Therapeutic Area 1")
      ta2 = create_therapeutic_area("TA2", "Therapeutic Area 2")
      ta3 = create_therapeutic_area("TA3", "Therapeutic Area 3")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "show" do
      ta = TherapeuticArea.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/TA2/V1#TA"))
      get :show, params: { :id => ta.id}
      expect(response).to render_template("show")
    end

    it "shows the history, page" do
      item = TherapeuticArea.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/TA2/V1#TA"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(TherapeuticArea).to receive(:history_pagination).with({identifier: item.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([item])
      get :history, params:{therapeutic_area: {identifier: item.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "shows the history, initial view" do
      params = {}
      expect(TherapeuticArea).to receive(:latest).and_return(TherapeuticArea.new)
      get :history, params:{therapeutic_area: {identifier: "TA", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("TA")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end