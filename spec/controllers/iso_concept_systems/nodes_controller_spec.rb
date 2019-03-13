require 'rails_helper'

describe IsoConceptSystems::NodesController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_curator

    def sub_dir
      return "controllers/iso_concept_systems"
    end

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

    it "get a new node" do
      expected = IsoConceptSystem::Node.new
      get :node_new, {:id => "GSC-C1", :namespace => "http://www.assero.co.uk/MDRConcepts"}
      expect(assigns(:id)).to eq("GSC-C1")
      expect(assigns(:namespace)).to eq("http://www.assero.co.uk/MDRConcepts")
      expect(assigns(:node).to_json).to eq(expected.to_json)
      concept_system = assigns(:concept_system)
    #write_yaml_file(concept_system.to_json, sub_dir, "concept_system_1.yaml")
      expected = read_yaml_file(sub_dir, "concept_system_1.yaml")
      expect(concept_system.to_json).to eq(expected)
      expect(assigns(:concept_system_path)).to eq("/iso_concept_systems/GSC-C?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
      parent_node = assigns(:parent_node)
    #write_yaml_file(parent_node.to_json, sub_dir, "parent_node_1.yaml")
      expected = read_yaml_file(sub_dir, "parent_node_1.yaml")
      expect(parent_node.to_json).to eq(expected)
      expect(assigns(:parent_node_path)).to eq("/iso_concept_systems/nodes/GSC-C1?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
    end
      
    it "allows a node to be added" do
      get :node_add, {:id => "GSC-C2", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_systems_node => {:label => "New Node Label", :description => "New Node Description"}}
      expect(flash[:success]).to be_present
      concept_system = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
    #write_yaml_file(concept_system.to_json, sub_dir, "concept_system_2.yaml")
      expected = read_yaml_file(sub_dir, "concept_system_2.yaml")
      json = concept_system.to_json
      node = json[:children].select {|x| x[:id] == "GSC-C2" }
      new_node_id = node[0][:children][0][:id]
      expected_node = expected[:children].select {|x| x[:id] == "GSC-C2" }
      expected_node[0][:children][0][:id] = new_node_id
      expect(concept_system.to_json).to eq(expected)
    end

    it "prevents an invalid node being added" do
      get :node_add, {:id => "GSC-C2", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_systems_node => {:label => "New Label", :description => "New Description±±"}}
      expect(flash[:error]).to be_present
    end

    it "allows a node to be destroyed" do
      parent_node = IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts")
      node = parent_node.add({label: "A label", description: "A new system"})
      delete :destroy, {:id => node.id, :namespace => node.namespace, :parent_id => parent_node.id, :parent_namespace => parent_node.namespace}
      expect(flash[:success]).to be_present      
    end

    it "prevents a node being destroyed if it has children" do
      parent_node = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
      node = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
      delete :destroy, {:id => node.id, :namespace => node.namespace, :parent_id => parent_node.id, :parent_namespace => parent_node.namespace}
      expect(flash[:error]).to be_present      
    end

    it "returns a given node, no parent" do
      expected = IsoConceptSystem::Node.find("GSC-C1", "http://www.assero.co.uk/MDRConcepts")
      get :show, {:id => expected.id, :namespace => expected.namespace}
      result = assigns(:node)
      expect(result.to_json).to eq(expected.to_json)
      expect(assigns(:node_path)).to eq("/iso_concept_systems/nodes/GSC-C1?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
      concept_system = assigns(:concept_system)
      expected = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
      expect(concept_system.to_json).to eq(expected.to_json)
      expect(assigns(:concept_system_path)).to eq("/iso_concept_systems/GSC-C?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
      expect(assigns(:parent_node)).to eq(nil)
      expect(assigns(:parent_node_path)).to eq("")
    end

    it "returns a given node, parent" do
      expected = IsoConceptSystem::Node.find("GSC-C3_2", "http://www.assero.co.uk/MDRConcepts")
      get :show, {:id => expected.id, :namespace => expected.namespace}
      result = assigns(:node)
      expect(result.to_json).to eq(expected.to_json)
      expect(assigns(:node_path)).to eq("/iso_concept_systems/nodes/GSC-C3_2?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
      concept_system = assigns(:concept_system)
      expected = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
      expect(concept_system.to_json).to eq(expected.to_json)
      expect(assigns(:concept_system_path)).to eq("/iso_concept_systems/GSC-C?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
      parent_node = assigns(:parent_node)
    #write_yaml_file(parent_node.to_json, sub_dir, "parent_node_2.yaml")
      expected = read_yaml_file(sub_dir, "parent_node_2.yaml")
      expect(parent_node.to_json).to eq(expected)
      expect(assigns(:parent_node_path)).to eq("/iso_concept_systems/nodes/GSC-C3?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRConcepts")
    end

  end

  describe "Unauthorized User" do
    
    it "show a concept" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end