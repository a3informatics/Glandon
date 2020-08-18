require 'rails_helper'

describe AdamIgsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/adam_igs"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ADAM_IG_1-0-0 Draft.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      adam_ig = AdamIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
      get :show, params: { :id => adam_ig.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      adam_ig = AdamIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: adam_ig.id, adam_ig:{count: 10, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      adam_ig = AdamIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(AdamIg).to receive(:history_pagination).with({identifier: adam_ig.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([adam_ig])
      get :history, params:{adam_ig: {identifier: adam_ig.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(AdamIg).to receive(:latest).and_return(AdamIg.new)
      get :history, params:{adam_ig: {identifier: "ADAM IG", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("ADAM IG")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end