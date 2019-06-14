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
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_concept_system_generic_data.ttl")
      clear_iso_concept_object
    end

    it "allows a node to be added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => "GSC-C2", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_systems_node => {:label => "New Node Label", :description => "New Node Description"}}
      concept_system = IsoConceptSystem.find("GSC-C", "http://www.assero.co.uk/MDRConcepts")
    #write_yaml_file(concept_system.to_json, sub_dir, "concept_system_2.yaml")
      expected = read_yaml_file(sub_dir, "concept_system_2.yaml")
      json = concept_system.to_json
      node = json[:children].select {|x| x[:id] == "GSC-C2" }
      new_node_id = node[0][:children][0][:id]
      expected_node = expected[:children].select {|x| x[:id] == "GSC-C2" }
      expected_node[0][:children][0][:id] = new_node_id
      expect(concept_system.to_json).to eq(expected)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
    end

    it "prevents an invalid node being added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => "GSC-C2", :namespace => "http://www.assero.co.uk/MDRConcepts", :iso_concept_systems_node => {:label => "New Label", :description => "New Description±±"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")    
      expect(response.body).to eq("{\"errors\":[\"Description contains invalid characters or is empty\"]}")    
    end

    it "allows a node to be destroyed" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent_node = IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts")
      node = parent_node.add({label: "A label", description: "A new system"})
      delete :destroy, {:id => node.id, :namespace => node.namespace}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
    end

    it "prevents a node being destroyed if it has children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
      delete :destroy, {:id => node.id, :namespace => node.namespace}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("500")    
      expect(response.body).to eq("{\"errors\":[\"Cannot destroy tag as it has children tags\"]}")    
    end

    it "update a node" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
      post :update, {:id => node.id, :namespace => node.namespace, :iso_concept_systems_node => {:label => "Updated Label", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
    end

    it "update a node, errors" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
      post :update, {:id => node.id, :namespace => node.namespace, :iso_concept_systems_node => {:label => "Updated Label±±", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")   
      expect(response.body).to eq("{\"errors\":[\"Label contains invalid characters\"]}") 
    end

  end

  describe "Unauthorized User" do
    
    it "add a concept" do
      post :add, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1", :iso_concept_systems_node => {:label => "New Node Label", :description => "New Node Description"}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end