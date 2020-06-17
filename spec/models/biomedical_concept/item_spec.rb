require 'rails_helper'
require 'biomedical_concept/item'

describe BiomedicalConcept::Item do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/biomedical_concept/item"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
  end

  it "validates a valid object" do
    item = BiomedicalConcept::Item.new
    item.mandatory = true
    item.enabled = false
    item.ordinal = 1
    item.uri = item.create_uri(item.class.base_uri)
    result = item.valid?
    expect(result).to eq(true)
  end

  # it "allows object to be initialized from triples" do
  #   result = 
  #     {
  #       :id => "N_1", 
  #       :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
  #       :extension_properties => [],
  #       :label => "Text Label",
  #       :alias => "XXXXX",
  #       :ordinal => 1,
  #       :bridg_class => "Class",
  #       :bridg_attribute => "Attribute",
  #       :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Node",
  #       :datatype =>
  #       {
  #         :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
  #         :id => "", 
  #         :namespace => "", 
  #         :label => "", 
  #         :extension_properties=>[], 
  #         :ordinal => 1, 
  #         :alias => "", 
  #         :iso21090_datatype => "", 
  #         :children=>[]
  #       }
  #     }
  #   triples = {}
  #   triples ["N_1"] = []
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/CDISCBiomedicalConcept#Node" }
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#alias", object: "XXXXX" }
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#ordinal", object: "1" }
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#bridg_class", object: "Class" }
  #   triples ["N_1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#N_1", predicate: "http://www.assero.co.uk/CDISCBiomedicalConcept#bridg_attribute", object: "Attribute" }
  #   item = BiomedicalConcept::Item.new(triples, "N_1")
  #   expect(item.to_json).to eq(result)    
  # end

  # it "allows the object to be found" do
  #   item = BiomedicalConcept::Item.find("BC-ACME_BC_C16358_DefinedObservation_targetAnatomicSiteCode", "http://www.assero.co.uk/MDRBCs/V1")
  #   write_yaml_file(item.to_json, sub_dir, "item_find.yaml")
  #   expected = read_yaml_file(sub_dir, "item_find.yaml")
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows the object to be exported as JSON" do
  #   result = 
  #     {
  #       :id => "123", 
  #       :namespace => "http://www.example.com/path", 
  #       :extension_properties => [],
  #       :label => "Test",
  #       :alias => "alias",
  #       :ordinal => 1,
  #       :bridg_class => "Class",
  #       :bridg_attribute => "Attribute",
  #       :type => "http://www.example.com/path#rdf_test_type",
  #       :datatype =>
  #       {
  #         :type => "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype", 
  #         :id => "", 
  #         :namespace => "", 
  #         :label => "", 
  #         :extension_properties=>[], 
  #         :ordinal => 1, 
  #         :alias => "", 
  #         :iso21090_datatype => "", 
  #         :children=>[]
  #       }
  #     }
  #   item = BiomedicalConcept::Item.new
  #   item.id = "123"
  #   item.namespace = "http://www.example.com/path"
  #   item.label = "Test"
  #   item.alias = "alias"
  #   item.ordinal = 1
  #   item.bridg_class = "Class"
  #   item.bridg_attribute = "Attribute"
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   expect(item.to_json).to eq(result)
  # end

  # it "allows the object to be created from JSON" do
  #   result = 
  #     {
  #       :id => "123", 
  #       :namespace => "http://www.example.com/path", 
  #       :extension_properties => [],
  #       :label => "Test",
  #       :alias => "alias",
  #       :ordinal => 1,
  #       :bridg_class => "Class",
  #       :bridg_attribute => "Attribute",
  #       :type => "http://www.example.com/path#rdf_test_type",
  #       :datatype =>
  #       {
  #         :type => "", 
  #         :id => "", 
  #         :namespace => "", 
  #         :label => "", 
  #         :extension_properties=>[], 
  #         :ordinal => 1, 
  #         :alias => "", 
  #         :iso21090_datatype => "", 
  #         :children=>[]
  #       }
  #     }
  #   expect(BiomedicalConcept::Item.from_json(result).to_json).to eq(result)
  # end

  # it "allows an object to be exported as SPARQL" do
  #   sparql = SparqlUpdateV2.new
  #   result = 
  #     "PREFIX cbc: <http://www.assero.co.uk/CDISCBiomedicalConcept#>\n" +
  #     "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
  #     "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
  #     "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
  #     "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
  #     "INSERT DATA \n" +
  #     "{ \n" + 
  #     "<http://www.example.com/path#XXX_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
  #     "<http://www.example.com/path#XXX_I1> rdfs:label \"test label\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#XXX_I1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" +
  #     "<http://www.example.com/path#XXX_I1> cbc:alias \"Note\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#XXX_I1> cbc:bridg_class \"Class\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#XXX_I1> cbc:bridg_attribute \"Attribute\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#XXX_I1_DT1> rdf:type <http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype> . \n" + 
  #     "<http://www.example.com/path#XXX_I1_DT1> rdfs:label \"\"^^xsd:string . \n" + 
  #     "<http://www.example.com/path#XXX_I1_DT1> cbc:ordinal \"1\"^^xsd:positiveInteger . \n" + 
  #     "<http://www.example.com/path#XXX_I1_DT1> cbc:alias \"\"^^xsd:string . \n" + 
  #     "<http://www.example.com/path#XXX_I1_DT1> cbc:iso21090_datatype \"\"^^xsd:string . \n" + 
  #     "<http://www.example.com/path#XXX_I1> cbc:hasDatatype <http://www.example.com/path#XXX_I1_DT1> . \n" +
  #     "}"
  # #Xwrite_text_file_2(result, sub_dir, "to_sparql_expected.txt")
  #   item = BiomedicalConcept::Item.new
  #   item.id = "123"
  #   item.namespace = "http://www.example.com/path"
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   item.label = "test label"
  #   item.alias = "Note"
  #   item.bridg_class = "Class"
  #   item.bridg_attribute = "Attribute"
  #   parent_uri = UriV2.new({:id => "XXX", :namespace => "http://www.example.com/path"})
  #   item.to_sparql_v2(parent_uri, sparql)
  #   #expect(sparql.to_s).to eq(result)
  #   check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
  # end
  
end
  