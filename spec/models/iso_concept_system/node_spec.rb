require 'rails_helper'

describe IsoConceptSystem::Node do

	include DataHelpers
  include PauseHelpers

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
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows the object to be created from json" do
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    concept = IsoConceptSystem::Node.create(json)
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "", 
        :namespace => "http://www.assero.co.uk/MDRConcepts", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
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
        :extension_properties => [],
        :description => "Description 3<>",
        :children => []
      }
    concept = IsoConceptSystem::Node.create(json)
    expect(concept.errors.count).to eq(1)
  end

  it "allows a child object to be added" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_3",
        :extension_properties => [],
        :description => "Description 3_3",
        :children => []
      }
    new_concept = concept.add(json)
    json[:id] = new_concept.id # Need this becuase of timestamped id
    json[:namespace] = "http://www.assero.co.uk/MDRConcepts"
    json[:type] = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode"
    expect(new_concept.errors.count).to eq(0)
    new_concept = IsoConceptSystem::Node.find(new_concept.id, "http://www.assero.co.uk/MDRConcepts", false)
    expect(new_concept.to_json).to eq(json)
  end

  it "allows an object to be destroyed" do
    concept = IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)
    concept.destroy
    concept = IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)
    expect(concept.id).to eq("")
  end

  it "allows the object to be created from json" do
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_4",
        :extension_properties => [],
        :description => "Description 3_4",
        :children => []
      }
    concept = IsoConceptSystem::Node.from_json(json)
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_4",
        :extension_properties => [],
        :description => "Description 3_4",
        :children => []
      }
    expect(result).to eq(expected)
  end

  it "allows the object to be returned as SPARQL" do
    expected = read_text_file("iso_concept_system_node_sparql.txt")
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result = concept.to_sparql_v2
    timestamps = /(\d{10})/.match(result.to_s) # Find the timestamp used in the test call
    updated_expected = expected.gsub("NNNNNNNNNN", timestamps[0]) # Update the expected results with the timestamp
    expect(result.to_s).to eq(updated_expected)
  end

  it "handles a bad response error - create" do
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    new_object = IsoConceptSystem::Node.create(json)
    expect(new_object.errors.count).to eq(1)
  end

  it "handles a bad response error - add" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_3",
        :extension_properties => [],
        :description => "Description 3_3",
        :children => []
      }
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    new_object = concept.add(json)
    expect(new_object.errors.count).to eq(1)
  end

  it "handles a bad response error - destroy" do
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    concept = IsoConceptSystem::Node.create(json)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{concept.destroy}.to raise_error(Exceptions::DestroyError)
  end

end