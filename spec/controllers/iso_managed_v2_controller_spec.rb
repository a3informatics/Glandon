require 'rails_helper'

describe IsoManagedV2Controller do

  include DataHelpers
  include PublicFileHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include ControllerHelpers
  include IsoManagedFactory
  include IsoManagedHelpers
  include ThesaurusManagedConceptFactory
  include NameValueHelpers
  
  def sub_dir
    return "controllers/iso_managed_v2"
  end

  describe "Curator User" do

    login_curator

    def current_status
      current_uri = CdiscTerm.current_uri(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      puts colourize("Current: #{current_uri}\n+++++", "blue")
    end

    before :all do
      x = Thesaurus.new
      @lock_user = ua_add_user(email: "lock@example.com")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      Token.delete_all
      nv_destroy
      nv_create(parent: '10', child: '999')
    end

    after :each do
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "status, html" do
      mi = create_iso_managed_thesaurus("TEST1A", "A test managed item")
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      get :status, params:{id: mi.uri.to_id, iso_managed: { current_id: "test" }}
      expect(assigns(:managed_item).to_h).to eq(mi.to_h)
      expect(assigns(:close_path)).to eq("/thesauri/history/?thesauri[identifier]=#{mi.scoped_identifier}&thesauri[scope_id]=#{mi.scope.id}")
      expect(response).to render_template("status")
    end

    it "status, json" do
      mi = create_iso_managed_thesaurus("TEST1B", "A test managed item")
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(mi, @user)
      get :status, params:{id: mi.uri.to_id, iso_managed: { current_id: "test" }}
      check_file_actual_expected(check_good_json_response(response), sub_dir, "status_expected_1.yaml", equate_method: :hash_equal)
    end

    it "status, html and locked" do
      mi = create_iso_managed_thesaurus("TEST2A", "A test managed item")
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      token = Token.obtain(mi, @lock_user)
      get :status, params:{id: mi.uri.to_id, iso_managed: { current_id: "test" }}
      expect(assigns(:managed_item).to_h).to eq(mi.to_h)
      expect(response).to redirect_to("/xxx")
    end

    it "status, json, lock missing" do
      mi = create_iso_managed_thesaurus("TEST2B", "A test managed item")
      request.env['HTTP_ACCEPT'] = "application/json"
      get :status, params:{id: mi.uri.to_id, iso_managed: { current_id: "test" }}
      check_file_actual_expected(check_error_json_response(response), sub_dir, "status_expected_2.yaml", equate_method: :hash_equal)
    end

    it "make current" do
      current_status
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      post :make_current, params:{id: uri_1.to_id}
      current_status
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)
      expect(mi_1.current?).to eq(true)
      expect(mi_2.current?).to eq(false)
      post :make_current, params:{id: uri_2.to_id}
      current_status
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)
      expect(mi_1.current?).to eq(false)
      expect(mi_2.current?).to eq(true)
    end

    it 'next state' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST3", "A test managed item")
      expect(AuditTrail).to receive(:update_item_event).with(@user, instance_of(Thesaurus), "Terminology owner: ACME, identifier: TEST3, state was updated from Incomplete to Candidate.")
      token = Token.obtain(mi, @user)
      post :next_state, params:{ id: mi.id, iso_managed: { administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(mi.uri)
      fix_dates(actual, sub_dir, "next_state_expected_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "next_state_expected_1a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(check_good_json_response(response), sub_dir, "next_state_expected_1b.yaml", equate_method: :hash_equal)
    end

      it 'next state, locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST4", "A test managed item")
      token = Token.obtain(mi, @lock_user)
      post :next_state, params:{ id: mi.id, iso_managed: { administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(mi.uri)
      fix_dates(actual, sub_dir, "next_state_expected_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "next_state_expected_2a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(check_error_json_response(response), sub_dir, "next_state_expected_2b.yaml", equate_method: :hash_equal)
    end

    it 'next state, prevents updates with invalid data' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST5", "A test managed item")
      token = Token.obtain(mi, @user)
      post :next_state, params:{ id: mi.id, iso_managed: { administrative_note: "X1", unresolved_issue: "§§§§§§X2" }}
      actual = IsoManagedV2.find_minimum(mi.uri)
      fix_dates(actual, sub_dir, "next_state_expected_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "next_state_expected_3a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(check_error_json_response(response), sub_dir, "next_state_expected_3b.yaml", equate_method: :hash_equal)
    end

    it 'next state, not permitted' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST5", "A test managed item")
      expect_any_instance_of(Thesaurus).to receive(:update_status_permitted?) do |arg|
        arg.errors.add(:base, "Some error")
        false
      end
      token = Token.obtain(mi, @user)
      post :next_state, params:{ id: mi.id, iso_managed: { administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(mi.uri)
      fix_dates(actual, sub_dir, "next_state_expected_4a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "next_state_expected_4a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(check_error_json_response(response), sub_dir, "next_state_expected_4b.yaml", equate_method: :hash_equal)
    end

    it 'updates the semantic version' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it 'updates the semantic version, locked' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @lock_user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual).to eq(["The edit lock has timed out."])
    end

    it 'updates the semantic version, error, has to be latest' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      new_item = IsoManagedHelpers.next_version(mi)
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["Can only modify the latest release"])
    end

    it 'updates the semantic version, error, release cannot be updated in the current state' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_standard(mi)
      token = Token.obtain(mi, @user)
      put :update_semantic_version , params:{ id: mi.id, iso_managed: { sv_type: "major" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The release cannot be updated in the current state"])
    end

    it 'updates the version label' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :update_version_label , params:{ id: mi.id, iso_managed: { version_label: "XXXXX" }}
      actual = check_good_json_response(response)
      expect(actual).to eq({data: "XXXXX", errors: []})
    end

    it 'updates the version label, error' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :update_version_label , params:{ id: mi.id, iso_managed: { version_label: "XXXXX§§§" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({:data=>"XXXXX§§§", :errors=>["Version label contains invalid characters"]})
    end

    it 'updates the version label, locked' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @lock_user)
      put :update_version_label , params:{ id: mi.id, iso_managed: { version_label: "DDDDDD" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["The edit lock has timed out."]})
    end

    it 'state change, fast forward' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change, params:{ id: mi.id, iso_managed: { action: "fast_forward", with_dependencies: "true" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_expected_1.yaml", equate_method: :hash_equal)
      expect(token.timed_out?).to be(false)
    end

    it 'state change, fast forward, multiple items' do
      request.env['HTTP_ACCEPT'] = "application/json"
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      extension = create_managed_concept("Extension")
      subset.add_link(:subsets, master.uri)
      extension.add_link(:extends, master.uri)
      token = Token.obtain(master, @user)
      put :state_change, params:{ id: master.id, iso_managed: { action: "fast_forward", with_dependencies: "true" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_expected_3.yaml", equate_method: :hash_equal)
      expect(IsoManagedV2.find_minimum(master.uri).registration_status).to eq("Standard")
      expect(IsoManagedV2.find_minimum(subset.uri).registration_status).to eq("Standard")
      expect(IsoManagedV2.find_minimum(extension.uri).registration_status).to eq("Standard")
      expect(token.timed_out?).to be(false)
    end

    it 'state change, fast forward, multiple, not allowed' do
      request.env['HTTP_ACCEPT'] = "application/json"
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      next_version = create_managed_concept("Next")
      next_version.add_link(:has_previous_version, subset.uri)
      subset.add_link(:subsets, master.uri)
      token = Token.obtain(master, @user)
      put :state_change, params:{ id: master.id, iso_managed: { action: "fast_forward", with_dependencies: "true" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["The state change is not permitted."]})
      expect(IsoManagedV2.find_minimum(master.uri).registration_status).to eq("Incomplete")
      expect(IsoManagedV2.find_minimum(subset.uri).registration_status).to eq("Incomplete")
    end

    it 'state change, fast forward, multiple, not allowed' do
      request.env['HTTP_ACCEPT'] = "application/json"
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      subset.add_link(:subsets, master.uri)
      IsoManagedHelpers.make_item_superseded(subset)
      token = Token.obtain(master, @user)
      put :state_change, params:{ id: master.id, iso_managed: { action: "fast_forward", with_dependencies: "true" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["The state change is not permitted."]})
      expect(IsoManagedV2.find_minimum(master.uri).registration_status).to eq("Incomplete")
      expect(IsoManagedV2.find_minimum(subset.uri).registration_status).to eq("Superseded")
    end

    it 'state change, fast forward, multiple, no dependencies' do
      request.env['HTTP_ACCEPT'] = "application/json"
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      extension = create_managed_concept("Extension")
      subset.add_link(:subsets, master.uri)
      extension.add_link(:extends, master.uri)
      token = Token.obtain(master, @user)
      put :state_change, params:{ id: master.id, iso_managed: { action: "fast_forward", with_dependencies: false }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_expected_4.yaml", equate_method: :hash_equal)
      expect(IsoManagedV2.find_minimum(master.uri).registration_status).to eq("Standard")
      expect(IsoManagedV2.find_minimum(subset.uri).registration_status).to eq("Incomplete")
      expect(IsoManagedV2.find_minimum(extension.uri).registration_status).to eq("Incomplete")
      expect(token.timed_out?).to be(false)
    end

    it 'state change, rewind' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change, params:{ id: mi.id, iso_managed: { action: "rewind", with_dependencies: "true" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_expected_2.yaml", equate_method: :hash_equal)
      expect(token.timed_out?).to be(false)
    end

    it 'state change, locked' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @lock_user)
      put :state_change, params:{ id: mi.id, iso_managed: { action: "fast_forward", with_dependencies: "true" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["The edit lock has timed out."]})
    end

    it 'state change, invalid action' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change_impacted_items , params:{ id: mi.id, iso_managed: { action: "DDDDDD" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["Invalid action detected."]})
    end

    it 'assess the impacted items, forward, empty' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change_impacted_items, params:{ id: mi.id, iso_managed: { action: "fast_forward" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_impacted_items_expected_1.yaml", equate_method: :hash_equal)
      expect(token.timed_out?).to be(false)
    end

    it 'assess the impacted items, rewind, empty' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change_impacted_items, params:{ id: mi.id, iso_managed: { action: "rewind" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_impacted_items_expected_2.yaml", equate_method: :hash_equal)
      expect(token.timed_out?).to be(false)
    end

    it 'assess the impacted items, forward, items' do
      request.env['HTTP_ACCEPT'] = "application/json"
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      extension = create_managed_concept("Extension")
      subset.add_link(:subsets, master.uri)
      extension.add_link(:extends, master.uri)
      token = Token.obtain(master, @user)
      put :state_change_impacted_items, params:{ id: master.id, iso_managed: { action: "fast_forward" }}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "state_change_impacted_items_expected_3.yaml", equate_method: :hash_equal)
      expect(token.timed_out?).to be(false)
    end

    it 'assess the impacted items, locked' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @lock_user)
      put :state_change_impacted_items, params:{ id: mi.id, iso_managed: { action: "fast_forward" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["The edit lock has timed out."]})
    end

    it 'assess the impacted items, invalid action' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_qualified(mi)
      token = Token.obtain(mi, @user)
      put :state_change_impacted_items , params:{ id: mi.id, iso_managed: { action: "DDDDDD" }}
      actual = check_error_json_response(response)
      expect(actual).to eq({errors: ["Invalid action detected."]})
    end

    it 'lists change notes data' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mi = create_iso_managed_thesaurus("TEST", "A test managed item")
      IsoManagedHelpers.make_item_standard(mi)
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

    it "impact" do
      im = IsoManagedV2.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(IsoManagedV2).to receive(:find_minimum).and_return(im)
      expect(im).to receive(:dependency_required_by).and_return([])
      request.env['HTTP_ACCEPT'] = "application/json"
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      get :impact, params: { id: uri.to_id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(actual, sub_dir, "impact_expected_1.yaml", equate_method: :hash_equal)
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

    it 'custom properties' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri = Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047")
      get :custom_properties, params:{id: uri.to_id}
      data = check_good_json_response(response)
      check_file_actual_expected(data, sub_dir, "custom_properties_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Unauthorized User" do

    it "status, html" do
      get :status, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "status, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :status, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      check_unauthorised_json_response(response)
    end
      
    it "make current" do
      post :make_current, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "next state, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :status, params:{ id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      check_unauthorised_json_response(response)
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
