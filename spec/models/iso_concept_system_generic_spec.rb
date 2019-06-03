require 'rails_helper'

describe IsoConceptSystemGeneric do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models"
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

  class ICSGTest1 < IsoConceptSystemGeneric
    C_CID_PREFIX = "CS"
    C_RDF_TYPE = "ConceptSystem"
  end

  class ICSGTest2 < IsoConceptSystemGeneric
    C_CID_PREFIX = "GSC"
    C_RDF_TYPE = "ConceptSystemNode"
  end

	it "validates a valid object" do
    result = IsoConceptSystemGeneric.new
    result.label = "Hello world"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    result = IsoConceptSystemGeneric.new
    result.label = "Hello world±"
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
        :children => 
        [
          {
            :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode", 
            :id=>"GSC-C3_2", :namespace=>"http://www.assero.co.uk/MDRConcepts", 
            :label=>"Node 3_2", 
            :extension_properties=>[], 
            :children=>[]
          }, 
          {
            :type=>"http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode", 
            :id=>"GSC-C3_1", 
            :namespace=>"http://www.assero.co.uk/MDRConcepts", 
            :label=>"Node 3_1", 
            :extension_properties=>[], 
            :children=>[]
          }
        ]
      }
    expect(concept.to_json).to eq(result)
  end

  it "finds all objects" do
    concepts = ICSGTest1.all
    result = [
      {
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
    expect(concepts.to_json).to hash_equal(result.to_json)
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
        :children => []
      }
    concept = ICSGTest1.from_json(json)
    result = concept.to_json
    expected =     
      { 
        :type => "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
        :id => "", 
        :namespace => "", 
        :label => "Node 3",
        :extension_properties => [],
        :children => []
      }
    expect(result).to eq(expected)
  end

  it "allows the object to be returned as SPARQL" do
    expected = read_text_file_2(sub_dir, "iso_concept_system_generic_sparql.txt")
    concept = ICSGTest2.find("GSC-C3", "http://www.assero.co.uk/MDRConcepts", false)
    result = concept.to_sparql_v2
    timestamps = /(\d{10})/.match(result.to_s) # Find the timestamp used in the test call
    updated_expected = expected.gsub("NNNNNNNNNN", timestamps[0]) # Update the expected results with the timestamp
    expect(result.to_s).to eq(updated_expected)
  end

end