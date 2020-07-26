require 'rails_helper'

describe Form::Item::Mapping do
  
  include DataHelpers

  def sub_dir
    return "models/form/item/mapping"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when XXTESTCD=HELLO"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when ±±TESTCD=HELLO"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Mapping contains invalid characters")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, ordinal" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when TESTCD=HELLO"
    item.ordinal = 0
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  # it "allows object to be initialized from triples" do
  #   result = 
  #     {
  #       :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
  #       :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
  #       :mapping => "XXXXX",
  #       :completion => "",
  #       :extension_properties => [],
  #       :label => "Text Label",
  #       :note => "xxxxx",
  #       :optional => false,
  #       :ordinal => 1,
  #       :type => "http://www.assero.co.uk/BusinessForm#Mapping"
  #     }
  #   triples = {}
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#Mapping" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#mapping", object: "XXXXX" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
  #   expect(Form::Item::Mapping.new(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  # end

  # it "allows an object to be found" do
  #   item = Form::Item::Mapping.find("F-ACME_T2_G1_I2","http://www.assero.co.uk/MDRForms/ACME/V1")
  # #write_hash_to_yaml_file_2(item.to_json, sub_dir, "find_expected.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "find_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows an object to be found from triples" do
  #   result = 
  #     {
  #       :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
  #       :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
  #       :mapping => "XXXXX",
  #       :completion => "",
  #       :extension_properties => [],
  #       :label => "Text Label",
  #       :note => "xxxxx",
  #       :optional => false,
  #       :ordinal => 1,
  #       :type => "http://www.assero.co.uk/BusinessForm#Mapping"
  #     }
  #   triples = {}
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#Mapping" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#mapping", object: "XXXXX" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
  #   expect(Form::Item::Mapping.find_from_triples(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)   
  # end

  # it "allows an object to be created from JSON" do
  #   input = read_yaml_file(sub_dir, "from_json_input.yaml")
  #   item = Form::Item::Mapping.from_json(input)
  #   expected = read_yaml_file(sub_dir, "from_json_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end	
  
  # it "allows an object to be exported as JSON" do
  #   item = Form::Item::Mapping.find("F-ACME_T2_G1_I2","http://www.assero.co.uk/MDRForms/ACME/V1")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "to_json_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end	

  # it "allows an object to be exported as SPARQL" do
  #   sparql = SparqlUpdateV2.new
  #   result = 
  #     "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
  #     "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
  #     "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
  #     "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
  #     "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
  #     "INSERT DATA \n" +
  #     "{ \n" + 
  #     "<http://www.example.com/path#parent_I1> rdf:type <http://www.example.com/path#rdf_test_type> . \n" +
  #     "<http://www.example.com/path#parent_I1> rdfs:label \"label\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#parent_I1> bf:ordinal \"1\"^^xsd:positiveInteger . \n" +
  #     "<http://www.example.com/path#parent_I1> bf:note \"\"^^xsd:string . \n" +
  #     "<http://www.example.com/path#parent_I1> bf:completion \"\"^^xsd:string . \n" + 
  #     "<http://www.example.com/path#parent_I1> bf:optional \"false\"^^xsd:boolean . \n" +
  #     "<http://www.example.com/path#parent_I1> bf:mapping \"XXX=YYY\"^^xsd:string . \n" +
  #     "}"
  #   item = Form::Item::Mapping.new
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   item.label = "label"
  #   item.mapping = "XXX=YYY"
  #   item.ordinal = 1
  #   item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  #   expect(sparql.to_s).to eq(result)
  # end
  
  # it "allows an object to be exported as XML" do
  # 	expect(true).to be(true) # No test required, noting in the code
  # end

end
  