require 'rails_helper'

describe IsoManagedV2Controller do

  include DataHelpers
  include PublicFileHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include ControllerHelpers

  describe "Curator User" do

    login_curator

    def sub_dir
      return "controllers/iso_managed_v2"
    end

    def current_status
      current_uri = CdiscTerm.current_uri(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      puts colourize("Current: #{current_uri}\n+++++", "blue")
    end

    before :all do
      x = Thesaurus.new
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "status" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      managed_item = CdiscTerm.find_minimum(uri.to_id)
      get :status, params:{id: uri.to_id, iso_managed: { current_id: "test" }}
      expect(assigns(:managed_item).to_h).to eq(managed_item.to_h)
      expect(assigns(:current_id)).to eq("test")
      expect(assigns(:close_path)).to eq("/thesauri/history/?thesauri[identifier]=#{managed_item.scoped_identifier}&thesauri[scope_id]=#{managed_item.scope.id}")
      expect(response).to render_template("status")
    end

    it "status, locked" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      managed_item = CdiscTerm.find_minimum(uri.to_id)
      token = Token.obtain(managed_item, @lock_user)
      get :status, params:{id: uri.to_id, iso_managed: { current_id: "test" }}
      expect(assigns(:managed_item).to_h).to eq(managed_item.to_h)
      expect(response).to redirect_to("/xxx")
    end

    it "make current" do
      current_status
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      get :make_current, params:{id: uri_1.to_id}
      current_status
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)
      expect(mi_1.current?).to eq(true)
      expect(mi_2.current?).to eq(false)
      get :make_current, params:{id: uri_2.to_id}
      current_status
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)
      expect(mi_1.current?).to eq(false)
      expect(mi_2.current?).to eq(true)
    end

    it 'updates the status' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      audit_count = AuditTrail.count
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C49499/V1#C49499")
      mi = IsoManagedV2.find_minimum(uri_1)
      token = Token.obtain(mi, @user)
      post :update_status, params:{ id: mi.id, iso_managed: { registration_status: "Retired", previous_state: "Standard",
        administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(uri_1)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_1.yaml", equate_method: :hash_equal)
      expect(response).to redirect_to("/registration_states")
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it 'updates the status, locked by another user' do
      audit_count = AuditTrail.count
      expect(TypePathManagement).to receive(:history_url_v2).and_return("/history")
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C49499/V1#C49499")
      mi = IsoManagedV2.find_minimum(uri_1)
      token = Token.obtain(mi, @lock_user)
      post :update_status, params:{ id: mi.id, iso_managed: { registration_status: "Retired", previous_state: "Standard",
        administrative_note: "X1", unresolved_issue: "X2" }}
      expect(response).to redirect_to("/history")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it 'prevents updates with invalid data (the state)' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      token = Token.obtain(mi, @user)
      post :update_status, params:{ id: mi.id, iso_managed: { registration_status: "X", previous_state: "Standard",
        administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(uri_1)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_2.yaml", equate_method: :hash_equal)
      expect(response).to redirect_to("/registration_states")
    end

    it 'updates the semantic version' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V10#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      mi.has_state.registration_status = "Qualified"
      mi.has_state.save
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it 'updates the semantic version, locked' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V10#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      mi.has_state.registration_status = "Qualified"
      mi.has_state.save
      token = Token.obtain(mi, @lock_user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual).to eq(["The edit lock has timed out."])
    end

    it 'updates the semantic version, error, has to be latest' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      mi.has_state.registration_status = "Qualified"
      mi.has_state.save
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["Can only modify the latest release"])
    end

    it 'updates the semantic version, error, release cannot be updated in the current state' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The release cannot be updated in the current state"])
    end

    it 'lists change notes data' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V10#TH")
      mi = Thesaurus::ManagedConcept.find_minimum(uri_1)
      get :list_change_notes_data, params:{ id: mi.id, iso_managed: { offset: "0", count: "200" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it 'change notes export csv' do
      expect(controller).to receive(:protect_from_bad_id).and_return("anything")
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).with("anything").and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identifier).and_return("C12345")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:change_notes_csv).and_return(["XXX", "YYY"])
      expect(@controller).to receive(:send_data).with(["XXX", "YYY"], {filename: "CL_CHANGE_NOTES_C12345.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'})
      get :export_change_notes_csv, params:{id: "aaa"}, format: 'text/csv'
    end

  end

  describe "Exports" do

    login_content_admin

    def sub_dir
      return "controllers"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it 'ttl' do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      get :export_ttl, params:{id: uri.to_id}
      expect(response.content_type).to eq("application/x-turtle")
      expect(response.code).to eq("200")
    end

    it 'json' do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      get :export_json, params:{id: uri.to_id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

  end

  describe "Custom Properties" do

    login_content_admin

    def sub_dir
      return "controllers"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_cdisc_term_versions(1..45)
    end

    it 'custom properties' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri = Uri.new(uri: "http://www.sanofi.com/C67154/V1#C67154")
      get :custom_properties, params:{id: uri.to_id}
      data = check_good_json_response(response)
      check_file_actual_expected(data, sub_dir, "custom_properties_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Unauthorized User" do

    it "status" do
      get :status, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "make current" do
      get :make_current, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "update_status" do
      post :update_status, params:{ id: "F-ACME_TEST"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "update_semantic_version" do
      put :update_semantic_version, params:{ id: "F-ACME_TEST"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "export ttl" do
      get :export_ttl, params:{ id: "F-ACME_TEST"}
      expect(response).to redirect_to("/users/sign_in")
    end
  end

end
