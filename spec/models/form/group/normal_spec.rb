require 'rails_helper'

describe Form::Group::Normal do
  
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
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = Form::Group::Normal.new
    result.note = "OK"
    result.completion = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    result = Form::Group::Normal.new
    result.note = "OK"
    result.completion = "Draft 123>"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, note" do
    result = Form::Group::Normal.new
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
        :repeating => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#NormalGroup",
        :children => [],
        :bc_ref => {}
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
    expect(Form::Group::Normal.new(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)    
  end

  it "allows an object to be found" do
    item = Form::Group::Normal.find("F-ACME_T2_G1","http://www.assero.co.uk/MDRForms/ACME/V1")
    #write_hash_to_yaml_file_2(item.to_json, sub_dir, "normal_find.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "normal_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows an object to be created from JSON" do
    json = 
    {
      type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
      label: "Group",
      id: "",
      namespace: "",
      ordinal: 1,
      optional: false,
      repeating: false,
      note: "",
      completion: "",
      bc_ref: {},
      children: 
      [
        {
          type: "http://www.assero.co.uk/BusinessForm#CommonGroup",
          label: "Common New",
          id: "",
          namespace: "",
          ordinal: 1,
          optional: false,
          repeating: false,
          completion: "",
          note: "",
          children: []
        }
      ]
    }
    result = Form::Group::Normal.from_json(json)
    #write_hash_to_yaml_file_2(result.to_json, sub_dir, "from_json.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "from_json.yaml")
    expect(result.to_json).to eq(expected)
  end
  
  it "allows an object to be exported as JSON" do
    item = Form::Group::Normal.find("F-ACME_T2_G1","http://www.assero.co.uk/MDRForms/ACME/V1")
    result = item.to_json
    write_hash_to_yaml_file_2(result, sub_dir, "to_json.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "to_json.yaml")
    expect(result).to eq(expected)
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
      "<http://www.example.com/path#parent_G1> bf:repeating \"true\"^^xsd:boolean . \n" + 
      "}"
    item = Form::Group::Normal.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.completion = "Completion"
    item.note = "Note"
    item.repeating = "true"
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
    expect(sparql.to_s).to eq(result)
  end

  it "allows an object to be exported as XML"
  
end
  