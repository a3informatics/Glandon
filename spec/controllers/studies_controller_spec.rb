require 'rails_helper'

describe StudiesController do

  include DataHelpers
  include UserAccountHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/studies"
  end

  describe "Authorized User" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl", "thesaurus_subsets_3.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_cdisc_term_versions(1..2)
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "index data" do
      expected = [{id: "a1", label: "aaa", identifier: "something", scope_id:"asd"}, {id: "a2", label: "bbb", identifier: "somethingelse", scope_id:"fgh"}]
      expect(Study).to receive(:unique).and_return(expected)
      get :index_data
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:history_url]
      check_file_actual_expected(actual, sub_dir, "index_data_expected.yaml", equate_method: :hash_equal)
    end

    it 'creates study' do
      count = Study.all.count
      expect(count).to eq(0)
      post :create, study: { :identifier => "NEW TH", :label => "New Thesaurus" }
      expect(Study.all.count).to eq(count + 1)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:history_url]
      check_file_actual_expected(actual, sub_dir, "history_url_expected.yaml", equate_method: :hash_equal)
    end

    it 'creates study, fails bad identifier' do
      count = Study.all.count
      expect(count).to eq(0)
      post :create, study: { :identifier => "NEW_TH!@£$%^&*", :label => "New Thesaurus" }
      count = Study.all.count
      expect(count).to eq(0)
      expect(Study.all.count).to eq(count)
    end
    
  end

  describe "Authorized User" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_test_file_into_triple_store("transcelerate.nq.gz")
    end

    it "show" do
      pr = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      study = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: pr.uri)
      get :design, id: study.id
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "design_expected.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end
