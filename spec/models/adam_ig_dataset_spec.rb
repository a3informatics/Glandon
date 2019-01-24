require 'rails_helper'

describe AdamIgDataset do

  include DataHelpers

  def sub_dir
    return "models/adam_ig_dataset"
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
    item = AdamIgDataset.new
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
    expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#IgDataset")
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "builds an object" do
    input = read_yaml_file(sub_dir, "build_input_1.yaml")
    result = AdamIgDataset.build(input)
  #Xwrite_yaml_file(result.to_json, sub_dir, "build_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "build_expected_1.yaml")
    expect(result.to_json).to eq(expected)
  end

=begin
  it "allows a model to be found" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "find_input.yaml")
    expected = read_yaml_file(sub_dir, "find_input.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    #expect(item.to_json).to eq(expected)
    check_model(item.to_json, expected)
  end

  it "allows a model to be found, not found error" do
    expect{SdtmModel.find("M-CDISC_SDTMMODELvvv", "http://www.assero.co.uk/MDRSdtmModelD/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
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
  
  it "allows a list of classes and variables to be found" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    result = item.classes
  #write_yaml_file(result, sub_dir, "classes_expected.yaml")
    expected = read_yaml_file(sub_dir, "classes_expected.yaml")
    result.each do |klass, r_entry|
      e_entry = expected.find { |k,v| k == klass }
      expect(e_entry).to_not be_nil
      expect(r_entry[:uri].to_s).to eq(e_entry[1][:uri].to_s)
      r = r_entry[:children].map {|k,v| [k,v.to_s] }
      e = e_entry[1][:children].map {|k,v| [k,v.to_s] }
      expect(r).to match_array(e)
    end
  end

  it "allows the model to be exported as JSON" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    check_model(item.to_json, expected)
  end

	it "allows the model to be created from JSON" do 
		expected = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = SdtmModel.from_json(expected)
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    check_model(item.to_json, expected)
	end

	it "allows the model to be created from JSON, prevent duplicates" do 
		input = read_yaml_file(sub_dir, "from_json_input_2.yaml")
    item = SdtmModel.from_json(input)
  #write_yaml_file(item.to_json, sub_dir, "from_json_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "from_json_expected_2.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    check_model(item.to_json, expected)
	end

	it "allows the object to be output as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = SdtmModel.from_json(json)
    result = item.to_sparql_v2(sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_1.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected_1.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL")
  end

	it "allows the object to be domain references as sparql" do
  	sparql = SparqlUpdateV2.new
  	json = read_yaml_file(sub_dir, "from_json_input_1.yaml")
    item = SdtmModel.from_json(json)
    result = item.domain_refs_to_sparql(sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "class_refs_to_sparql_expected_1.txt")
    expected = read_text_file_2(sub_dir, "class_refs_to_sparql_expected_1.txt")
    expect(sparql.to_s).to eq(expected)
    expect(result.to_s).to eq("http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC_SDTMMODEL")
  end

  it "allows the item to be built" do
  	sparql = SparqlUpdateV2.new
		json = read_yaml_file(sub_dir, "build_input.yaml")
		result = SdtmModel.build(json, sparql)
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected_2.txt")
    expected = read_text_file_2(sub_dir, "to_sparql_expected_2.txt")
    expect(sparql.to_s).to eq(expected)
	#write_yaml_file(result.to_json, sub_dir, "build_expected.yaml")
    expected = read_yaml_file(sub_dir, "build_expected.yaml")
		expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expected[:class_refs].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expect(result.to_json).to eq(expected)
		expect(result.errors.full_messages.to_sentence).to eq("")
		expect(result.errors.count).to eq(0)
  end

  it "allows for the addition of a domain" do
  	ig = SdtmModel.new
  	expect(ig.class_refs.count).to eq(0)
  	domain_1 = SdtmModelDomain.new
  	domain_1.id = "IG-CDISC_SDTM_1"
  	domain_1.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
  	domain_2 = SdtmModelDomain.new
  	domain_2.id = "IG-CDISC_SDTM_2"
  	domain_2.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
  	ig.add_domain(domain_1)
  	expect(ig.class_refs.count).to eq(1)
  	ig.add_domain(domain_2)
  	expect(ig.class_refs.count).to eq(2)
  	expect(ig.class_refs[0].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTM_1")
  	expect(ig.class_refs[1].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTM_2")
  end

	it "creates a new version" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "4",
      :version_label => "2.0",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmModel.create(params)
		expect(result[:job]).to_not eq(nil)
		expect(result[:object].errors.count).to eq(0)
  end

  it "creates a new version, error I" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "1",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmModel.create(params)
		expect(result[:job]).to eq(nil)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Version label contains invalid characters")
  end

  it "creates a new version, error II" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version => "NaN",
      :version_label => "2.0",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmModel.create(params)
		expect(result[:job]).to eq(nil)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")
  end

  it "creates a new version, error III" do
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = 
    { 
      :version_label => "2.0",
      :date => "2017-10-14", 
      :files => ["#{filename}"]
		}
		result = SdtmModel.create(params)
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
      :files => ["#{filename}"]
		}
		result = SdtmModel.create(params)
		expect(result[:object].errors.count).to eq(1)
		expect(result[:object].errors.full_messages.to_sentence).to eq("Date is empty")
  end
=end

end