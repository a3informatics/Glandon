require 'rails_helper'

describe SdtmUserDomain::Variable do

  include DataHelpers

  def sub_dir
    return "models/sdtm_user_domain"
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
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = SdtmUserDomain::Variable.new
    result.name = "AB123456"
    result.ordinal = 1
    valid = result.valid?
    puts result.errors.full_messages.to_sentence
    expect(valid).to eq(true)
  end

  it "does not validate an invalid object, name" do
    result = SdtmUserDomain::Variable.new
    result.ordinal = 1
    valid = result.valid?   
    expect(result.errors.full_messages.to_sentence).to eq("Name contains invalid characters, is empty or is too long")
    expect(result.errors.count).to eq(1)
    expect(valid).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "D-ACME_VSDomain_V5", 
        :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :extension_properties => [],
        :label => "Group ID",
        :ordinal => 5,
        :property_refs => [],
        :rule => "",
        :type => "http://www.assero.co.uk/BusinessDomain#UserVariable",
        :name => "VSGRPID",
        :used => true,
        :non_standard => false,
        :length => 0,
        :key_ordinal => 0,
        :format => "",
        :ct => "",
        :notes => "",
        :comment => "",
        :classification => "null",
        :sub_classification => {},
        :compliance => "null",
        :datatype => "null",
        :variable_ref => {}
      }
    triples = read_yaml_file(sub_dir, "variable_triples.yaml")
    expect(SdtmUserDomain::Variable.new(triples, "D-ACME_VSDomain_V5").to_json).to eq(result) 
  end 

  it "allows object to be initialized from triples" do
    result = 
      {
        :id => "D-ACME_VSDomain_V9", 
        :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :extension_properties => [],
        :label => "Category for Vital Signs",
        :ordinal => 9,
        :property_refs => [],
        :rule => "",
        :type => "http://www.assero.co.uk/BusinessDomain#UserVariable",
        :name => "VSCAT",
        :used => true,
        :non_standard => false,
        :length => 0,
        :key_ordinal => 0,
        :format => "",
        :ct => "",
        :notes => "",
        :comment => "",
        :classification => "null",
        :sub_classification => {},
        :compliance => "null",
        :datatype => "null",
        :variable_ref => {}
      }
    triples = read_yaml_file(sub_dir, "variable_triples_2.yaml")
    expect(SdtmUserDomain::Variable.new(triples, "D-ACME_VSDomain_V9").to_json).to eq(result) 
  end 

  it "allows an object to be found" do
    variable = SdtmUserDomain::Variable.find("D-ACME_VSDomain_V5", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  #write_yaml_file(variable.triples, sub_dir, "variable_triples.yaml")
  #write_yaml_file(variable.to_json, sub_dir, "variable.yaml")
    expected = read_yaml_file(sub_dir, "variable.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be found, classification and sub-classifcation" do
    variable = SdtmUserDomain::Variable.find("D-ACME_VSDomain_V9", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    #write_yaml_file(variable.triples, sub_dir, "variable_triples_2.yaml")
  #write_yaml_file(variable.to_json, sub_dir, "variable_2.yaml")
    expected = read_yaml_file(sub_dir, "variable_2.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be created from JSON" do
    json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmUserDomain::Variable.from_json(json)
  #write_yaml_file(item.to_json, sub_dir, "variable_from_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_from_json.yaml")
    expect(item.to_json).to eq(expected)
  end
  
  it "allows an object to be created from JSON, comment" do
    json = read_yaml_file(sub_dir, "variable.yaml")
    json[:comment] = "NEW NEW NEW"
    item = SdtmUserDomain::Variable.from_json(json)
  #write_yaml_file(item.to_json, sub_dir, "variable_from_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_from_json.yaml")
    expected[:comment] = "NEW NEW NEW"
    expect(item.to_json).to eq(expected)
  end
  
  it "allows an object to be exported as JSON" do
    json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmUserDomain::Variable.from_json(json)
  #write_yaml_file(item.to_json, sub_dir, "variable_to_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end
  
  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    item = SdtmUserDomain::Variable.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.name = "XXXXX"
    item.notes = "Notes"
    item.format = "ISO 8601"
    item.ct = ""
    item.non_standard = true
    item.comment = "Comment"
    item.length = "20"
    item.used = true
    item.key_ordinal = 1
    item.datatype = SdtmModelDatatype.new
    item.datatype.id = "datatype"
    item.datatype.namespace = "http://www.example.com/path"
    item.compliance = EnumeratedLabel.new
    item.compliance.id = "compliance"
    item.compliance.namespace = "http://www.example.com/path"
    item.classification = EnumeratedLabel.new
    item.classification.id = "classification"
    item.classification.namespace = "http://www.example.com/path"
    item.sub_classification = EnumeratedLabel.new
    item.sub_classification.id = "subClassification"
    item.sub_classification.namespace = "http://www.example.com/path"
    item.variable_ref = OperationalReferenceV2.new
    item.variable_ref.subject_ref = UriV2.new({:id => "variableReference", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sparql.txt")
    expected = read_text_file_2(sub_dir, "sparql.txt")
    expect(sparql.to_s).to eq(expected)
  end

  it "allows object to be initialized from triples, PR" do
    result = 
      {
        :id => "D-ACME_VSDomain_V5", 
        :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :extension_properties => [],
        :label => "Group ID",
        :ordinal => 5,
        :property_refs => [],
        :rule => "",
        :type => "http://www.assero.co.uk/BusinessDomain#UserVariable",
        :name => "VSGRPID",
        :used => true,
        :non_standard => false,
        :length => 0,
        :key_ordinal => 0,
        :format => "",
        :ct => "",
        :notes => "",
        :comment => "",
        :classification => "null",
        :sub_classification => {},
        :compliance => "null",
        :datatype => "null",
        :variable_ref => {}
      }
    triples = read_yaml_file(sub_dir, "variable_triples_3.yaml")
    expect(SdtmUserDomain::Variable.new(triples, "D-ACME_VSDomain_V5").to_json).to eq(result) 
  end

  it "allows an object to be exported as SPARQL, PR" do
    sparql = SparqlUpdateV2.new
    item = SdtmUserDomain::Variable.new
    item.rdf_type = "http://www.example.com/path#rdf_test_type"
    item.label = "test label"
    item.name = "XXXXX"
    item.notes = "Notes"
    item.format = "ISO 8601"
    item.ct = ""
    item.non_standard = true
    item.comment = "Comment"
    item.length = "20"
    item.used = true
    item.key_ordinal = 1
    item.datatype = SdtmModelDatatype.new
    item.datatype.id = "datatype"
    item.datatype.namespace = "http://www.example.com/path"
    item.compliance = EnumeratedLabel.new
    item.compliance.id = "compliance"
    item.compliance.namespace = "http://www.example.com/path"
    item.classification = EnumeratedLabel.new
    item.classification.id = "classification"
    item.classification.namespace = "http://www.example.com/path"
    item.sub_classification = EnumeratedLabel.new
    item.sub_classification.id = "subClassification"
    item.sub_classification.namespace = "http://www.example.com/path"
    item.variable_ref = OperationalReferenceV2.new
    item.variable_ref.subject_ref = UriV2.new({:id => "variableReference", :namespace => "http://www.example.com/path"})
    item.property_refs << OperationalReferenceV2.new
    item.property_refs[0].subject_ref = UriV2.new({:id => "propertyReference1", :namespace => "http://www.example.com/path"})
    item.property_refs << OperationalReferenceV2.new
    item.property_refs[1].subject_ref = UriV2.new({:id => "propertyReference2", :namespace => "http://www.example.com/path"})
    item.to_sparql_v2(UriV2.new({:id => "parent", :namespace => "http://www.example.com/path"}), sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sparql_2.txt")
    expected = read_text_file_2(sub_dir, "sparql_2.txt")
    expect(sparql.to_s).to eq(expected)
  end

  it "allows an object to be found, PR" do
    variable = SdtmUserDomain::Variable.find("D-ACME_VSDomain_V7", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  write_yaml_file(variable.to_json, sub_dir, "variable_3.yaml")
    expected = read_yaml_file(sub_dir, "variable_3.yaml")
    expect(variable.to_json).to eq(expected)
  end

  

end
  