require 'rails_helper'

describe Form::Item::Question do
  
  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/item/question"
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
    item = Form::Item::Question.new
    item.datatype = "string"
    item.format = "20"
    item.question_text = "Hello"
    item.ordinal = 1
    item.tc_refs = []
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, question label" do
    result = Form::Item::Question.new
    result.datatype = "S"
    result.format = "20"
    result.question_text = "Hello|"
    result.ordinal = 1
    result.tc_refs = []
    expect(result.valid?).to eq(false)
    expect(result.errors.full_messages.to_sentence).to eq("Datatype contains an invalid datatype")
  end

  it "does not validate an invalid object, format" do
    result = Form::Item::Question.new
    result.datatype = "S"
    result.format = "3#"
    result.question_text = "Hello|"
    result.ordinal = 1
    result.tc_refs = []
    expect(result.valid?).to eq(false)
    expect(result.errors.full_messages.to_sentence).to eq("Format contains invalid characters")
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :question_text => "Hello world",
        :format => "2.3",
        :datatype => "float",
        :mapping => "SDTM=XXX",
        :completion => "",
        :extension_properties => [],
        :label => "Question",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#Question",
        :children => []
      }
    triples = {}
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#format", object: "2.3" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#datatype", object: "float" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#question_text", object: "Hello world" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#mapping", object: "SDTM=XXX" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
    expect(Form::Item::Question.new(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  end

  it "allows object to be initialized from triples - old datatype" do
    result = 
      {
        :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :question_text => "Hello world",
        :format => "2.3",
        :datatype => "integer",
        :mapping => "SDTM=XXX",
        :completion => "",
        :extension_properties => [],
        :label => "Question",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#Question",
        :children => []
      }
    triples = {}
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#mapping", object: "SDTM=XXX" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#format", object: "2.3" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#datatype", object: "I" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#question_text", object: "Hello world" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
    expect(Form::Item::Question.new(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  end

  it "allows an object to be found" do
    item = Form::Item::Question.find("F-ACME_T2_G1_I4","http://www.assero.co.uk/MDRForms/ACME/V1")
  #write_hash_to_yaml_file_2(item.to_json, sub_dir, "find_expected.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "find_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows an object to be found from triples" do
    result = 
      {
        :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :question_text => "Hello world",
        :format => "2.3",
        :datatype => "integer",
        :mapping => "SDTM=XXX",
        :completion => "",
        :extension_properties => [],
        :label => "Question",
        :note => "xxxxx",
        :optional => false,
        :ordinal => 1,
        :type => "http://www.assero.co.uk/BusinessForm#Question",
        :children => []
      }
    triples = {}
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Question" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#mapping", object: "SDTM=XXX" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#format", object: "2.3" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#datatype", object: "I" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#question_text", object: "Hello world" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
    triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
    expect(Form::Item::Question.find_from_triples(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  end

  it "allows an object to be created from JSON" do
    json = 
    {
      type: "http://www.assero.co.uk/BusinessForm#Question",
      id: "F-ACME_T10_G1_I1",
      namespace: "http://www.assero.co.uk/MDRForms/ACME/V1",
      label: "Question 1",
      extension_properties: nil,
      ordinal: 1,
      note: "",
      completion: "",
      optional: false,
      datatype: "CL",
      format: "",
      question_text: "TEST",
      mapping: "",
      children: [
        {
          type: "http://www.assero.co.uk/BusinessOperational#TcReference",
          label: "Mile Per Hour",
          id: "",
          namespace: "",
          ordinal: 1,
          local_label: "Mile Per Hour",
          enabled: true,
          optional: false,
          subject_ref: {
            id: "CLI-C71620_C105500",
            namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
          },
          subject_data: {
            identifier: "C105500",
            notation: "mph"
          }
        }
      ]
    }
    result = Form::Item::Question.from_json(json)
  #write_hash_to_yaml_file_2(result.to_json, sub_dir, "from_json_expected.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "from_json_expected.yaml")
    expect(result.to_json).to eq(expected)
    sparql = SparqlUpdateV2.new
    result.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  end
  
  it "allows an object to be exported as JSON" do
    item = Form::Item::Question.find("F-ACME_T2_G1_I4","http://www.assero.co.uk/MDRForms/ACME/V1")
  #write_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to eq(expected)
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
      "<http://www.example.com/path#parent_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
      "<http://www.example.com/path#parent_I1> rdfs:label \"label\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_I1> bf:ordinal \"1\"^^xsd:positiveInteger . \n" +
      "<http://www.example.com/path#parent_I1> bf:note \"\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_I1> bf:completion \"\"^^xsd:string . \n" + 
      "<http://www.example.com/path#parent_I1> bf:optional \"false\"^^xsd:boolean . \n" +
      "<http://www.example.com/path#parent_I1> bf:datatype \"string\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_I1> bf:format \"5\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_I1> bf:question_text \"****free****\"^^xsd:string . \n" +
      "<http://www.example.com/path#parent_I1> bf:mapping \"X=Y\"^^xsd:string . \n" +
      "}"
  #Xwrite_text_file_2(result, sub_dir, "to_sparql_expected_1.txt")
    item = Form::Item::Question.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.question_text = "****free****"
    item.format = "5"
    item.datatype = "string"
    item.mapping = "X=Y"
    item.ordinal = 1
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
    #expect(sparql.to_s).to eq(result)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected_1.txt")
  end
  
  it "allows an object to be exported as SPARQL, with child" do
    json = 
    {
      type: "http://www.assero.co.uk/BusinessForm#Question",
      id: "F-ACME_T10_G1_I1",
      namespace: "http://www.assero.co.uk/MDRForms/ACME/V1",
      label: "Question 1",
      extension_properties: nil,
      ordinal: 1,
      note: "",
      completion: "",
      optional: false,
      datatype: "CL",
      format: "",
      question_text: "TEST",
      mapping: "",
      children: [
        {
          type: "http://www.assero.co.uk/BusinessOperational#TcReference",
          label: "Mile Per Hour",
          id: "",
          namespace: "",
          ordinal: 1,
          local_label: "Mile Per Hour",
          enabled: true,
          optional: false,
          subject_ref: {
            id: "CLI-C71620_C105500",
            namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
          },
          subject_data: {
            identifier: "C105500",
            notation: "mph"
          }
        }
      ]
    }
    result = Form::Item::Question.from_json(json)
    sparql = SparqlUpdateV2.new
    result.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_2.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected_2.txt")
  end

  it "allows an object to be exported as XML" do
  	odm = add_root
    study = add_study(odm.root)
    mdv = add_mdv(study)
    form = add_form(mdv)
    form.add_item_group_ref("G-TEST", "1", "No", "")
    item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
    item = Form::Item::Question.new
    item.id = "THE-ID"
    item.label = "A label for the name attribute"
    item.datatype = "string"
    item.format = "20"
    item.question_text = "Hello"
    item.ordinal = 45
    item.tc_refs = []
		item.to_xml(mdv, form, item_group)
		xml = odm.to_xml
  #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
    expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
    odm_fix_datetimes(xml, expected)
    odm_fix_system_version(xml, expected)
    expect(xml).to eq(expected)
  end

end
  