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
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "returns a concept system tree, none exists" do
      get :index
      result = assigns(:concept_system)
      expect(result.id.start_with?("CS-BBB_")).to eq(true)
      expect(result.namespace).to eq("http://www.assero.co.uk/MDRConcepts")
    end

  end

  describe "Authrorized User" do
    
    def sub_dir
      return "controllers"
    end

    login_curator

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_concept_system_generic_data.ttl")
      clear_iso_concept_object
    end

    it "returns a concept system tree" do
      get :index
      result = assigns(:concept_system)
      expect(result.id).to eq("GSC-C")
      expect(result.namespace).to eq("http://www.assero.co.uk/MDRConcepts")
    end

    it "returns a concept system tree" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts"}
    #Xwrite_yaml_file(result, sub_dir, "iso_concept_system_controller.yaml")
      expected = read_yaml_file(sub_dir, "iso_concept_system_controller.yaml")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)    
    end

    it "allows a node to be added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Node Label", :description => "New Node Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      expect(response.body).to eq("{\"errors\":[]}")    
    end

    it "prevents an invalid node being added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Label", :description => "New Description±"}}
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