require 'rails_helper'

describe SdtmIgDomain::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_ig_domain/variable"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
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
    item = SdtmIgDomain::Variable.new
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, name" do
    item = SdtmIgDomain::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  it "returns the compliance label" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    expect(variable.compliance_label).to eq("Required")
  end

  it "returns blank compliance label if none present" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    variable.compliance = nil
    expect(variable.compliance_label).to eq("")
  end

  it "allows object to be initialized from triples" do
    result = 
    {
      :extension_properties => [],
      :id => "IG-CDISC_SDTMIGRP_RPTEST",
      :label => "Reproductive System Findings Test Name",
      :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3",
      :ordinal => 9,
      :rule => "",
      :name => "RPTEST",
      :type => "http://www.assero.co.uk/BusinessDomain#IgVariable",
      :controlled_term_or_format => "(RPTEST)",
      :notes => "Verbatim name of the test or examination used to obtain the measurement or finding. " +
        "The value in RPTEST cannot be longer than 40 characters. Examples: Number of Live Births, Number " +
        "of Pregnancies, Birth Control Method, etc.",
      :compliance => "null"
    }
    triples = read_yaml_file(sub_dir, "from_triples_input.yaml")
    expect(SdtmIgDomain::Variable.new(triples, "IG-CDISC_SDTMIGRP_RPTEST").to_json).to eq(result) 
  end 

  it "allows an object to be found" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  write_yaml_file(variable.to_json, sub_dir, "find_expected.yaml")
    expected = read_yaml_file(sub_dir, "find_expected.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be exported as JSON" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  #write_yaml_file(variable.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows the object to be imported from JSON" do
  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = SdtmIgDomain::Variable.from_json(json)
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to eq(expected)
	end

  it "allows the object to be output as sparql" do
  	parent_uri = UriV2.new(id: "M-CDISC_SDTMMODEL_EVENTS", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = SdtmIgDomain::Variable.from_json(json)
    result = item.to_sparql_v2(parent_uri, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_EVENTS_RPTEST")
  end

  it "allows the compliance reference to be updated" do
  	variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  	compliance_1 = SdtmModelCompliance.new
  	compliance_1.id = "EXP_NEW"
  	compliance_1.label = "Expected"
  	compliance_2 = SdtmModelCompliance.new
  	compliance_2.id = "REQ_NEW"
  	compliance_2.label = "Required"
  	compliance_3 = SdtmModelCompliance.new
  	compliance_3.id = "PERM_NEW"
  	compliance_3.label = "Permissible"
  	compliances = {}
  	compliances["Expected"] = compliance_1
  	compliances["Required"] = compliance_2
  	compliances["Permissible"] = compliance_3
  	variable.update_compliance(compliances)
  	expect(variable.compliance.id).to eq("REQ_NEW")
  end

  it "allows the compliance reference to be updated, exception" do
  	variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  	compliance_1 = SdtmModelCompliance.new
  	compliance_1.id = "EXP_NEW"
  	compliance_1.label = "Expected"
  	compliance_2 = SdtmModelCompliance.new
  	compliance_2.id = "REQ_NEW"
  	compliance_2.label = "Required"
  	compliance_3 = SdtmModelCompliance.new
  	compliance_3.id = "PERM_NEW"
  	compliance_3.label = "Permissible"
  	compliances = {}
  	compliances["Expected1"] = compliance_1
  	compliances["Required2"] = compliance_2
  	compliances["Permissible3"] = compliance_3
  	expect{variable.update_compliance(compliances)}.to raise_error(Exceptions::ApplicationLogicError)
  end

end
  