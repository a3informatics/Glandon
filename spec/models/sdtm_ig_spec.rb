require 'rails_helper'

describe SdtmIg do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_ig"
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
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a IG to be found" do
    item = SdtmIg.find("IG-CDISC_SDTMIG", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3")
  #Xwrite_yaml_file(item.to_json, sub_dir, "find_input.yaml")
    expected = read_yaml_file(sub_dir, "find_input.yaml")
    expect(item.to_json).to hash_equal(expected)
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
  #Xwrite_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to hash_equal(expected)
  end

	it "allows the model to be created from JSON" do 
		input = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = SdtmIg.from_json(input)
  #Xwrite_yaml_file(item.to_json, sub_dir, "from_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "from_json_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = SdtmIg.from_json(json)
    result = item.to_sparql_v2(sparql)
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_1.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_expected_1.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected_1.txt")
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG")
  end

 	it "allows the object domain references to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
    item = SdtmIg.from_json(json)
    result = item.domain_refs_to_sparql(sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "domain_refs_to_sparql_expected_1.txt")
    #expected = read_text_file_2(sub_dir, "domain_refs_to_sparql_expected_1.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "domain_refs_to_sparql_expected_1.txt")
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG")
  end

	it "allows the item to be built" do
		clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "build_input.yaml")
		result = SdtmIg.build(json, sparql)
	#Xwrite_yaml_file(result.to_json, sub_dir, "build_expected.yaml")
    expected = read_yaml_file(sub_dir, "build_expected.yaml")
		expect(result.to_json).to eq(expected)
		expect(result.errors.count).to eq(0)
  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_2.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected_2.txt")
  end

  it "allows for the addition of a domain" do
  	ig = SdtmIg.new
  	expect(ig.domain_refs.count).to eq(0)
  	domain_1 = SdtmIgDomain.new
  	domain_1.id = "IG-CDISC_SDTMIG_1"
  	domain_1.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
  	domain_2 = SdtmIgDomain.new
  	domain_2.id = "IG-CDISC_SDTMIG_2"
  	domain_2.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
  	ig.add_domain(domain_1)
  	expect(ig.domain_refs.count).to eq(1)
  	ig.add_domain(domain_2)
  	expect(ig.domain_refs.count).to eq(2)
  	expect(ig.domain_refs[0].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG_1")
  	expect(ig.domain_refs[1].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG_2")
  end

  it "creates a new version" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "4",
      :version_label => "2.0",
      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmIg.create(params)
		expect(result[:job]).to_not eq(nil)
		expect(result[:object].errors.count).to eq(0)
  end

  it "creates a new version, error I" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "NaN",
      :version_label => "2.0",
      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmIg.create(params)
		expect(result[:job]).to eq(nil)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")
  end

  it "creates a new version, error II" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "1",
      :version_label => "2.0",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmIg.create(params)
		expect(result[:job]).to eq(nil)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Model uri is empty")
  end

  it "creates a new version, error III" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version_label => "2.0",
      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmIg.create(params)
		expect(result[:job]).to eq(nil)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Version is empty")
  end

  it "creates a new version, error IV" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "4",
      :version_label => "2.0",
      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
      :files => ["#{filename}"]
		}
		result = SdtmIg.create(params)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Date is empty")
  end

end