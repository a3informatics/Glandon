require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers

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
    concept = IsoConceptSystem.create(json)
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
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
        :description => "Description 3±",
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
        :extension_properties => [],
        :description => "Description 3_3",
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
        :extension_properties => [],
        :description => "Description 3_4",
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
        :extension_properties => [],
        :description => "Description 3_4",
        :children => []
      }
    expect(result).to eq(expected)
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
    #new_object = IsoConceptSystem.create(json)
    #expect(new_object.errors.count).to eq(1)
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
        :extension_properties => [],
        :description => "Description 3_3",
        :children => []
      }
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    #new_object = concept.add(json)
    #expect(new_object.errors.count).to eq(1)
    expect{concept.add(json)}.to raise_error(Exceptions::CreateError)
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
    concept = IsoConceptSystem.create(json)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{concept.destroy}.to raise_error(Exceptions::DestroyError)
  end

end