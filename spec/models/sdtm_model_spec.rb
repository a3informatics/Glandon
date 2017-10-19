require 'rails_helper'

describe SdtmModel do

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

  it "validates a valid object" do
    item = SdtmModel.new
    ra = IsoRegistrationAuthority.new
    ra.number = "123456789"
    ra.scheme = "DUNS"
    ra.namespace = IsoNamespace.find("NS-ACME")
    item.registrationState.registrationAuthority = ra
    si = IsoScopedIdentifier.new
    si.identifier = "X FACTOR"
    item.scopedIdentifier = si
    item.ordinal = 1
    result = item.valid?
    expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#Model")
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "allows a model to be found" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    write_yaml_file(item.to_json, sub_dir, "sdtm_model_find.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a model to be found, not found error" do
    expect{SdtmModel.find("M-CDISC_SDTMMODELvvv", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all models to be found" do
    result = SdtmModel.all 
    expect(result.count).to eq(1)
    expect(result[0].identifier).to eq("SDTM MODEL")
  end
  
  it "allows all released models to be found" do
    result = SdtmModel.list
    expect(result.count).to eq(1)    
  end
  
  it "allows the model to be exported as JSON" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_model_to_json.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end

	it "allows the model to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "sdtm_model_to_json.yaml")
    item = SdtmModel.from_json(expected)
    expect(item.to_json).to eq(expected)
	end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "sdtm_model_to_json.yaml")
    item = SdtmModel.from_json(json)
    result = item.to_sparql_v2(sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_to_sparql.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_to_sparql.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL")
  end

  it "allows the item to be built and sparql created" do
  	sparql = SparqlUpdateV2.new
		json = read_yaml_file(sub_dir, "sdtm_model_json_2.yaml")
		result = SdtmModel.build_and_sparql(json, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "sdtm_model_to_sparql_2.txt")
    expected = read_text_file_2(sub_dir, "sdtm_model_to_sparql_2.txt")
    expect(sparql.to_s).to eq(expected)
	#write_yaml_file(result.to_json, sub_dir, "sdtm_model_build_sparql.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_build_sparql.yaml")
		expect(result.to_json).to eq(expected)
		expect(result.errors.full_messages.to_sentence).to eq("")
		expect(result.errors.count).to eq(0)
  end

  it "adds the datatypes" do
		json = read_yaml_file(sub_dir, "sdtm_model_json_2.yaml")
		item = SdtmModel.new
		item.add_datatypes(json[:managed_item])
		expect(item.datatypes.count).to eq(2)
		expect(item.datatypes.has_key?("Char")).to eq(true)
		expect(item.datatypes.has_key?("Num")).to eq(true)
  end

  it "adds the classifications, no sub classifications" do
		json = read_yaml_file(sub_dir, "sdtm_model_json_2.yaml")
		item = SdtmModel.new
		item.add_classifications(json[:managed_item])
		expect(item.classifications.count).to eq(2)
		expect(item.classifications.has_key?("None")).to eq(true)
		expect(item.classifications.has_key?("Identifier")).to eq(true)
  end
  
  it "adds the classifications, sub classifications present" do
		json = read_yaml_file(sub_dir, "sdtm_model_json_3.yaml")
		item = SdtmModel.new
		item.add_classifications(json[:managed_item])
		expect(item.classifications.count).to eq(6)
		expect(item.classifications.has_key?("None")).to eq(true)
		expect(item.classifications.has_key?("Identifier")).to eq(true)
		expect(item.classifications.has_key?("Qualifier")).to eq(true)
		expect(item.classifications.has_key?("Sub Class 1")).to eq(true)
		expect(item.classifications.has_key?("Sub Class 2")).to eq(true)
		expect(item.classifications.has_key?("Sub Class 3")).to eq(true)
		classification = item.classifications["Identifier"]
		expect(classification.parent).to eq(true)
		expect(classification.children.count).to eq(2)
		classification = item.classifications["Qualifier"]
		expect(classification.parent).to eq(true)
		expect(classification.children.count).to eq(1)
		classification = item.classifications["Sub Class 3"]
		expect(classification.parent).to eq(false)
		expect(classification.children.count).to eq(0)
  end

  it "updates variables" do
  	item = SdtmModel.new
  	child_1 = SdtmModel::Variable.new
  	child_2 = SdtmModel::Variable.new
  	item.children << child_1
  	item.children << child_2
  	allow_any_instance_of(SdtmModel::Variable).to receive(:update_datatype)
  	allow_any_instance_of(SdtmModel::Variable).to receive(:update_classification)
  	item.update_variables
  end

end