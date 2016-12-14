require 'rails_helper'

describe Form::Group do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    clear_iso_concept_object
  end

  it "validates a valid object" do
    result = Form::Group.new
    result.note = "OK"
    result.completion = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    result = Form::Group.new
    result.note = "OK"
    result.completion = "Draft 123>"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, note" do
    result = Form::Group.new
    result.note = "OK<"
    result.completion = "Draft 123"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_TEST_G1_I1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :completion => "",
        :extension_properties => [],
        :label => "My Group",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#NormalGroup",
        :children => []
      }
    triples = {}
    triples ["F-ACME_TEST_G1_I1"] = []
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#NormalGroup" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "My Group" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#isGroupOf", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1>" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasItem", object: "<http://www.assero.co.uk/MDRForms/UCB/V2#F-UCB_AEPI103_G1_I1>" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#label_text", object: "XXXXX" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
    expect(Form::Group.new(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)    
  end

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
      "}"
    item = Form::Group.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.completion = "Completion"
    item.note = "Note"
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as XML"
  
end
  