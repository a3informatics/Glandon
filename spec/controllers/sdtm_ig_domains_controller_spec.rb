require 'rails_helper'

describe SdtmIgDomainsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/sdtm_ig_domains"
  end
  
  describe "Reader User" do
  	
    login_reader

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_CM/V1#IGD"))
      get :show, params: { :id => sdtm_ig_domain.id}
      expect(response).to render_template("show")
    end

    it "shows the history, page" do
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_CM/V1#IGD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(SdtmIgDomain).to receive(:history_pagination).with({identifier: sdtm_ig_domain.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([sdtm_ig_domain])
      get :history, params:{sdtm_ig_domain: {identifier: sdtm_ig_domain.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(SdtmIgDomain).to receive(:latest).and_return(SdtmIgDomain.new)
      get :history, params:{sdtm_ig_domain: {identifier: "CM", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("CM")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

  end

  describe "data actions" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..13)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "show data I" do
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_CM/V1#IGD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: sdtm_ig_domain.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show data II" do
      request.env['HTTP_ACCEPT'] = "application/json"
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      get :show_data, params:{id: sdtm_ig_domain.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end