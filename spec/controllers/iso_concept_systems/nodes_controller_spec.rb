require 'rails_helper'

describe IsoConceptSystems::NodesController do

  include DataHelpers

  describe "Authrorized User" do

    login_curator

    def sub_dir
      return "controllers/iso_concept_systems"
    end

    before :all do
      data_files =["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_concept_system_generic_data.ttl"]
      load_files(schema_files, data_files)
    end

    it "allows a node to be added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2").to_id, :iso_concept_systems_node => {:label => "New Node Label", :description => "New Node Description"}}
      result = IsoConceptSystem::Node.find_children(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
      actual = result.to_h
      expected = read_yaml_file(sub_dir, "concept_system_2.yaml")
      actual[:narrower][0][:id] = expected[:narrower][0][:id]
      actual[:narrower][0][:uri] = expected[:narrower][0][:uri]
    #Xwrite_yaml_file(actual.to_h, sub_dir, "concept_system_2.yaml")
      expect(actual).to hash_equal(expected)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "prevents an invalid node being added" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2").to_id, :iso_concept_systems_node => {:label => "New Label", :description => "New Description±±"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")
      expect(response.body).to eq("{\"errors\":[\"Description contains invalid characters or is empty\"]}")
    end

    it "prevents an invalid node being added, empty fields" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, {:id => Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2").to_id, :iso_concept_systems_node => {:label => "", :description => ""}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")
      expect(response.body).to eq("{\"errors\":[\"Pref label is empty\",\"Description contains invalid characters or is empty\"]}")
    end

    it "allows a node to be destroyed" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent_node = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
      node = parent_node.add({label: "A label", description: "A new system"})
      delete :destroy, :id => node.id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "prevents a node being destroyed if it has children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
      delete :destroy, {:id => node.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("500")
      expect(response.body).to eq("{\"errors\":[\"Cannot destroy tag as it has children tags or the tag or a child tag is currently in use.\"]}")
    end

    it "update a node" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
      post :update, {:id => node.id, :iso_concept_systems_node => {:label => "Updated Label", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "update a node, errors" do
      request.env['HTTP_ACCEPT'] = "application/json"
      node = IsoConceptSystem::Node.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
      post :update, {:id => node.id, :iso_concept_systems_node => {:label => "Updated Label±±", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")
      expect(response.body).to eq("{\"errors\":[\"Pref label contains invalid characters\"]}")
    end

  end

  describe "Unauthorized User" do

    it "add a concept" do
      post :add, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1", :iso_concept_systems_node => {:label => "New Node Label", :description => "New Node Description"}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
