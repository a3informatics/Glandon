require 'rails_helper'

describe SdtmClass::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_model_domain/variable"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm/SDTM_Model_1-4.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = SdtmClass::Variable.new
    item.ordinal = 1
    result = item.valid?
    expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#ClassVariable")
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, ordinal" do
    item = SdtmClass::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  # it "allows object to be initialized from triples" do
  #   result = 
  #   {
  #     :extension_properties => [],
  #     :id => "M-CDISC_SDTMMODEL_EVENTS_xxSCAT",
  #     :label => "Subcategory",
  #     :namespace => "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3",
  #     :ordinal => 23,
  #     :rule => "",
  #     :name => "xxSCAT",
  #     :type => "http://www.assero.co.uk/BusinessDomain#ClassVariable"
  #   }
  #   triples = read_yaml_file(sub_dir, "from_triples_expected.yaml")
  #   expect(SdtmModelDomain::Variable.new(triples, "M-CDISC_SDTMMODEL_EVENTS_xxSCAT").to_json).to eq(result) 
  # end 

  it "allows an object to be found" do
    variable = SdtmClass::Variable.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3#M-CDISC_SDTMMODELEVENTS_xxSCAT"))
  #write_yaml_file(variable.to_json, sub_dir, "find_input.yaml")
    expected = read_yaml_file(sub_dir, "find_input.yaml")
    expect(variable.to_json).to eq(expected)
  end

 #  it "allows an object to be exported as JSON" do
 #    variable = SdtmModelDomain::Variable.find("M-CDISC_SDTMMODELEVENTS_xxSCAT", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
 #  #write_yaml_file(variable.to_json, sub_dir, "to_json_expected.yaml")
 #    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
 #    expect(variable.to_json).to eq(expected)
 #  end

 #  it "allows the object to be imported from JSON" do
 #  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
 #    item = SdtmModelDomain::Variable.from_json(json)
 #  #write_yaml_file(item.to_json, sub_dir, "from_json_expected.yaml")
 #    expected = read_yaml_file(sub_dir, "from_json_expected.yaml")
 #    expect(item.to_json).to eq(expected)
	# end

 #  it "allows the object to be output as sparql" do
 #  	parent_uri = UriV2.new(id: "M-CDISC_SDTMMODEL_EVENTS", namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
 #  	sparql = SparqlUpdateV2.new
 #  	json = read_yaml_file(sub_dir, "find_input.yaml")
 #    item = SdtmModelDomain::Variable.from_json(json)
 #    result = item.to_sparql_v2(parent_uri, sparql)
 #  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
 #    #expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
 #    #expect(sparql.to_s).to eq(expected)
 #    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
 #    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL_EVENTS_xxSCAT")
 #  end

end
  