require 'rails_helper'

describe IsoConceptSystemsController do

  include DataHelpers
  
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
      result = assigns(:concept_systems)
    #Xwrite_yaml_file(result, sub_dir, "iso_concept_system_controller.yaml")
      expected = read_yaml_file(sub_dir, "iso_concept_system_controller.yaml")
      expect(result).to eq(expected)
    end

    it "allows a node to be added" do
      post :add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Node Label", :description => "New Node Description"}}
      expect(flash[:success]).to be_present
    end

    it "prevents an invalid node being added" do
      post :add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Label", :description => "New Description±"}}
      expect(flash[:error]).to be_present
    end

  end

  describe "Unauthorized User" do
    
    it "show a concept" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end