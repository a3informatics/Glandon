require 'rails_helper'

describe SdtmClass do

  include DataHelpers
  include SparqlHelpers
  
  def sub_dir
    return "models/sdtm_model_domain"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm/SDTM_Model_1-4.ttl"]
    load_files(schema_files, data_files)
  end

	it "allows a class to be found" do
    item = SdtmClass.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3#M-CDISC_SDTMMODELINTERVENTIONS"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows a class to get children (class variables)" do
    actual = []
    item = SdtmClass.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3#M-CDISC_SDTMMODELEVENTS"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

  # it "allows all domains to be found" do
  #   results = SdtmModelDomain.all 
  #   expect(results.count).to eq(7)
  # #write_yaml_file(results, sub_dir, "all_expected.yaml")
  #   expected = read_yaml_file(sub_dir, "all_expected.yaml")
  #   results.each do |result|
  #     found = expected.find { |x| x.identifier == result.identifier }
  #     expect(result.identifier).to eq(found.identifier)
  #   end
  # end
  
 #  it "allows all released domains to be found" do
 #    result = SdtmModelDomain.list
 #    expect(result.count).to eq(7)    
 #  end
  
 #  it "allows the domain class to be exported as JSON" do
 #    item = SdtmModelDomain.find("M-CDISC_SDTMMODELINTERVENTIONS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
 #    check_file_actual_expected(item.to_json, sub_dir, "to_json_expected.yaml", equate_method: :hash_equal)
 #  end

	# it "allows the domain class to be created from JSON" do 
	# 	input = read_yaml_file(sub_dir, "from_json_input.yaml")
 #    item = SdtmModelDomain.from_json(input)
 #    check_file_actual_expected(item.to_json, sub_dir, "from_json_expected.yaml", equate_method: :hash_equal)
 #  end

	# it "allows the object to be output as sparql" do
 #  	sparql = SparqlUpdateV2.new
 #  	json = read_yaml_file(sub_dir, "from_json_input.yaml")
 #    item = SdtmModelDomain.from_json(json)
 #    result = item.to_sparql_v2(sparql)
 #  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_1.txt")
 #    #expected = read_text_file_2(sub_dir, "to_sparql_expected_1.txt")
 #    #expect(sparql.to_s).to eq(expected)
 #    check_sparql_no_file(sparql.to_s, "to_sparql_expected_1.txt")
 #    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmMd/CDISC/V3#M-CDISC_SDTMMODELINTERVENTIONS")
 #  end

 #  it "allows the item to be built and sparql created" do
 #  	clear_triple_store
 #    load_schema_file_into_triple_store("ISO11179Types.ttl")
 #    load_schema_file_into_triple_store("ISO11179Identification.ttl")
 #    load_schema_file_into_triple_store("ISO11179Registration.ttl")
 #    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
 #    load_schema_file_into_triple_store("business_operational.ttl")
 #    load_schema_file_into_triple_store("BusinessDomain.ttl")
 #    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
 #    load_test_file_into_triple_store("iso_namespace_real.ttl")

 #    sparql = SparqlUpdateV2.new
	# 	results = read_yaml_file(sub_dir, "build_input.yaml")
	# 	models = results.select { |hash| hash[:type]=="MODEL" }
 #    model = SdtmModel.build(models[0][:instance], sparql)
 #  	domains = results.select { |hash| hash[:type]=="MODEL_DOMAIN" }
	# 	result = SdtmModelDomain.build(domains[0][:instance], model, sparql)
 #  #Xwrite_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_2.txt")
 #    #expected = read_text_file_2(sub_dir, "to_sparql_expected_2.txt")
 #    #expect(sparql.to_s).to eq(expected)
 #    check_sparql_no_file(sparql.to_s, "to_sparql_expected_2.txt")
 #    check_file_actual_expected(result.to_json, sub_dir, "build_expected.yaml", equate_method: :hash_equal)
	# 	expect(result.errors.count).to eq(0)
 #  end

end