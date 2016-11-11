require 'rails_helper'

describe OperationalReferenceV2 do

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
    load_data_file_into_triple_store("MDRIdentificationACME.ttl")
    load_data_file_into_triple_store("ACME_DM1 01.ttl")
  end
 
  it "validates a valid object" do
    result = OperationalReferenceV2.new
    result.local_label = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = OperationalReferenceV2.new
    result.local_label = "Draft 123 more tesxt >"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_OR_G1_I1", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :local_label => "sssssssssss",
        :extension_properties => [],
        :label => "BC Property Reference",
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :subject_ref => "null",
        :type => "http://www.assero.co.uk/BusinessOperational#PReference"
      }
    triples = {}
    triples ["F-ACME_OR_G1_I1"] = []
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessOperational#PReference" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "BC Property Reference" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#isItemOf", object: "<http://www.assero.co.uk/X/V1#F-ACME_OR_G1>" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#enabled", object: "true" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessOperational#local_label", object: "sssssssssss" }
    triples ["F-ACME_OR_G1_I1"] << { subject: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    expect(OperationalReferenceV2.new(triples, "F-ACME_OR_G1_I1").to_json).to eq(result)    
  end

  it "allows the object to be initialized from JSON" do
    result = 
      {
        :id => "F-ACME_OR_G1_I1", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :local_label => "XXXXX",
        :extension_properties => [],
        :label => "BC Property Reference",
        :subject_ref => UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"}).to_json,
        :optional => false,
        :ordinal => 1,
        :enabled => true,
        :type => "http://www.assero.co.uk/BusinessForm#PReference"
      }
    item = OperationalReferenceV2.from_json(result)
    expect(item.to_json).to eq(result)
  end

  it "allows an object to be found from triples"

  it "allows an object to be exported as SPARQL, TcReference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#TcReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Thesaurus Concept Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:hasThesaurusConcept <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "hasThesaurusConcept", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as SPARQL, TpReference" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX bo: <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.example.com/path#parent_XXX1> rdf:type <http://www.assero.co.uk/BusinessOperational#TpReference> . \n" +
      "<http://www.example.com/path#parent_XXX1> rdfs:label \"Based on Template Reference\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:basedOnTemplate <http://www.example.com/path#fragement> . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:enabled \"true\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_XXX1> bo:local_label \"****local****\"^^xsd:string . \n" + 
      "}"
    item = OperationalReferenceV2.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.local_label = "****local****"
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), "basedOnTemplate", "XXX", 1, sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as JSON" do
    result = 
      {
        :id => "fragment", 
        :namespace => "http://www.assero.co.uk/X/V1", 
        :local_label => "****local****",
        :extension_properties => [],
        :label => "BC Property Reference",
        :enabled => true,
        :optional => false,
        :ordinal => 1,
        :subject_ref => UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"}).to_json,
        :type => "http://www.assero.co.uk/BusinessForm#PReference"
      }
    item = OperationalReferenceV2.new
    item.id = "fragment"
    item.namespace = "http://www.assero.co.uk/X/V1"
    item.rdf_type = "http://www.assero.co.uk/BusinessForm#PReference"
    item.label = "BC Property Reference"
    item.local_label = "****local****"
    item.enabled = true
    item.optional = false  
    item.ordinal = 1
    item.subject_ref = UriV2.new({:id => "fragement", :namespace => "http://www.example.com/path"})
    expect(item.to_json).to eq(result)
  end

	it "clears triple store" do
    clear_triple_store
  end

end