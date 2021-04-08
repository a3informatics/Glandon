require 'rails_helper'

describe IndicationsController do

  include DataHelpers
  include ControllerHelpers
  include IndicationFactory
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/indications"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      indication1 = create_indication("IND1", "Indication 1")
      indication2 = create_indication("IND2", "Indication 2")
      indication3 = create_indication("IND3", "Indication 3")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    # it "show" do
    #   indication = Indication.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/IND2/V1#IND"))
    #   get :show, params: { :id => indication.id}
    #   expect(response).to render_template("show")
    # end

    it "shows the history, page" do
      item = Indication.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/IND2/V1#IND"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Indication).to receive(:history_pagination).with({identifier: item.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([item])
      get :history, params:{indication: {identifier: item.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(Indication).to receive(:latest).and_return(Indication.new)
      get :history, params:{indication: {identifier: "INDICATION", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("INDICATION")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end