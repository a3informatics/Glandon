require 'rails_helper'

describe SdtmIgsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "sdtm/SDTM_IG_3-2.ttl"]
      load_files(schema_files, data_files)
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    # it "show" do
    #   sdtm_ig = SdtmIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG"))
    #   get :show, params: { :id => sdtm_ig.id}
    #   expect(response).to render_template("show")
    # end

    # it "show results" do
    #   sdtm_ig = SdtmIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :show_data, params:{id: sdtm_ig.id}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "shows the history, page" do
    #   sdtm_ig = SdtmIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   expect(SdtmIg).to receive(:history_pagination).with({identifier: sdtm_ig.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([sdtm_ig])
    #   get :history, params:{sdtm_ig: {identifier: sdtm_ig.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "shows the history, initial view" do
    #   params = {}
    #   expect(SdtmIg).to receive(:latest).and_return(SdtmIg.new)
    #   get :history, params:{sdtm_ig: {identifier: "SDTM IG", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
    #   expect(assigns(:identifier)).to eq("SDTM IG")
    #   expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
    #   expect(response).to render_template("history")
    # end

    # it "allows for a SDTM Model to be exported as JSON" do
    #   get :export_json, params:{ :id => "IG-CDISC_SDTMIG", sdtm_ig: { :namespace => "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3" }}
    # end

    # it "allows for a SDTM Model to be exported as TTL" do
    #   get :export_ttl, params:{ :id => "IG-CDISC_SDTMIG", sdtm_ig: { :namespace => "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3" }}
    # end

    # it "prevents access to the import view"  do
    #   get :import
    #   expect(response).to redirect_to("/")
    # end

    # it "prevents access to creation of a SDTM Model" do
    #   post :create, {} # id needs to be there but doesn't do anything
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
    #   post :create, {} # id needs to be there but doesn't do anything
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

    # it "allows a SDTM IG to be created" do
    #   filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
    #   post :create, params:{:sdtm_ig => { 
    #       :version => "4",
    #       :version_label => "2.0",
    #       :date => "2017-10-14", 
    #       :files => ["#{filename}"],
    #       :model_uri => "http://www.model.com/sdtm"}}
    #   expect(response).to redirect_to("/backgrounds")
    # end
    
    # it "allows a SDTM Model to be created, error version" do
    #   filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
    #   post :create,       params:{
    #     :sdtm_ig => 
    #     { 
    #       :version => "aa", 
    #       :version_label => "2.0",
    #       :date => "2016-12-13", 
    #       :files => ["#{filename}"],
    #       :model_uri => "http://www.model.com/sdtm"
    #     }
    #   }
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/sdtm_igs/history")
    # end

  end

end