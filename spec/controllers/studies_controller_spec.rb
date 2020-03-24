require 'rails_helper'

describe StudiesController do

  include DataHelpers
  include UserAccountHelpers

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
      expect(Study).to receive(:all).and_return(expected)
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
      expect(assigns(:study).errors.count).to eq(0)
      expect(Study.all.count).to eq(count + 1)
      expect(flash[:success]).to be_present
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
      expect(assigns(:study).errors.count).to eq(1)
      expect(Study.all.count).to eq(count)
      expect(flash[:error]).to be_present
    end
    
  end

end
