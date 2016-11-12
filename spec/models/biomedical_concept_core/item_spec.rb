require 'rails_helper'

describe BiomedicalConceptCore::Item do
  
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
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
  end

  it "validates a valid object" do
    result = BiomedicalConceptCore::Item.new
    result.bridg_class = "Class"
    result.bridg_attribute = "Attribute"
    expect(result.valid?).to eq(true)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "N_1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :extension_properties => [],
        :label => "Text Label",
        :alias => "XXXXX",
        :ordinal => 1,
        :bridg_class => "Class",
        :bridg_attribute => "Attribute",
        :children => [],
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Node",
        :datatype =>
        {
          :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
          :id => "", 
          :namespace => "", 
          :label => "", 
          :extension_properties=>[], 
          :ordinal => 1, 
          :alias => "", 
          :iso21090_datatype => "", 
          :children=>[]
        }
      }
    triples = {}
    triples ["N_1"] = []
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/CDISCBiomedicalConcept#Node" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#alias", object: "XXXXX" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#ordinal", object: "1" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#bridg_class", object: "Class" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#bridg_attribute", object: "Attribute" }
    item = BiomedicalConceptCore::Item.new(triples, "N_1")
    expect(item.to_json).to eq(result)    
  end

  it "allows the object to be found"

  it "allows the object to be exported as JSON" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :bridg_class => "Class",
        :bridg_attribute => "Attribute",
        :children => [],
        :type => "http://www.example.com/path#rdf_test_type",
        :datatype =>
        {
          :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
          :id => "", 
          :namespace => "", 
          :label => "", 
          :extension_properties=>[], 
          :ordinal => 1, 
          :alias => "", 
          :iso21090_datatype => "", 
          :children=>[]
        }
      }
    item = BiomedicalConceptCore::Item.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.label = "Test"
    item.alias = "alias"
    item.ordinal = 1
    item.bridg_class = "Class"
    item.bridg_attribute = "Attribute"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    expect(item.to_json).to eq(result)
  end

  it "allows the object to be created from JSON" do
    result = 
      {
        :id => "123", 
        :namespace => "http://www.example.com/path", 
        :extension_properties => [],
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :bridg_class => "Class",
        :bridg_attribute => "Attribute",
        :children => [],
        :type => "http://www.example.com/path#rdf_test_type",
        :datatype =>
        {
          :type => "", 
          :id => "", 
          :namespace => "", 
          :label => "", 
          :extension_properties=>[], 
          :ordinal => 1, 
          :alias => "", 
          :iso21090_datatype => "", 
          :children=>[]
        }
      }
    expect(BiomedicalConceptCore::Item.from_json(result).to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX cbc: <http://www.assero.co.uk/CDISCBiomedicalConcept#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#XXX_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#XXX_I1> rdfs:label \"test label\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:alias \"Note\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:bridg_class \"Class\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1> cbc:bridg_attribute \"Attribute\"^^xsd:string . \n" +
      "<http://www.example.com/path#XXX_I1_DT1> rdf:type <http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype> . \n" + 
      "<http://www.example.com/path#XXX_I1_DT1> rdfs:label \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXX_I1_DT1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" + 
      "<http://www.example.com/path#XXX_I1_DT1> cbc:alias \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXX_I1_DT1> cbc:iso21090_datatype \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#XXX_I1> cbc:hasComplexDatatype <http://www.example.com/path#XXX_I1> . \n" +
      "}"
    item = BiomedicalConceptCore::Item.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.alias = "Note"
    item.bridg_class = "Class"
    item.bridg_attribute = "Attribute"
    parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(parent_uri, sparql)
    expect(sparql.to_s).to eq(result)
  end
  
end
  