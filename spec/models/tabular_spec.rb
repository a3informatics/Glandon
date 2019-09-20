require 'rails_helper'

describe Tabular do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/tabular"
  end

  class TabularSubClass < Tabular

    C_CLASS_NAME = self.name
    C_SCHEMA_PREFIX = "XX"
    C_RDF_TYPE = "Model"
    C_CID_PREFIX = "M"
    C_SCHEMA_NS = "http://www.a3informatics.com/ns"
    C_IDENTIFIER = "IDENTIFIER"
    C_RDF_TYPE_URI = UriV3.new({:namespace => C_SCHEMA_NS, :fragment => C_RDF_TYPE})
    
    def children_from_triples 
    end

  end
    
  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    result = TabularSubClass.new
    result.ordinal = 1
    ra = IsoRegistrationAuthority.new
    ra.uri = "na" # Bit naughty
    ra.organization_identifier = "123456789"
    ra.international_code_designator = "DUNS"
    ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
    result.registrationState.registrationAuthority = ra
    result.scopedIdentifier.identifier = "hello"
    result.valid?
    expect(result.errors.full_messages.to_sentence).to eq("")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, ordinal" do
    result = TabularSubClass.new
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, rule"


  it "allows object to be initialized from triples" do
    triples = read_yaml_file(sub_dir, "from_triples_input.yaml")
    result = TabularSubClass.new(triples, "D-ACME_VSDomain")
    check_file_actual_expected(result.to_json, sub_dir, "from_triples_expected.yaml", equate_method: :hash_equal)
  end  

  it "allows an object to be found" do
    uri = UriV3.new(uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_VSDomain")
    tabular = TabularSubClass.find(uri.to_id)
    check_file_actual_expected(tabular.to_json, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an object to be created from JSON" do
    json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = TabularSubClass.from_json(json)
    check_file_actual_expected(item.to_json, sub_dir, "from_json_expected.yaml", equate_method: :hash_equal)
  end
  
  it "allows an object to be exported as JSON" do
    json = read_yaml_file(sub_dir, "to_json_input.yaml")
    item = TabularSubClass.from_json(json)
    item.label = "test label"
    item.ordinal = 12
    item.rule = ""
    check_file_actual_expected(item.to_json, sub_dir, "to_json_expected.yaml", equate_method: :hash_equal)
  end
  
  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    uri = UriV3.new(uri: "http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_VSDomain")
    item = TabularSubClass.find(uri.to_id)
    uri = item.to_sparql_v2(sparql, "bd")
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
    expect(uri.to_s).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_VSDomain")
  end

  it "finds all items" do
    expected = ["A", "B"]
    expect(IsoManaged).to receive(:all_by_type).with(TabularSubClass::C_RDF_TYPE, TabularSubClass::C_SCHEMA_NS).and_return(expected)
    results = TabularSubClass.all
    expect(results).to eq(expected)
  end

  it "lists all items" do
    expected = ["A", "B"]
    expect(IsoManaged).to receive(:list).with(TabularSubClass::C_RDF_TYPE, TabularSubClass::C_SCHEMA_NS).and_return(expected)
    results = TabularSubClass.list
    expect(results).to eq(expected)
  end

  it "finds the history of an item" do
    expected = ["A", "B"]
    params = {identifier: "XXXX", scope_id: "123"}
    expect(IsoManaged).to receive(:history).with(TabularSubClass::C_RDF_TYPE, TabularSubClass::C_SCHEMA_NS, params).and_return(expected)
    results = TabularSubClass.history(params)
    expect(results).to eq(expected)
  end

  it "builds an item" do
    # Tested as part of ADaM IG Dataset testing
    expect(true).to be(true)
  end
  
end
  