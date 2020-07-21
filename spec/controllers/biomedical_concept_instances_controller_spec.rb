require 'rails_helper'

describe BiomedicalConceptInstancesController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers/biomedical_concept_instances"
    end

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    after :all do
    end
    
    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :show, params: { :id => bci.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(BiomedicalConceptInstance).to receive(:find_minimum).and_return(bci)
      get :show_data, params:{id: bci.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(BiomedicalConceptInstance).to receive(:history_pagination).with({identifier: instance.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([instance])
      get :history, params:{biomedical_concept_instance: {identifier: instance.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(BiomedicalConceptInstance).to receive(:latest).and_return(BiomedicalConceptInstance.new)
      get :history, params:{biomedical_concept_instance: {identifier: "HEIGHT", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("HEIGHT")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end
    
  end

end