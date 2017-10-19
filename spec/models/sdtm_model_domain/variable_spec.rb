require 'rails_helper'

describe SdtmModelDomain::Variable do

  include DataHelpers

  def sub_dir
    return "models/sdtm_model_domain"
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
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    item = SdtmModelDomain::Variable.new
    item.ordinal = 1
    result = item.valid?
    expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#ClassVariable")
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, name" do
    item = SdtmModelDomain::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
    {
      :extension_properties => [],
      :id => "M-CDISC_SDTMMODEL_EVENTS_xxSCAT",
      :label => "Subcategory",
      :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3",
      :ordinal => 23,
      :rule => "",
      :type => "http://www.assero.co.uk/BusinessDomain#ClassVariable"
    }
    triples = read_yaml_file(sub_dir, "variable_triples.yaml")
    expect(SdtmModelDomain::Variable.new(triples, "M-CDISC_SDTMMODEL_EVENTS_xxSCAT").to_json).to eq(result) 
  end 

  it "allows an object to be found" do
    variable = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODEL_EVENTS_xxSCAT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
    #write_yaml_file(variable.triples, sub_dir, "variable_triples.yaml")
    #write_yaml_file(variable.to_json, sub_dir, "variable.yaml")
    expected = read_yaml_file(sub_dir, "variable.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be exported as JSON" do
    variable = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODEL_EVENTS_xxSCAT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
    #write_yaml_file(variable.to_json, sub_dir, "variable_to_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows the object to be imported from JSON" do
  	json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmModelDomain::Variable.from_json(json)
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(item.to_json).to eq(expected)
	end

  it "allows the object to be output as sparql" do
  	parent_uri = UriV2.new(id: "M-CDISC_SDTMMODEL_EVENTS", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "variable.yaml")
    item = SdtmModelDomain::Variable.from_json(json)
    result = item.to_sparql_v2(parent_uri, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "variable_to_sparql.txt")
    expected = read_text_file_2(sub_dir, "variable_to_sparql.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_EVENTS_23")
  end

end
  