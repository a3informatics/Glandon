require 'rails_helper'

describe IsoConceptSystem::Node do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models/iso_concept_system"
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
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a child object to be added" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_3",
        :description => "XXX",
        :extension_properties => [],
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

  it "allows the system to be found, I" do
    cs_uri = IsoConceptSystem::Node.find_system("GSC-C3_2", "http://www.assero.co.uk/MDRConcepts")
    uri =  
    { 
      id: "GSC-C",
      namespace: "http://www.assero.co.uk/MDRConcepts",
    }
    expect(cs_uri.to_json).to eq(uri)
  end

  it "allows the system to be found, II" do
    cs_uri = IsoConceptSystem::Node.find_system("GSC-C2", "http://www.assero.co.uk/MDRConcepts")
    uri =  
    { 
      id: "GSC-C",
      namespace: "http://www.assero.co.uk/MDRConcepts",
    }
    expect(cs_uri.to_json).to eq(uri)
  end

  it "allows the system to be found, III" do
    cs_uri = IsoConceptSystem::Node.find_system("GSC-C", "http://www.assero.co.uk/MDRConcepts")
    uri =  
    { 
      id: "GSC-C",
      namespace: "http://www.assero.co.uk/MDRConcepts",
    }
    expect(cs_uri.to_json).to eq(uri)
  end

  it "allows the parent to be found, I" do
    csn_uri = IsoConceptSystem::Node.find_parent("GSC-C3_2", "http://www.assero.co.uk/MDRConcepts")
    uri =  
    { 
      id: "GSC-C3",
      namespace: "http://www.assero.co.uk/MDRConcepts",
    }
    expect(csn_uri.to_json).to eq(uri)
  end

  it "allows the parent to be found, II" do
    csn_uri = IsoConceptSystem::Node.find_parent("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
    expect(csn_uri).to eq(nil)
  end

  it "prevents a child object being added from invalid json" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
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
    new_concept = concept.add(json)
    expect(new_concept.errors.full_messages.to_sentence).to eq("Description contains invalid characters or is empty")
    expect(new_concept.errors.count).to eq(1)
  end

  it "allows an object to be destroyed, no children" do
    concept = IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)
    concept.destroy
    expect(concept.errors.count).to eq(0)
    expect{IsoConceptSystem::Node.find("GSC-C2", "http://www.assero.co.uk/MDRConcepts", false)}.to raise_error(Exceptions::NotFoundError)
  end

  it "prevents an object being destroyed, children" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
    concept.destroy
    expect(concept.errors.count).to eq(1)
    expect(concept.errors.full_messages.to_sentence).to eq("Cannot destroy tag as it has children tags")
  end

  it "allows the object to be created from json" do
    json =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "Node 3_4",
        :description => "definition X",
        :extension_properties => [],
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
        :description => "definition X",
        :children => []
      }
    expect(result).to eq(expected)
  end

  it "allows the object to be returned as SPARQL" do
    expected = read_text_file_2(sub_dir, "node_sparql.txt")
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result = concept.to_sparql_v2
    timestamps = /(\d{10})/.match(result.to_s) # Find the timestamp used in the test call
    updated_expected = expected.gsub("NNNNNNNNNN", timestamps[0]) # Update the expected results with the timestamp
    expect(result.to_s).to eq(updated_expected)
  end

  it "handles a bad response error - add" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
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
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{concept.add(json)}.to raise_error(Exceptions::CreateError)
  end

  it "handles a bad response error - destroy" do
    concept = IsoConceptSystem::Node.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{concept.destroy}.to raise_error(Exceptions::DestroyError)
  end

end