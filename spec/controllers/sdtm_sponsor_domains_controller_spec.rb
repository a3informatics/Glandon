require 'rails_helper'

describe SdtmSponsorDomainsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/sdtm_sponsor_domains"
    end

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
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
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      get :show, params: { :id => sdtm_sponsor_domain.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: sdtm_sponsor_domain.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "show_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(SdtmSponsorDomain).to receive(:history_pagination).with({identifier: sdtm_sponsor_domain.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([sdtm_sponsor_domain])
      get :history, params:{sdtm_sponsor_domain: {identifier: sdtm_sponsor_domain.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(SdtmSponsorDomain).to receive(:latest).and_return(SdtmSponsorDomain.new)
      get :history, params:{sdtm_sponsor_domain: {identifier: "AAA", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("AAA")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

end