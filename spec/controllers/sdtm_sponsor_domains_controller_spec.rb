require 'rails_helper'

describe SdtmSponsorDomainsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers

  def sub_dir
      return "controllers/sdtm_sponsor_domains"
  end
  
  describe "Simple actions" do
  	
    login_curator

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

  describe "create actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
    end

    it "creates from IG" do
      sdtm_ig_domain = SdtmIgDomain.find(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      post :create_from_ig, params:{sdtm_sponsor_domain: {identifier: "NEW1", label: "Something", prefix: sdtm_ig_domain.prefix, sdtm_ig_domain_id: sdtm_ig_domain.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "create_from_ig_expected_1.yaml", equate_method: :hash_equal)
    end

    it "creates from IG, error" do
      sdtm_ig_domain = SdtmIgDomain.find(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      post :create_from_ig, params:{sdtm_sponsor_domain: {identifier: "HEIGHT", label: "something", prefix: sdtm_ig_domain.prefix, sdtm_ig_domain_id: sdtm_ig_domain.id}}
      actual = check_error_json_response(response)
      expect(actual[:errors]).to eq(["http://www.s-cubed.dk/AE_Domain/V1#SPD already exists in the database"])
    end

  end

end