require 'rails_helper'

describe AdamIg do

  include DataHelpers

  def sub_dir
    return "models/adam_ig"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("adam_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "validates a valid object" do
    item = AdamIg.new
    ra = IsoRegistrationAuthority.new
    ra.number = "123456789"
    ra.scheme = "DUNS"
    ra.namespace = IsoNamespace.find("NS-ACME")
    item.registrationState.registrationAuthority = ra
    si = IsoScopedIdentifier.new
    si.identifier = "X FACTOR"
    item.scopedIdentifier = si
    result = item.valid?
    expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#ADaMImplementationGuide")
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "returns the configuration" do
    expected = {identifier: AdamIg::C_IDENTIFIER}
    expect(AdamIg.configuration).to eq(expected)
    expect(AdamIg.new.configuration).to eq(expected)    
  end

  it "returns the history" do
    expect(AdamIg.history.count).to eq(1)
  end

  it "returns the next version" do
    expect(AdamIg.next_version).to eq(2)
  end

  it "returns the child class" do
    expect(AdamIg.child_klass).to eq(::AdamIgDataset)
  end

  it "builds an object" do
    input = read_yaml_file(sub_dir, "build_input_1.yaml")
    result = AdamIg.build(input)
  #Xwrite_yaml_file(result.to_json, sub_dir, "build_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "build_expected_1.yaml")
    expect(result.to_json).to eq(expected)
  end

  it "returns the owner" do
    expected =IsoRegistrationAuthority.find_by_short_name("CDISC").to_json
    ra = AdamIg.owner
    expect(ra.to_json).to eq(expected)
  end    

  it "allows the model to be exported as JSON" do
    item = AdamIg.find(Base64.strict_encode64("http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
  #Xwrite_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

	it "allows the model to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = AdamIg.from_json(expected)
    expect(item.to_json).to eq(expected)
	end

	it "allows the object to be output as sparql" do
  	json = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = AdamIg.from_json(json)
    sparql = item.to_sparql_v2
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_1.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected_1.txt")
    expect(sparql.to_s).to eq(expected)
  end

end