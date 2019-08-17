require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers

  describe "No root" do

    before :each do
      clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Basic.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Data.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_test_file_into_triple_store("iso_namespace_fake.ttl")
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl"
      ]
      data_files = 
      [
        "iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"    
      ]
      load_files(schema_files, data_files)
      clear_iso_concept_object
    end

    it "creates the root node if not present" do
      concept = IsoConceptSystem.root
      expect(concept.label).to eq("Tags")
      expect(concept.description).to eq("Root node for all tags")
    end

    it "only creates a single root node" do
      concept_1 = IsoConceptSystem.root
      concept_2 = IsoConceptSystem.root
      expect(concept_1.id).to eq(concept_2.id)
      expect(concept_1.namespace).to eq(concept_2.namespace)
    end

    it "handles a bad response error - create" do
      response = IsoConceptSystem.new
      response.errors.add(:base, "Failure!")
      expect(IsoConceptSystem).to receive(:create).and_return(response)
      expect{IsoConceptSystem.root}.to raise_error(Errors::ApplicationLogicError, "Errors creating the tag root node. Failure!")
    end

  end

  describe "Existing data" do

  	before :all do
      clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Basic.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Data.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_test_file_into_triple_store("iso_namespace_fake.ttl")
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl"
      ]
      data_files = 
      [
        "iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_concept_system_generic_data.ttl"  
      ]
      load_files(schema_files, data_files)
      clear_iso_concept_object
    end

    it "allows the object to be created from json" do
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3",
          :description => "Node 3",
          :extension_properties => [],
          :children => []
        }
      concept = IsoConceptSystem.create(json)
      result = concept.to_json
      expected =     
        { 
          :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
          :id => "", 
          :namespace => "http://www.assero.co.uk/MDRConcepts", 
          :label => "Node 3",
          :description => "Node 3",
          :extension_properties => [],
          :children => []
        }
      expected[:id] = concept.id # Needed because contains a timestamp
      expect(result).to eq(expected)
    end

    it "prevents an object being created from invalid json" do
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3",
          :description => "Node 3±",
          :extension_properties => [],
          :children => []
        }
      concept = IsoConceptSystem.create(json)
      expect(concept.errors.count).to eq(1)
    end

    it "allows a child object to be added" do
      concept = IsoConceptSystem.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3_3",
          :description => "Node 3_3",
          :extension_properties => [],
          :children => []
        }
      new_concept = concept.add(json)
      json[:id] = new_concept.id # Need this becuase of timestamped id
      json[:namespace] = "http://www.assero.co.uk/MDRConcepts"
      json[:type] = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode"
      expect(new_concept.errors.count).to eq(0)
      result = IsoConceptSystem.find(new_concept.id, "http://www.assero.co.uk/MDRConcepts", false)
      expect(result.to_json).to eq(json)
    end

    it "allows an object to be destroyed" do
      concept = IsoConceptSystem.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)
      concept.destroy
      expect{IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)}.to raise_error(Exceptions::NotFoundError)
    end

    it "allows the object to be created from json" do
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3_4",
          :description => "Node 3_4",
          :extension_properties => [],
          :children => []
        }
      concept = IsoConceptSystem.from_json(json)
      result = concept.to_json
      expected =     
        { 
          :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
          :id => "", 
          :namespace => "", 
          :label => "Node 3_4",
          :description => "Node 3_4",
          :extension_properties => [],
          :children => []
        }
      expect(result).to eq(expected)
    end

    it "handles a bad response error - create" do
      response = Typhoeus::Response.new(code: 200, body: "")
      expect(CRUD).to receive(:update).and_return(response)
      expect(response).to receive(:success?).and_return(false)
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3",
          :description => "Node 3",
          :extension_properties => [],
          :children => []
        }
      expect{IsoConceptSystem.create(json)}.to raise_error(Exceptions::CreateError)
    end

    it "handles a bad response error - add" do
      concept = IsoConceptSystem.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3_3",
          :description => "Node 3_3",
          :extension_properties => [],
          :children => []
        }
      response = Typhoeus::Response.new(code: 200, body: "")
      expect(CRUD).to receive(:update).and_return(response)
      expect(response).to receive(:success?).and_return(false)
      expect{concept.add(json)}.to raise_error(Exceptions::CreateError)
    end

    it "handles a bad response error - destroy" do
      json =     
        { 
          :type => "",
          :id => "", 
          :namespace => "", 
          :label => "Node 3",
          :description => "Node 3",
          :extension_properties => [],
          :children => []
        }
      concept = IsoConceptSystem.create(json)
      response = Typhoeus::Response.new(code: 200, body: "")
      expect(Rest).to receive(:sendRequest).and_return(response)
      expect(response).to receive(:success?).and_return(false)
      expect{concept.destroy}.to raise_error(Exceptions::DestroyError)
    end

  end

end