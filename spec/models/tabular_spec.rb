require 'rails_helper'

describe Tabular do

  include DataHelpers

  def sub_dir
    return "models/tabular"
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
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = Tabular.new
    result.ordinal = 1
    result.registrationState.registrationAuthority.namespace.shortName = "AAA"
    result.registrationState.registrationAuthority.namespace.name = "USER AAA"
    result.registrationState.registrationAuthority.number = "123456789"
    result.scopedIdentifier.identifier = "hello"
    result.valid?
    expect(result.errors.full_messages.to_sentence).to eq("")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, ordinal" do
    result = Tabular.new
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, rule"

  it "allows object to be initialized from triples" do
    triples = read_yaml_file(sub_dir, "from_triples_input.yaml")
    result = Tabular.new(triples, "D-ACME_VSDomain")
  #write_yaml_file(result.to_json, sub_dir, "from_triples_expected.yaml")
    expected = read_yaml_file(sub_dir, "from_triples_expected.yaml")
    expect(result.to_json).to eq(expected) 
  end  

  it "allows an object to be found" do
    tabular = Tabular.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  #write_yaml_file(tabular.to_json, sub_dir, "find_expected.yaml")
    expected = read_yaml_file(sub_dir, "find_expected.yaml")
  #write_yaml_file(tabular.triples, sub_dir, "from_triples_input.yaml")
    expect(tabular.to_json).to eq(expected)
  end

  it "allows an object to be created from JSON" do
    json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = Tabular.from_json(json)
    expect(item.to_json).to eq(json)
  end
  
  it "allows an object to be exported as JSON" do
    json = read_yaml_file(sub_dir, "to_json_input.yaml")
    item = Tabular.from_json(json)
    item.label = "test label"
    item.ordinal = 12
    item.rule = ""
  #write_yaml_file(item.to_json, sub_dir, "tabular_json.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to eq(expected)
  end
  
  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    item = Tabular.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    uri = item.to_sparql_v2(sparql, "bd")
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
    expect(sparql.to_s).to eq(expected)
    expect(uri.to_s).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_VSDomain")
  end

end
  