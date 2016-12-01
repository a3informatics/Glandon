require 'rails_helper'

describe IsoConceptSystemGeneric do

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

	it "validates a valid object" do
    result = IsoConceptSystemGeneric.new
    result.description = "Hello world"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    result = IsoConceptSystemGeneric.new
    result.description = "Hello world<>"
    expect(result.valid?).to eq(false)
  end

  it "allows a blank object to be created" do
    result =     
      { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :label => "",
        :extension_properties => [],
        :description => "",
        :children => []
      }
    expect(IsoConceptSystemGeneric.new.to_json).to match(result)
  end

  it "finds a given object, no children" do
    concept = IsoConceptSystemGeneric.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "GSC-C3", 
        :namespace => "http://www.assero.co.uk/MDRConcepts", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    expect(concept.to_json).to eq(result)
  end

  it "finds a given object with children" do
    concept = IsoConceptSystemGeneric.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts")
    result =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "GSC-C3", 
        :namespace => "http://www.assero.co.uk/MDRConcepts", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => 
        [
          {
            :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode", 
            :id=>"GSC-C3_2", :namespace=>"http://www.assero.co.uk/MDRConcepts", 
            :label=>"Node 3_2", 
            :extension_properties=>[], 
            :description=>"Description 3_2", 
            :children=>[]
          }, 
          {
            :type=>"http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode", 
            :id=>"GSC-C3_1", 
            :namespace=>"http://www.assero.co.uk/MDRConcepts", 
            :label=>"Node 3_1", 
            :extension_properties=>[], 
            :description=>"Description 3_1", 
            :children=>[]
          }
        ]
      }
    expect(concept.to_json).to eq(result)
  end

  it "finds all objects" do
    concepts = IsoConceptSystemGeneric.all("ConceptSystem")
    result = [
      {
        description: "",
        children: [],
        rdf_type: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
        id: "GSC-C",
        namespace: "http://www.assero.co.uk/MDRConcepts",
        label: "Tags",
        properties: [],
        links: [],
        extension_properties: [],
        triples: {}
      }
    ]
    expect(concepts.to_json).to eq(result.to_json)
  end

  it "allows the object to be returned as json" do
    concept = IsoConceptSystemGeneric.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "GSC-C3", 
        :namespace => "http://www.assero.co.uk/MDRConcepts", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    expect(concept.to_json).to eq(expected)
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
    concept = IsoConceptSystemGeneric.from_json(json, "ConceptSystemNode")
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
        :id => "", 
        :namespace => "", 
        :label => "Node 3",
        :extension_properties => [],
        :description => "Description 3",
        :children => []
      }
    expect(result).to eq(expected)
  end

  it "allows the object to be returned as SPARQL" do
    expected = read_text_file("iso_concept_system_generic_sparql.txt")
    concept = IsoConceptSystemGeneric.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result = concept.to_sparql_v2("GSC")
    timestamps = /(\d{10})/.match(result.to_s) # Find the timestamp used in the test call
    updated_expected = expected.gsub("NNNNNNNNNN", timestamps[0]) # Update the expected results with the timestamp
    expect(result.to_s).to eq(updated_expected)
  end

end