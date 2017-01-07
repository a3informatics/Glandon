require 'rails_helper'

describe SdtmIgDomain::Variable do

  include DataHelpers

  def sub_dir
    return "models/sdtm_ig_domain"
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
    triples = read_yaml_file(sub_dir, "variable_triples.yaml")
    expect(SdtmIgDomain::Variable.new(triples, "IG-CDISC_SDTMIGRP_RPTEST").to_json).to eq(result) 
  end 

  it "allows an object to be found" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    write_yaml_file(variable.triples, sub_dir, "variable_triples.yaml")
    write_yaml_file(variable.to_json, sub_dir, "variable.yaml")
    expected = read_yaml_file(sub_dir, "variable.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows an object to be exported as JSON" do
    variable = SdtmIgDomain::Variable.find("IG-CDISC_SDTMIGRP_RPTEST", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    write_yaml_file(variable.to_json, sub_dir, "variable_to_json.yaml")
    expected = read_yaml_file(sub_dir, "variable_to_json.yaml")
    expect(variable.to_json).to eq(expected)
  end

  it "allows the object to be imported"

end
  