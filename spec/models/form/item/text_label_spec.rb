require 'rails_helper'

describe Form::Item::TextLabel do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/item/text_label"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000150_1.ttl", "ACME_VSTADIABETES_1.ttl","ACME_FN000120_1.ttl" ]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item::TextLabel.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    result.label_text = "Draft 123"
    result.ordinal = 1
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Form::Item::TextLabel.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    result.label_text = "Draft 123§"
    expect(result.valid?).to eq(false)
  end

  # it "allows object to be initialized from triples" do
  #   result = 
  #     {
  #       :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
  #       :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
  #       :label_text => "XXXXX",
  #       :completion => "",
  #       :extension_properties => [],
  #       :label => "Text Label",
  #       :note => "xxxxx",
  #       :optional => false,
  #       :ordinal => 1,
  #       :type => "http://www.assero.co.uk/BusinessForm#TextLabel"
  #     }
  #   triples = {}
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#TextLabel" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#label_text", object: "XXXXX" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
  #   expect(Form::Item::TextLabel.new(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  # end

  # it "allows an object to be found" do
  #   item = Form::Item::TextLabel.find("F-ACME_T2_G1_I3","http://www.assero.co.uk/MDRForms/ACME/V1")
  # #write_hash_to_yaml_file_2(item.to_json, sub_dir, "find_expected.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "find_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows an object to be found from triples" do
  #   result = 
  #     {
  #       :id => "F-ACME_PLACEHOLDERTEST_G1_I1", 
  #       :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
  #       :label_text => "XXXXX",
  #       :completion => "",
  #       :extension_properties => [],
  #       :label => "Text Label",
  #       :note => "xxxxx",
  #       :optional => false,
  #       :ordinal => 1,
  #       :type => "http://www.assero.co.uk/BusinessForm#TextLabel"
  #     }
  #   triples = {}
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] = []
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/BusinessForm#TextLabel" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.w3.org/2000/01/rdf-schema#label", object: "Text Label" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#note", object: "xxxxx" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#optional", object: "false" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#label_text", object: "XXXXX" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#ordinal", object: "1" }
  #   triples ["F-ACME_PLACEHOLDERTEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_PLACEHOLDERTEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#completion", object: "" }
  #   expect(Form::Item::TextLabel.find_from_triples(triples, "F-ACME_PLACEHOLDERTEST_G1_I1").to_json).to eq(result)    
  # end

  # it "allows an object to be created from JSON" do
  #   input = read_yaml_file(sub_dir, "from_json_input.yaml")
  #   item = Form::Item::TextLabel.from_json(input)
  #   expected = read_yaml_file(sub_dir, "from_json_expected.yaml")
  #   expect(item.to_json).to eq(expected)
  # end	
  
  # it "allows an object to be exported as JSON" do
  #   item = Form::Item::TextLabel.find("F-ACME_T2_G1_I3","http://www.assero.co.uk/MDRForms/ACME/V1")
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
  #     "<http://www.example.com/path#parent_I1> bf:label_text \"test label\"^^xsd:string . \n" +
  #     "}"
  #   item = Form::Item::TextLabel.new
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   item.label = "label"
  #   item.label_text = "test label"
  #   item.ordinal = 1
  #   item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  #   expect(sparql.to_s).to eq(result)
  # end
  
  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   form.add_item_group_ref("G-TEST", "1", "No", "")
  #   item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
  #   item = Form::Item::TextLabel.new
  #   item.id = "THE-ID"
  #   item.label = "Item"
  #   item.label_text = "The Label"
  #   item.ordinal = 34
		# item.to_xml(mdv, form, item_group)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end

end
  