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
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_concept_system_generic_data.ttl")
      clear_iso_concept_object
    end

    it "returns a concept system tree" do
      get :view
      result = assigns(:concept_systems)
      expected = read_yaml_file(sub_dir, "iso_concept_system_controller.yaml")
      expect(result).to eq(expected)
    end

    it "display all systems" do
      expected = 
      [
        { 
          :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
          :id => "GSC-C", 
          :namespace => "http://www.assero.co.uk/MDRConcepts", 
          :label => "Tags",
          :extension_properties => [],
          :description => "",
          :children => []
        }
      ]
      get :index, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      result = assigns(:conceptSystems)
      expect(result.length).to eq(1)
      expect(result[0].to_json).to eq(expected[0])
    end

    it "gets a new concept system" do
      result = IsoConceptSystem.new
      get :new
      expect(assigns(:conceptSystem).to_json).to eq(result.to_json)
    end

    it "allows a concept system to be created" do
      expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
        :id => "", 
        :namespace => "http://www.assero.co.uk/MDRConcepts", 
        :label => "New Concept System",
        :extension_properties => [],
        :description => "New Concept System Description",
        :children => []
      }
      post :create, {:iso_concept_system => {:label => "New Concept System", :description => "New Concept System Description"}}
      result = assigns(:conceptSystem)
      expected[:id] = result.id # Dynamic timestamped id so we need this
      expect(result.to_json).to eq(expected)
      expect(flash[:success]).to be_present
    end

    it "allows a concept system to be created" do
      post :create, {:iso_concept_system => {:label => "New Label§§", :description => "New Description"}}
      expect(flash[:error]).to be_present
    end
        
    it "get a new node" do
      expected = IsoConceptSystem::Node.new
      get :node_new, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts"}
      expect(assigns(:id)).to eq("GSC-C")
      expect(assigns(:namespace)).to eq("http://www.assero.co.uk/MDRConcepts")
      expect(assigns(:node).to_json).to eq(expected.to_json)
    end
      
    it "allows a node to be added" do
      get :node_add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Node Label", :description => "New Node Description"}}
      expect(flash[:success]).to be_present
    end

    it "prevents an invalid node being added" do
      get :node_add, {:id => "GSC-C", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_system => {:label => "New Label", :description => "New Description±"}}
      expect(flash[:error]).to be_present
    end

    it "allows a concept system to be destroyed" do
      concept_system = IsoConceptSystem.create({label: "A label", description: "A new system"})
      delete :destroy, {:id => concept_system.id, :namespace => concept_system.namespace}
      expect(flash[:success]).to be_present      
    end

    it "prevents a concept system being destroyed if it has children" do
      concept_system = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
      delete :destroy, {:id => concept_system.id, :namespace => concept_system.namespace}
      expect(flash[:error]).to be_present      
    end

    it "returns a given concept system" do
      concept_system = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
      get :show, {:id => concept_system.id, :namespace => concept_system.namespace}
      result = assigns(:conceptSystem)
      expect(result.to_json).to eq(concept_system.to_json)
    end

  end

  describe "Unauthorized User" do
    
    it "show a concept" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end