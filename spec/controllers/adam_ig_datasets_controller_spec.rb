require 'rails_helper'

describe AdamIgDatasetsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/adam_ig_datasets"
    end

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/adam_ig/ADAM_IG_V1.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      adam_ig_dataset = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.cdisc.org/BDS/V1"))
      get :show, params: { :id => adam_ig_dataset.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      adam_ig_dataset = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.cdisc.org/BDS/V1"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: adam_ig_dataset.id, adam_ig_dataset:{count: 10, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      adam_ig_dataset = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.cdisc.org/BDS/V1"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(AdamIgDataset).to receive(:history_pagination).with({identifier: adam_ig_dataset.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([adam_ig_dataset])
      get :history, params:{adam_ig_dataset: {identifier: adam_ig_dataset.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(AdamIgDataset).to receive(:latest).and_return(AdamIgDataset.new)
      get :history, params:{adam_ig_dataset: {identifier: "ADAMIG BDS", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("ADAMIG BDS")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end