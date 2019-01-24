require 'rails_helper'

describe AdamIg do

  include DataHelpers

  def sub_dir
    return "models/adam_ig"
  end

  before :each do
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
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

=begin
  def check_model(result, expected)
    expect(result[:children].count).to eq(expected[:children].count)
    result[:children].each do |r|
      item = expected[:children].find { |e| e[:id] == r[:id] }
      expect(item).to_not be_nil
      expect(r).to eq(item)
    end
  end
=end

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
    expected = []
    expect(AdamIg.history).to eq(expected)
  end

  it "returns the next version" do
    expect(AdamIg.next_version).to eq(1)
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
    item = AdamIg.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    check_model(item.to_json, expected)
  end

	it "allows the model to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = AdamIg.from_json(expected)
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    check_model(item.to_json, expected)
	end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = AdamIg.from_json(json)
    result = item.to_sparql_v2
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_1.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected_1.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL")
  end

end