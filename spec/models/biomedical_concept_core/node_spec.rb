require 'rails_helper'
require 'biomedical_concept_core/node'

describe BiomedicalConceptCore::Node do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", "BC.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
  end

  it "validates a valid object" do
    result = BiomedicalConceptCore::Node.new
    result.ordinal = "1"
    result.alias = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    result = BiomedicalConceptCore::Node.new
    result.ordinal = "1"
    result.alias = "Draft 123>"
    result.label = "@£$%^&*("
    expect(result.valid?).to eq(false)
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
        :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Node"
      }
    triples = {}
    triples ["N_1"] = []
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/CDISCBiomedicalConcept#Node" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#alias", object: "XXXXX" }
    triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#ordinal", object: "1" }
    item = BiomedicalConceptCore::Node.new(triples, "N_1")
    expect(item.to_json).to eq(result)    
  end

  it "allows the object to be found"

  it "allows the object to be exported as JSON" do
    result =
      {
        :id => "123",
        :namespace => "http://www.example.com/path",
        :type => "http://www.example.com/path#rdf_test_type",
        :label => "Test",
        :alias => "alias",
        :ordinal => 1, 
        :extension_properties => []
      }
    item = BiomedicalConceptCore::Node.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.label = "Test"
    item.alias = "alias"
    item.ordinal = 1
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    expect(item.to_json).to eq(result)
  end

  it "allows the object to be created from JSON" do
    result =
      {
        :id => "123",
        :namespace => "http://www.example.com/path",
        :type => "http://www.example.com/path#rdf_test_type",
        :label => "Test",
        :alias => "alias",
        :ordinal => 1,
        :extension_properties => []
      }
    expect(BiomedicalConceptCore::Node.from_json(result).to_json).to eq(result)
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
      "<http://www.example.com/path#123> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#123> rdfs:label \"test label\"^^xsd:string . \n" +
      "<http://www.example.com/path#123> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#123> cbc:alias \"Note\"^^xsd:string . \n" +
      "}"
    item = BiomedicalConceptCore::Node.new
    item.id = "123"
    item.namespace = "http://www.example.com/path"
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.alias = "Note"
    item.to_sparql_v2(sparql)
    expect(sparql.to_s).to eq(result)
  end
  
end
  