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
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
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

    it "history, JSON" do
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(SdtmSponsorDomain).to receive(:history_pagination).with({identifier: sdtm_sponsor_domain.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "0", count: "20"}).and_return([sdtm_sponsor_domain])
      get :history, params:{sdtm_sponsor_domain: {identifier: sdtm_sponsor_domain.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history, HTML" do
      params = {}
      expect(SdtmSponsorDomain).to receive(:latest).and_return(SdtmSponsorDomain.new)
      get :history, params:{sdtm_sponsor_domain: {identifier: "AAA", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("AAA")
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
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
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

    it "show data" do
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show_data, params:{id: sdtm_sponsor_domain.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "create actions" do

    login_curator

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

   it "creates from IG" do
      sdtm_ig_domain = SdtmIgDomain.find(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      post :create_from, params:{sdtm_sponsor_domain: {identifier: "NEW1", label: "Something", prefix: sdtm_ig_domain.prefix, based_on_id: sdtm_ig_domain.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "create_from_ig_expected_1.yaml", equate_method: :hash_equal)
    end

    it "creates from IG, error" do
      sdtm_ig_domain = SdtmIgDomain.find(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      post :create_from, params:{sdtm_sponsor_domain: {identifier: "HEIGHT", label: "something", prefix: sdtm_ig_domain.prefix, based_on_id: sdtm_ig_domain.id}}
      post :create_from, params:{sdtm_sponsor_domain: {identifier: "HEIGHT", label: "something", prefix: sdtm_ig_domain.prefix, based_on_id: sdtm_ig_domain.id}}
      actual = check_error_json_response(response)
      expect(actual[:errors]).to eq(["http://www.s-cubed.dk/HEIGHT/V1#SPD already exists in the database"])
    end

    it "creates from class" do
      sdtm_class = SdtmClass.find(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_EVENTS/V1#CL"))
      post :create_from, params:{sdtm_sponsor_domain: {identifier: "HEIGHT", label: "something", prefix: "DS", based_on_id: sdtm_class.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "create_from_class_expected_1.yaml", equate_method: :hash_equal)
    end

    it "add non standard variable" do
      @request.env['HTTP_REFERER'] = '/path'
      sdtm_sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(sdtm_sponsor_domain, @user)
      post :add_non_standard_variable, params:{id: sdtm_sponsor_domain.id, sdtm_sponsor_domain: {name: "AENEWVAR"}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_non_standard_variable_expected_1.yaml", equate_method: :hash_equal)
    end

    it "add non standard variable, not locked" do
      @request.env['HTTP_REFERER'] = '/path'
      sdtm_sponsor_domain = SdtmSponsorDomain.find(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      post :add_non_standard_variable, params:{id: sdtm_sponsor_domain.id}
      expect(response).to redirect_to("/path")
    end

  end

  describe "edit actions" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "edit, html request" do
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      get :edit, params:{id: instance.id}
      expect(assigns(:sdtm_sponsor_domain).uri).to eq(instance.uri)
      expect(assigns(:close_path)).to eq("/sdtm_sponsor_domains/history?sdtm_sponsor_domain%5Bidentifier%5D=AAA&sdtm_sponsor_domain%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("edit")
    end

    it "edit, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(instance, @user)
      get :edit, params:{id: instance.id}
      actual = check_good_json_response(response)
      expect(assigns[:lock].token.id).to eq(Token.all.last.id)  # Will change each test run
      actual[:token_id] = 9999                                  # So, fix for file compare
      check_file_actual_expected(actual, sub_dir, "edit_json_expected_1.yaml", equate_method: :hash_equal)
    end

    # it "edit, json request, already locked" do
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
    #   token = Token.obtain(instance, @user)
    #   get :edit, params:{id: instance.id}
    #   actual = check_good_json_response(response)
    #   expect(assigns[:lock].token.id).to eq(Token.all.last.id)  # Will change each test run
    #   actual[:token_id] = 9999                                  # So, fix for file compare
    #   check_file_actual_expected(actual, sub_dir, "edit_json_expected_1.yaml", equate_method: :hash_equal) # Note same result as above
    # end

    it "edit, html request, standard and creates new draft" do
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      instance.has_state.registration_status = "Standard"
      instance.has_state.save
      get :edit, params:{id: instance.id}
      expect(assigns[:sdtm_sponsor_domain].uri).to eq(Uri.new(uri: "http://www.s-cubed.dk/AAA/V2#SPD"))
      expect(assigns[:edit].lock.token.id).to eq(Token.all.last.id)
    end

    it "edit, json, locked by another user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(instance, @lock_user)
      get :edit, params:{id: instance.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "edit_json_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "editor metadata" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
    end

    it "editor metadata" do
      get :editor_metadata
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "editor_metadata_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "update variable action" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      @instance = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "update" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sponsor_domain = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      put :update, params:{id: @instance.id, sdtm_sponsor_domain: {label: "Label updated"}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update variable, error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {label: "ABC", non_standard_var_id: sponsor_variable.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update variable" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {used: false, non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_2.yaml", equate_method: :hash_equal)
    end

    it "update non-standard variable, bug" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      
      sdtm_sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      post :add_non_standard_variable, params: {id: sdtm_sponsor_domain.id}
    
      # Update non standard var field other than 'name' 
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {label: "ABC", non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_3.yaml", equate_method: :hash_equal)

      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {typed_as: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvQ1NOIzE3OGY4ZGJlLWMzYmEtNGRjMC04YTJhLTE4MDgxNjQ0YjRjNg==", non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_4.yaml", equate_method: :hash_equal)

      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {format: "123", non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_5.yaml", equate_method: :hash_equal)

      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {name: "AEXXX123", non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_6.yaml", equate_method: :hash_equal)
    end

    it "update non-standard variable, role bug, do not run with other tests just on its own" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sdtm_sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      post :add_non_standard_variable, params: {id: sdtm_sponsor_domain.id}
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {classified_as: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvQ1NOIzgxOGE5NzU3LTFlZTUtNGJkMy1hMTc5LWU2NjJlMjZiNWI0Nw==", non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_7.yaml", equate_method: :hash_equal) 
    end

    it "update non-standard variable, ct reference" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sdtm_sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      post :add_non_standard_variable, params: {id: sdtm_sponsor_domain.id}
      cl_1 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66767/V4#C66767"))
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.assero.co.uk/SDV#1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {label: "ABC", ct_reference: [cl_1.id], non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_8a.yaml", equate_method: :hash_equal) 
      cl_2 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66768/V4#C66768"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {ct_reference: [cl_2.id], non_standard_var_id: sponsor_variable.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_variable_expected_8b.yaml", equate_method: :hash_equal)
    end

  end

  describe "delete variable action" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      @instance = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "delete variable" do
      request.env['HTTP_ACCEPT'] = "application/json"
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(sponsor_domain, @user)
      uri = Uri.new(uri: "http://www.assero.co.uk/eee#aaa")
      sponsor_variable = SdtmSponsorDomain::VariableSSD.new(uri: uri, name: "AENEWAAA")
      expect(SdtmSponsorDomain::VariableSSD).to receive(:find_full).and_return(sponsor_variable)
      delete :delete_non_standard_variable, params:{id: sponsor_domain.id, sdtm_sponsor_domain: {non_standard_var_id: sponsor_variable}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "delete_variable_expected_1.yaml", equate_method: :hash_equal)
    end

    it "delete variable, error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      sponsor_variable = SdtmSponsorDomain::VariableSSD.find_full(Uri.new(uri:"http://www.s-cubed.dk/AAA/V1#SPD_STUDYID"))
      put :update_variable, params:{id: @instance.id, sdtm_sponsor_domain: {non_standard_var_id: sponsor_variable.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "delete_variable_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "delete action" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      @instance = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "delete domain" do
      sponsor_domain = SdtmSponsorDomain.find_full(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      delete :destroy, params:{id: sponsor_domain.id}
      actual = check_good_json_response(response)
    end

  end

  describe "bc associations actions" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl", "association.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "bc associations, html request" do
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      get :bc_associations, params:{id: instance.id}
      expect(assigns(:sdtm_sponsor_domain).uri).to eq(instance.uri)
      expect(assigns(:close_path)).to eq("/sdtm_sponsor_domains/history?sdtm_sponsor_domain%5Bidentifier%5D=AAA&sdtm_sponsor_domain%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("bc_associations")
    end

    it "bc associations, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(instance, @user)
      get :bc_associations, params:{id: instance.id}
      actual = check_good_json_response(response)
      expect(assigns[:lock].token.id).to eq(Token.all.last.id)  # Will change each test run
      actual[:token_id] = 9999                                  # So, fix for file compare
      check_file_actual_expected(actual, sub_dir, "bc_associations_json_expected_1.yaml", equate_method: :hash_equal)
    end

    it "bc associations, json, locked by another user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      token = Token.obtain(instance, @lock_user)
      get :bc_associations, params:{id: instance.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "bc_associations_json_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "add bcs actions" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "add bcs, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      token = Token.obtain(domain, @user)
      post :add_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_1.id]}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_bcs_json_expected_1a.yaml", equate_method: :hash_equal)
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bc_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      post :add_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_2.id, bc_3.id]}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_bcs_json_expected_1b.yaml", equate_method: :hash_equal)
    end

  end

  describe "remove bcs actions" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "remove bcs, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bc_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      token = Token.obtain(domain, @user)
      post :add_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_1.id, bc_2.id, bc_3.id]}}
      check_good_json_response(response)
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      expect(domain.associated.count).to eq(3)
      put :remove_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_2.id]}}
      check_good_json_response(response)
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      expect(domain.associated.count).to eq(2)
      put :remove_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_1.id, bc_3.id]}}
      check_good_json_response(response)
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      expect(domain.associated.count).to eq(0)
    end

  end

  describe "remove all bcs actions" do

    login_curator

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "remove all bcs, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      token = Token.obtain(domain, @user)
      post :add_bcs, params:{id: domain.id, sdtm_sponsor_domain: {bc_id_set: [bc_1.id, bc_2.id]}}
      domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      expect(domain.association?).to eq(true)
      check_good_json_response(response)
      put :remove_all_bcs, params:{id: domain.id}
      check_good_json_response(response)
      expect(domain.association?).to eq(false)
    end

  end

end