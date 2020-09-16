require 'rails_helper'
require 'tabulation'

describe SdtmClassesController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/sdtm_classes"
    end

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      sdtm_class = SdtmClass.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_SE/V1#CL"))
      get :show, params: { :id => sdtm_class.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      sdtm_class = SdtmClass.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_SE/V1#CL"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: sdtm_class.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      sdtm_class = SdtmClass.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_SE/V1#CL"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(SdtmClass).to receive(:history_pagination).with({identifier: sdtm_class.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([sdtm_class])
      get :history, params:{sdtm_class: {identifier: sdtm_class.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(SdtmClass).to receive(:latest).and_return(SdtmClass.new)
      get :history, params:{sdtm_class: {identifier: "SDTM MODEL SE", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("SDTM MODEL SE")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

    # it "presents the domain" do
    #   params = 
    #   { 
    #     :id => "M-CDISC_SDTMMODELTRIALDESIGN", 
    #     sdtm_model_domain: 
    #     {
    #       :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3" 
    #     }
    #   }
    #   get :show, params:params
    #   expect(response).to render_template("show")
    # end

    # it "allows for a SDTM Model Domain to be exported as JSON" do
    #   get :export_json, params:{ :id => "M-CDISC_SDTMMODEL_TRIAL_DESIGN", sdtm_model_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3" }}
    # end

    # it "allows for a SDTM Model Domain to be exported as TTL" do
    #   get :export_ttl, params:{ :id => "M-CDISC_SDTMMODEL_TRIAL_DESIGN", sdtm_model_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3" }}
    # end

  end

end