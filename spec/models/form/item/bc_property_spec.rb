require 'rails_helper'

describe Form::Item::BcProperty do

  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/item"
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
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = Form::Item::BcProperty.new
    result.ordinal = 1
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, ordinal" do
    item = Form::Item::BcProperty.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
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
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasProperty", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_PR0>" }
    triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasThesaurusConcept", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_TCR0>" }
    expect(Form::Item::BcProperty.new(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)    
  end

  it "allows the item to be found" do
    item = Form::Item::BcProperty.find("F-ACME_VSBASELINE1_G1_G2_I1","http://www.assero.co.uk/MDRForms/ACME/V1")
  #write_hash_to_yaml_file_2(item.to_json, sub_dir, "bc_property_find.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "bc_property_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows the BC Property to be found" do
    item = Form::Item::BcProperty.find("F-ACME_VSBASELINE1_G1_G2_I1","http://www.assero.co.uk/MDRForms/ACME/V1")
    result = item.bc_property
  #write_hash_to_yaml_file_2(result.to_json, sub_dir, "bc_property_property.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "bc_property_property.yaml")
    expect(result.to_json).to eq(expected)
  end

  it "allows Thesaurus Concepts to be found" do
    item = Form::Item::BcProperty.find("F-ACME_VSBASELINE1_G1_G2_I3","http://www.assero.co.uk/MDRForms/ACME/V1")
    result = item.thesaurus_concepts
    json = []
    result.each {|tc| json << tc.to_json}
  #write_hash_to_yaml_file_2(json, sub_dir, "bc_property_tcs.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "bc_property_tcs.yaml")
    expect(json).to eq(expected)
  end 

  it "allows an object to be found from triples" #do
=begin
    # Test works but does not include the operation references in the triples. Needs to be better. Commented out so test is pending.
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
    #triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasProperty", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_PR0>" }
    #triples ["F-ACME_TEST_G1_I1"] << { subject: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST_G1_I1", predicate: "http://www.assero.co.uk/BusinessForm#hasThesaurusConcept", object: "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_I1_TCR0>" }
    expect(Form::Item::BcProperty.find_from_triples(triples, "F-ACME_TEST_G1_I1").to_json).to eq(result)
  end
=end

  it "allows an object to be created from JSON"
  
  it "allows an object to be exported as JSON" do
    expected = 
    {
      :children => [],
      :completion => "",
      :extension_properties => [],
      :id => "",
      :is_common => true,
      :label => "label",
      :namespace => "",
      :note => "Hello!",
      :optional => false,
      :ordinal => 1,
      :property_ref => 
      {
        :type => "http://www.assero.co.uk/BusinessOperational#Reference", 
        :id  => "", 
        :namespace  => "", 
        :label => "", 
        :extension_properties=>[], 
        :enabled=>true, 
        :optional=>false, 
        :ordinal=>0, 
        :local_label => "", 
        :subject_ref=>
        {
          :namespace=>"http://www.example.com/path", 
          :id=>"test"
        }
      },
      :type => "http://www.example.com/path#rdf_test_type"
    }
    item = Form::Item::BcProperty.new
    item.property_ref = OperationalReferenceV2.new
    item.property_ref.subject_ref = UriV2.new({:id => "test", :namespace => "http://www.example.com/path"})
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.note = "Hello!"
    item.ordinal = 1
    item.is_common = true
    expect(item.to_json).to eq(expected)
  end

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
    item.ordinal = 1
    item.to_sparql_v2(UriV2.new({:id => "XXXX", :namespace => "http://www.example.com/path"}), sparql)
    expect(sparql.to_s).to eq(result)
  end
  
  it "allows an object to be exported as XML" do
  	odm = add_root
    study = add_study(odm.root)
    mdv = add_mdv(study)
    form = add_form(mdv)
    form.add_item_group_ref("G-TEST", "1", "No", "")
    item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
    item = Form::Item::BcProperty.new
    item.id = "THE-ID"
    item.label = "A label for the name attribute"
    item.property_ref = OperationalReferenceV2.new
    item.property_ref.subject_ref = UriV2.new({:id => "BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", 
    	:namespace => "http://www.assero.co.uk/MDRBCs/V1"})
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "label"
    item.note = "Hello!"
    item.ordinal = 1
    item.is_common = false
    tc_ref = OperationalReferenceV2.new
    tc_ref.ordinal = 1
    tc_ref.subject_ref = UriV2.new({:id => "CLI-C66770_C49668", 
    	:namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"})
    item.children << tc_ref
 		item.to_xml(mdv, form, item_group)
		xml = odm.to_xml
  #write_text_file_2(xml, sub_dir, "bc_property_to_xml_1.xml")
    expected = read_text_file_2(sub_dir, "bc_property_to_xml_1.xml")
    odm_fix_datetimes(xml, expected)
    odm_fix_system_version(xml, expected)
    expect(xml).to eq(expected)
  end

end
  