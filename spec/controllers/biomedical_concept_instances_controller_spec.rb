require 'rails_helper'

describe BiomedicalConceptInstancesController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  include UserAccountHelpers
  include AuditTrailHelpers

  def sub_dir
    return "controllers/biomedical_concept_instances"
  end

  describe "simple actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "index" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :show, params: { :id => bci.id}
      expect(response).to render_template("show")
    end

    it "history, html" do
      expect(BiomedicalConceptInstance).to receive(:latest).and_return(BiomedicalConceptInstance.new)
      get :history, params:{biomedical_concept_instance: {identifier: "HEIGHT", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("HEIGHT")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

    it "history II, html" do
      @request.env['HTTP_REFERER'] = '/path'
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      expect(BiomedicalConceptInstance).to receive(:latest).with({identifier: instance.has_identifier.identifier, scope: an_instance_of(IsoNamespace)}).and_return(nil)
      get :history, params:{biomedical_concept_instance: {identifier: instance.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response).to redirect_to("/biomedical_concept_instances")
    end

    it "history, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      expect(BiomedicalConceptInstance).to receive(:history_pagination).with({identifier: instance.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([instance])
      get :history, params:{biomedical_concept_instance: {identifier: instance.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
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
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "show data" do
      request.env['HTTP_ACCEPT'] = "application/json"
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :show_data, params:{id: bci.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_1.yaml", equate_method: :hash_equal)
    end

    it "edit data" do
      request.env['HTTP_ACCEPT'] = "application/json"
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      token = Token.obtain(bci, @user)
      get :edit_data, params:{id: bci.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "edit_data_expected_1.yaml", equate_method: :hash_equal)
    end

    it "edit data, lock timeout" do
      # Don't gt a lock, looks like it has timedout
      request.env['HTTP_ACCEPT'] = "application/json"
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :edit_data, params:{id: bci.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_2.yaml", equate_method: :hash_equal)
    end

    it "edit data, locked by another user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      token = Token.obtain(bci, @lock_user)
      get :edit_data, params:{id: bci.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "create actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "creates from a template" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      post :create_from_template, params:{biomedical_concept_instance: {identifier: "NEW1", label: "something", template_id: template.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "create_from_template_expected_1.yaml", equate_method: :hash_equal)
    end

    it "creates from a template, error" do
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      post :create_from_template, params:{biomedical_concept_instance: {identifier: "HEIGHT", label: "something", template_id: template.id}}
      actual = check_error_json_response(response)
      expect(actual[:errors]).to eq(["http://www.s-cubed.dk/HEIGHT/V1#BCI already exists in the database"])
    end

  end

  describe "edit actions" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "edit, html request" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :edit, params:{id: instance.id}
      expect(assigns(:bc).uri).to eq(instance.uri)
      #expect(assigns(:data_path)).to eq("/biomedical_concept_instances/aHR0cDovL3d3dy5zLWN1YmVkLmRrL0hFSUdIVC9WMSNCQ0k=/show_data")
      expect(assigns(:close_path)).to eq("/biomedical_concept_instances/history?biomedical_concept_instance%5Bidentifier%5D=HEIGHT&biomedical_concept_instance%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("edit")
    end

    it "edit, html, locked by another user" do
      request.env["HTTP_REFERER"] = "/path"
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      token = Token.obtain(instance, @lock_user)
      get :edit, params:{id: instance.id}
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com./)
      expect(response).to redirect_to("/path")
    end

    it "edit, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      get :edit, params:{id: instance.id}
      actual = check_good_json_response(response)
      expect(actual[:token_id]).to eq(Token.all.last.id)  # Will change each test run
      actual[:token_id] = 9999                            # So, fix for file compare
      check_file_actual_expected(actual, sub_dir, "edit_json_expected_1.yaml", equate_method: :hash_equal)
    end

    it "edit, html, locked by another user" do
      request.env['HTTP_ACCEPT'] = "application/json"
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      token = Token.obtain(instance, @lock_user)
      get :edit, params:{id: instance.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "edit_json_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "delete actions" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it 'delete' do
      @request.env['HTTP_REFERER'] = '/path'
      bci = BiomedicalConceptInstance.create({:identifier => "NEW BC", :label => "New BC" })
      audit_count = AuditTrail.count
      delete :destroy, params:{id: bci.id}
      expect(AuditTrail.count).to eq(audit_count+1)
      check_file_actual_expected(last_audit_event, sub_dir, "destroy_expected_1.yaml", equate_method: :hash_equal)
      #expect(response).to redirect_to("/path")
      check_good_json_response(response)
    end

    it 'delete, locked by another user' do
      @request.env['HTTP_REFERER'] = '/path'
      bci = BiomedicalConceptInstance.create({:identifier => "NEW BC", :label => "New BC" })
      token = Token.obtain(bci, @lock_user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: bci.id}
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com./)
      #expect(response).to redirect_to("/path")
    end

  end

  describe "update property actions" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62) # A bit naughty but quicker. Some references will be unresolved.
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      uri = Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI_BCI1_BCCDTCD_BCPcode")
      @property = BiomedicalConcept::PropertyX.find(uri)
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it 'update property' do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      audit_count = AuditTrail.count
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {question_text: "something", property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_property_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update property, second update so no audit' do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      audit_count = AuditTrail.count
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {question_text: "something", property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {question_text: "something else", property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_property_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update property, locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @lock_user)
      audit_count = AuditTrail.count
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {question_text: "something", property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_property_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update property, errors' do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      audit_count = AuditTrail.count
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {question_text: "something±±±", property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_property_expected_4.yaml", equate_method: :hash_equal)
    end

    it 'update property, coded' do
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@instance, @user)
      audit_count = AuditTrail.count
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
      cli = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41259"))
      post :update_property, params:{id: @instance.id, biomedical_concept_instance: {has_coded_value: [{id: cli.id, context_id: cl.id}], property_id: @property.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_property_expected_5.yaml", equate_method: :hash_equal)
    end

  end

  describe "Reader User Access" do

    login_reader

    before :all do
      load_files(schema_files, [])
    end

    it "prevents access to a reader, edit" do
      get :edit, params:{id: 1} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      delete :destroy, params:{id: 10} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, update property" do
      post :update_property, params:{id: 10} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

  end

  describe "Unauthorised User" do

    before :all do
      load_files(schema_files, [])
    end

    it "prevents access, edit" do
      get :edit, params:{id: 1} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents access, destroy" do
      delete :destroy, params:{id: 10} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/users/sign_in")
    end

    it "prevents access, update property" do
      post :update_property, params:{id: 10} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
