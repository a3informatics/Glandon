require 'rails_helper'

describe Form::Group::Common::Common do
  
  include DataHelpers

  def sub_dir
    return "models/form/group"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    item = Form::Group::Common.new
    item.note = "OK"
    item.completion = "Draft 123"
    item.ordinal = 2
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    item = Form::Group::Common.new
    item.note = "OK"
    item.completion = "Draft 123±"
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Completion contains invalid markdown")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, note" do
    item = Form::Group::Common.new
    item.note = "OK±"
    item.completion = "Draft 123"
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Note contains invalid markdown")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_TEST_G1_G1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :completion => "",
        :extension_properties => [],
        :label => "My Group",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#CommonGroup",
        :children => []
      }
    triples = {}
    triples ["F-ACME_TEST_G1_I1"] = []
    triples ["F-ACME_TEST_G1_I1"] << 
    { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", 
      object: "http://www.assero.co.uk/BusinessForm#CommonGroup" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.w3.org/2000/01/rdf-schema#label", 
      object: "My Group" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#hasItem", 
      object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1_I1>" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#hasItem", 
      object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1_I2>" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#note", 
      object: "xxxxx" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#optional", 
      object: "false" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#label_text", 
      object: "XXXXX" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#ordinal", 
      object: "1" 
    }
    triples ["F-ACME_TEST_G1_I1"] << 
    { 
      subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_G1", 
      predicate: "http://www.assero.co.uk/BusinessForm#completion", 
      object: "" 
    }
    expect(Form::Group::Common.new(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)    
  end

  it "allows an object to be found" do
    item = Form::Group::Common.find("F-ACME_VSBASELINE1_G1_G1","http://www.assero.co.uk/MDRForms/ACME/V1")
    #write_hash_to_yaml_file_2(item.to_json, sub_dir, "common_find.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "common_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows an object to be created from JSON"
  
  it "allows an object to be exported as JSON"

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_G1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#parent_G1> rdfs:label \"test label\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1> bf:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_G1> bf:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_G1> bf:note \"Note\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1> bf:completion \"Completion\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I1> rdf:type <http://www.assero.co.uk/BusinessForm#CommonItem> . \n" +
      "<http://www.example.com/path#parent_G1_I1> rdfs:label \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I1> bf:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_G1_I1> bf:note \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I1> bf:completion \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#parent_G1_I1> bf:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_G1> bf:hasItem <http://www.example.com/path#parent_G1_I1> . \n" +
      "<http://www.example.com/path#parent_G1_I2> rdf:type <http://www.assero.co.uk/BusinessForm#CommonItem> . \n" +
      "<http://www.example.com/path#parent_G1_I2> rdfs:label \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I2> bf:ordinal \"2\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_G1_I2> bf:note \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I2> bf:completion \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_G1_I2> bf:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_G1> bf:hasItem <http://www.example.com/path#parent_G1_I2> . \n" +
      "}"
    item = Form::Group::Common.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.completion = "Completion"
    item.note = "Note"
    item.ordinal = 1
    common_item = Form::Item::Common.new
    common_item.ordinal = 1
    item.children << common_item
    common_item = Form::Item::Common.new
    common_item.ordinal = 2
    item.children << common_item
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as XML"
  
end
  