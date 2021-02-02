require 'rails_helper'

describe ManagedCollectionsController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  include UserAccountHelpers
  include AuditTrailHelpers
  include IsoManagedHelpers
  include ManagedCollectionFactory

  def sub_dir
    return "controllers/managed_collections"
  end

  describe "simple actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "index" do
      request.env['HTTP_ACCEPT'] = "application/json"
      expected = [{x: "a1", y: true, z: "something"}, {x: "a2", y: true, z: "something else"}]
      expect(ManagedCollection).to receive(:unique).and_return(expected)
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      mc = ManagedCollection.create({ :identifier => "NEW MC", :label => "New Collection 1" })
      expect(ManagedCollection).to receive(:find_minimum).and_return(mc)
      get :show, params:{id: mc.id}
      expect(response).to render_template("show")
    end

    it "history, html" do
      expect(ManagedCollection).to receive(:latest).and_return(ManagedCollection.new)
      get :history, params:{managed_collection: {identifier: "AAA", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("AAA")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

    it "history, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      collection = ManagedCollection.create({ :identifier => "NEW MC 2", :label => "New Collection 2" })
      expect(ManagedCollection).to receive(:history_pagination).with({identifier: collection.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([collection])
      get :history, params:{managed_collection: {identifier: collection.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "data actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "show data" do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = create_managed_collection("ITEM1", "Item 1")
      item_2 = create_managed_collection("ITEM2", "Item 2")
      item_3 = create_managed_collection("ITEM3", "Item 3")
      item_4 = create_managed_collection("ITEM4", "Item 4")
      mc.add_item([item_2.id, item_3.id, item_4.id])
      mc = ManagedCollection.find_full(mc.id)
      get :show_data, params:{id: mc.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_data_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  # describe "edit actions" do

  #   before :all do
  #     load_files(schema_files, [])
  #     load_data_file_into_triple_store("mdr_identification.ttl")
  #     @lock_user = ua_add_user(email: "lock@example.com")
  #     Token.delete_all
  #   end

  #   after :all do
  #     ua_remove_user("lock@example.com")
  #     Token.delete_all
  #   end

  #   it "edit, html request" do
  #     mc = create_managed_collection("ITEM1", "Item 1")
  #     #item_2 = create_managed_collection("ITEM2", "Item 2")
  #     #item_3 = create_managed_collection("ITEM3", "Item 3")
  #     #item_4 = create_managed_collection("ITEM4", "Item 4")
  #     #mc.add_item([item_2.id, item_3.id, item_4.id])
  #     #mc = ManagedCollection.find_minimum(mc.id)
  #     get :edit, params:{id: mc.id}
  #     expect(assigns(:mc).uri).to eq(mc.uri)
  #     expect(assigns(:close_path)).to eq("/managed_collections/history?managed_collection%5Bidentifier%5D=ITEM1&managed_collection%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
  #     expect(assigns(:edit_tags_path)).to eq("/iso_concept/aHR0cDovL3d3dy5zLWN1YmVkLmRrL0lURU0xL1YxI01D/edit_tags")
  #     expect(response).to render_template("edit")
  #   end

  #   # it "edit, html request, not locked, standard and creates new draft" do
  #   #   mc = set_mc_data
  #   #   mc.has_state.registration_status = "Standard"
  #   #   mc.has_state.save
  #   #   get :edit, params:{id: mc.id}
  #   #   expect(assigns[:mc].uri).to eq(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V2#MC"))
  #   #   expect(assigns[:edit].lock.token.id).to eq(Token.all.last.id)
  #   # end

  #   # it "edit, json request" do
  #   #   request.env['HTTP_ACCEPT'] = "application/json"
  #   #   mc = set_mc_data
  #   #   token = Token.obtain(mc, @user)
  #   #   get :edit, params:{id: mc.id}
  #   #   actual = check_good_json_response(response)
  #   #   expect(actual[:token_id]).to eq(Token.all.last.id)  # Will change each test run
  #   #   actual[:token_id] = 9999                            # So, fix for file compare
  #   #   check_file_actual_expected(actual, sub_dir, "edit_json_expected_1.yaml", equate_method: :hash_equal, write_file: true)
  #   # end

  # end

  describe "add actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "add, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = create_managed_collection("ITEM1", "Item 1")
      item_2 = create_managed_collection("ITEM2", "Item 2")
      item_3 = create_managed_collection("ITEM3", "Item 3")
      item_4 = create_managed_collection("ITEM4", "Item 4")
      token = Token.obtain(mc, @user)
      post :add, params:{id: mc.id, managed_collection: {id_set: [item_2.id, item_3.id, item_4.id]}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_expected_1a.yaml", equate_method: :hash_equal)
      item_5 = create_managed_collection("ITEM5", "Item 5")
      item_6 = create_managed_collection("ITEM6", "Item 6")
      mc = ManagedCollection.find_full(mc.id)
      expect(mc.has_managed.count).to eq(3)
      post :add, params:{id: mc.id, managed_collection: {id_set: [item_5.id, item_6.id]}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_expected_1b.yaml", equate_method: :hash_equal)
      mc = ManagedCollection.find_full(mc.id)
      expect(mc.has_managed.count).to eq(5)
    end

  end

  describe "remove actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
      Token.delete_all
    end

    it "remove, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = create_managed_collection("ITEM1", "Item 1")
      item_2 = create_managed_collection("ITEM2", "Item 2")
      item_3 = create_managed_collection("ITEM3", "Item 3")
      item_4 = create_managed_collection("ITEM4", "Item 4")
      token = Token.obtain(mc, @user)
      post :add, params:{id: mc.id, managed_collection: {id_set: [item_2.id, item_3.id, item_4.id]}}
      check_good_json_response(response)
      mc = ManagedCollection.find_full(mc.id)
      expect(mc.has_managed.count).to eq(3)
      put :remove, params:{id: mc.id, managed_collection: {id_set: [item_3.id]}}
      check_good_json_response(response)
      mc = ManagedCollection.find_full(mc.id)
      expect(mc.has_managed.count).to eq(2)
      put :remove, params:{id: mc.id, managed_collection: {id_set: [item_2.id, item_4.id]}}
      check_good_json_response(response)
      mc = ManagedCollection.find_full(mc.id)
      expect(mc.has_managed.count).to eq(0)
    end

  end


  describe "create actions" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it 'creates collection' do
      audit_count = AuditTrail.count
      count = ManagedCollection.all.count
      expect(count).to eq(0)
      post :create, params:{managed_collection: { :identifier => "NEW MC", :label => "New Collection" }}
      expect(ManagedCollection.all.count).to eq(count + 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end


  # describe "delete actions" do

  #   login_curator

  #   before :all do
  #     @lock_user = ua_add_user(email: "lock@example.com")
  #     Token.delete_all
  #   end

  #   before :each do
  #     load_files(schema_files, [])
  #     load_data_file_into_triple_store("mdr_identification.ttl")
  #   end

  #   after :all do
  #     ua_remove_user("lock@example.com")
  #   end

  #   it 'delete' do
  #     @request.env['HTTP_REFERER'] = '/path'
  #     bci = BiomedicalConceptInstance.create({:identifier => "NEW BC", :label => "New BC" })
  #     audit_count = AuditTrail.count
  #     delete :destroy, params:{id: bci.id}
  #     expect(AuditTrail.count).to eq(audit_count+1)
  #     check_file_actual_expected(last_audit_event, sub_dir, "destroy_expected_1.yaml", equate_method: :hash_equal)
  #     #expect(response).to redirect_to("/path")
  #     check_good_json_response(response)
  #   end

  #   it 'delete, locked by another user' do
  #     @request.env['HTTP_REFERER'] = '/path'
  #     bci = BiomedicalConceptInstance.create({:identifier => "NEW BC", :label => "New BC" })
  #     token = Token.obtain(bci, @lock_user)
  #     audit_count = AuditTrail.count
  #     delete :destroy, params:{id: bci.id}
  #     expect(flash[:error]).to be_present
  #     expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com./)
  #     #expect(response).to redirect_to("/path")
  #   end

  # end

end