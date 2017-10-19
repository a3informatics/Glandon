require 'rails_helper'

describe SdtmIg do

  include DataHelpers

  def sub_dir
    return "models"
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
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a IG to be found" do
    item = SdtmIg.find("IG-CDISC_SDTMIG", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3")
    #write_yaml_file(item.to_json, sub_dir, "sdtm_ig_find.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a IG to be found, not found error" do
    expect{SdtmIg.find("IG-CDISC_SDTMIGvv", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all IGs to be found" do
    result = SdtmIg.all 
    expect(result.count).to eq(1)
    expect(result[0].identifier).to eq("SDTM IG")
  end
  
  it "allows the IG history to be found" do
    result = SdtmIg.history
    expect(result.count).to eq(1)    
  end
  
  it "allows the model to be exported as JSON" do
    item = SdtmIg.find("IG-CDISC_SDTMIG", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_ig_to_json.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end

	it "allows the model to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "sdtm_ig_to_json.yaml")
    item = SdtmIg.from_json(expected)
    expect(item.to_json).to eq(expected)
	end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "sdtm_ig_to_json.yaml")
    item = SdtmIg.from_json(json)
    result = item.to_sparql_v2(sparql)
  write_text_file_2(sparql.to_s, sub_dir, "sdtm_ig_to_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_ig_to_sparql.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG")
  end

  it "allows the item to be built" do
  	sparql = SparqlUpdateV2.new
		json = read_yaml_file(sub_dir, "sdtm_ig_json_2.yaml")
		result = SdtmIg.build(json, sparql)
	write_yaml_file(result.to_json, sub_dir, "sdtm_ig_build.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_build.yaml")
		expect(result.to_json).to eq(expected)
		expect(result.errors.count).to eq(0)
  end

  it "adds the compliance" do
		json = read_yaml_file(sub_dir, "sdtm_ig_json_2.yaml")
		item = SdtmIg.new
		item.add_compliance(json[:managed_item])
		expect(item.complaince.count).to eq(3)
		expect(item.compliance.has_key?("Required")).to eq(true)
		expect(item.compliance.has_key?("Expected")).to eq(true)
		expect(item.compliance.has_key?("Permissible")).to eq(true)
  end

end