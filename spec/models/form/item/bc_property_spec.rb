require 'rails_helper'

describe Form::Item::BcProperty do
  
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
    result = Form::Item::BcProperty.new
    result.property_ref = nil
    result.children = Array.new
    expect(result.valid?).to eq(true)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_TEST_G1_I1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :completion => "",
        :extension_properties => [],
        :label => "Date and Time (--DTC)",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#BcProperty",
        :is_common => true,
        :children => [],
        :property_ref => "null",
      }
    triples = {}
    triples ["F-ACME_TEST_G1_I1"] = []
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#BcProperty" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Date and Time (--DTC)" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#is_common", object: "true" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasCommonItem", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_I1>" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasProperty", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_PR0>" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasThesaurusConcept", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_TCR0>" }
    expect(Form::Item::BcProperty.new(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)    
  end

  it "allows an object to be found"

  it "allows an object to be found from triples"

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#XXXX_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#XXXX_I1> rdfs:label \"label\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXXX_I1> bf:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#XXXX_I1> bf:note \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXXX_I1> bf:completion \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXXX_I1> bf:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#XXXX_I1> bf:is_common \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#XXXX_I1_PR0> rdf:type <http://www.assero.co.uk/BusinessOperational#PReference> . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> rdfs:label \"BC Property Reference\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> bo:hasProperty <http://www.example.com/path#test> . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> bo:enabled \"true\"^^xsd:boolean . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> bo:optional \"false\"^^xsd:boolean . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> bo:ordinal \"0\"^^xsd:positiveInteger . \n" + 
      "<http://www.example.com/path#XXXX_I1_PR0> bo:local_label \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXXX_I1> bf:hasProperty <http://www.example.com/path#XXXX_I1_PR0> . \n" +
      "}"
    item = Form::Item::BcProperty.new
    item.property_ref = OperationalReferenceV2.new
    item.property_ref.subject_ref = UriV2.new({:id => "test", :namespace => "http://www.example.com/path"})
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.is_common = true
    item.to_sparql_v2(UriV2.new({:id => "XXXX", :namespace => "http://www.example.com/path"}), sparql)
    expect(sparql.to_s).to eq(result)
  end
  
  it "allows an object to be exported as XML"

end
  