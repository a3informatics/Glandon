require 'rails_helper'

describe SdtmIgDomain do

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

  it "allows a domain to be found" do
    item = SdtmIgDomain.find("IG-CDISC_SDTMIGPR", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_ig_domain_find.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_domain_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a domain to be found, not found error" do
    expect{SdtmIgDomain.find("IG-CDISC_SDTMIGPRx", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all domains to be found" do
    results = SdtmIgDomain.all
  #write_yaml_file(results, sub_dir, "sdtm_ig_domain_all.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_domain_all.yaml")
    expect(results.count).to eq(41)
    results.each do |result|
      found = expected.find { |x| x.identifier == result.identifier }
      expect(result.identifier).to eq(found.identifier)
    end
  end
  
  it "allows all released domains to be found" do
    result = SdtmIgDomain.list
    expect(result.count).to eq(41)    
  end
  
  it "allows compliances for the domain to be found" do
    item = SdtmIgDomain.find("IG-CDISC_SDTMIGPR", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    result = item.compliance
    expect(result.count).to eq(3) 
    expect(result[0].label).to eq("Permissible") 
    expect(result[1].label).to eq("Expected") 
    expect(result[2].label).to eq("Required") 
  end
  
  it "allows the domain to be exported as JSON" do
    item = SdtmIgDomain.find("IG-CDISC_SDTMIGPR", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_ig_domain_to_json.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_ig_domain_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end

  	it "allows the domain class to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "sdtm_ig_domain_to_json.yaml")
    item = SdtmIgDomain.from_json(expected)
    expect(item.to_json).to eq(expected)
	end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "sdtm_ig_domain_to_json.yaml")
    item = SdtmIgDomain.from_json(json)
    result = item.to_sparql_v2(sparql)
  write_text_file_2(sparql.to_s, sub_dir, "sdtm_ig_domain_to_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_ig_domain_to_sparql.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3#IG-CDISC_SDTMIGPR")
  end

  it "allows the item to be built" do
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
    sparql = SparqlUpdateV2.new
		results = read_yaml_file(sub_dir, "sdtm_ig_domain_import.yaml")
		models = results.select { |hash| hash[:type]=="MODEL" }
    model = SdtmModel.build_and_sparql(models[0][:instance], sparql)
  	domains = results.select { |hash| hash[:type]=="MODEL_DOMAIN" }
		result = SdtmIgDomain.build_and_sparql(domains[0][:instance], sparql, model)
  #write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_domain_to_sparql_2.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_domain_to_sparql_2.txt")
    expect(sparql.to_s).to eq(expected)
	#write_yaml_file(result.to_json, sub_dir, "sdtm_model_domain_build_sparql.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_domain_build_sparql.yaml")
		expect(result.to_json).to eq(expected)
		expect(result.errors.count).to eq(0)
  end

end