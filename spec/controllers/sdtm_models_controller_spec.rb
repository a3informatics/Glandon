require 'rails_helper'
require 'tabulation'

describe SdtmModelsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/sdtm_models"
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
      sdtm_model = SdtmModel.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_INTERVENTIONS/V1#CL"))
      get :show, params: { :id => sdtm_model.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      sdtm_model = SdtmModel.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_INTERVENTIONS/V1#CL"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: sdtm_model.id, sdtm_model:{count: 10, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      sdtm_model = SdtmModel.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_INTERVENTIONS/V1#CL"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(SdtmModel).to receive(:history_pagination).with({identifier: sdtm_model.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([sdtm_model])
      get :history, params:{sdtm_model: {identifier: sdtm_model.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQ0RJU0M=", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(SdtmModel).to receive(:latest).and_return(SdtmModel.new)
      get :history, params:{sdtm_model: {identifier: "SDTM MODEL", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQ0RJU0M="}}
      expect(assigns(:identifier)).to eq("SDTM MODEL")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQ0RJU0M=")
      expect(response).to render_template("history")
    end

    # it "allows for a SDTM Model to be exported as JSON" do
    #   get :export_json, params:{ :id => "M-CDISC_SDTMMODEL", :sdtm_model => { :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
    # end

    # it "allows for a SDTM Model to be expoerted as TTL" do
    #   get :export_ttl, params:{ :id => "M-CDISC_SDTMMODEL", :sdtm_model => { :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
    # end

    # it "prevents access to the import view"  do
    #   get :import
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to creation of a SDTM Model" do
    #   post :create, params:{} # id needs to be there but doesn't do anything
    #   expect(response).to redirect_to("/")
    # end

  end

  describe "Curator User" do
    
    login_curator

    # it "prevents access to the import view"  do
    #   get :import
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to creation of a SDTM Model" do
    #   post :create, params:{} # id needs to be there but doesn't do anything
    #   expect(response).to redirect_to("/")
    # end
    
  end

  describe "Content Admin User" do
    
    login_content_admin

    # it "presents the import view"  do
    #   get :import
    #   expect(assigns(:next_version)).to eq(4)
    #   expect(response).to render_template("import")
    # end

    # it "allows a SDTM Model to be created" do
    #   filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
    #   post :create, params:{:sdtm_model => { :version => "4",:version_label => "2.0",:date => "2017-10-14", :files => ["#{filename}"]}}
    #   expect(response).to redirect_to("/backgrounds")
    # end
    
    # it "allows a SDTm Model to be created, error version" do
    #   filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
    #   post :create, params:{:sdtm_model => { :version => "aa", :version_label => "2.0",:date => "2016-12-13", :files => ["#{filename}"]}}
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/sdtm_models/history")
    # end

  end

end