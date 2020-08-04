require 'rails_helper'

describe SdtmIgDomainsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "sdtm/SDTM_IG_3-2.ttl.ttl"]
      load_files(schema_files, data_files)
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    # it "show" do
    #   sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#IG-CDISC_SDTMIGRS"))
    #   get :show, params: { :id => sdtm_ig_domain.id}
    #   expect(response).to render_template("show")
    # end

    # it "show results" do
    #   sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#IG-CDISC_SDTMIGRS"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :show_data, params:{id: sdtm_ig_domain.id}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "shows the history, page" do
    #   sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#IG-CDISC_SDTMIGRS"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   expect(SdtmIgDomain).to receive(:history_pagination).with({identifier: sdtm_ig_domain.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([sdtm_ig_domain])
    #   get :history, params:{sdtm_ig: {identifier: sdtm_ig.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "shows the history, initial view" do
    #   params = {}
    #   expect(SdtmIgDomain).to receive(:latest).and_return(SdtmIgDomain.new)
    #   get :history, params:{sdtm_ig_domain: {identifier: "SDTM IG RS", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
    #   expect(assigns(:identifier)).to eq("SDTM IG RS")
    #   expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
    #   expect(response).to render_template("history")
    # end

    it "presents a domain" do
      params = 
      { 
        :id => "IG-CDISC_SDTMIGRS", 
        sdtm_ig_domain: 
        {
          :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3" 
        }
      }
      get :show, params:params
      expect(response).to render_template("show")
    end

    it "allows for a SDTM Model to be exported as JSON" do
      get :export_json, params:{ :id => "IG-CDISC_SDTMIGRS", sdtm_ig_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3" }}
    end

    it "allows for a SDTM Model to be exported as TTL" do
      get :export_ttl, params:{ :id => "IG-CDISC_SDTMIGRS", sdtm_ig_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3" }}
    end

  end

end