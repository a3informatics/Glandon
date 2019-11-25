require 'rails_helper'

describe IsoConceptSystemsController do

  include DataHelpers
  
  describe "Authrorized Use, Empty" do
  	
    def sub_dir
      return "controllers"
    end

    login_curator

    before :all do
      clear_triple_store
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "returns a concept system tree, none exists" do
      get :index
      result = assigns(:concept_system)
      expect(result.pref_label).to eq("Tags")
    end

  end

  describe "Authrorized User" do
    
    def sub_dir
      return "controllers"
    end

    login_curator

    before :all do
      clear_triple_store
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_concept_system_generic_data.ttl"]
      load_files(schema_files, data_files)
    end

    it "returns a concept system tree" do
      get :index
      result = assigns(:concept_system)
      expect(result.pref_label).to eq("Tags")
    end

    it "returns a concept system tree" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, id: Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C").to_id
    #Xwrite_yaml_file(JSON.parse(response.body).deep_symbolize_keys[:data], sub_dir, "iso_concept_system_controller.yaml")
      expected = read_yaml_file(sub_dir, "iso_concept_system_controller.yaml")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to iso_concept_system_equal(expected)    
    end

    it "allows a node to be added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {id: Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C").to_id, :iso_concept_system => {:label => "New Node Label", :description => "New Node Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      expect(response.body).to eq("{\"errors\":[]}")    
    end

    it "prevents an invalid node being added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {id: Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C").to_id, :iso_concept_system => {:label => "New Label", :description => "New Description±"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")    
      expect(response.body).to eq("{\"errors\":[\"Description contains invalid characters or is empty\"]}")    
    end

  end

  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "show a concept" do
      get :show, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "add a concept" do
      post :add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts"}
      expect(response).to redirect_to("/users/sign_in")
    end
  end

end