require 'rails_helper'

describe TermExcel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/term_excel"
  end

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", 
      "BusinessOperational.ttl", "BusinessForm.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..49)
    th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V49#TH"))
    th.has_state.make_current
  end

	before :each do
    load_schema
  end

  it "initialize object, fails to read the model file" do
    full_path = test_file_path(sub_dir, "termX.xlsx") #dodgy filename
    error_msg = "Exception raised opening Excel workbook filename=#{full_path}."
		object = TermExcel.new(full_path)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq(error_msg)		
	end

	it "initialize object, success" do
		full_path = test_file_path(sub_dir, "term_example_1.xlsx")
    object = TermExcel.new(full_path)
    expect(object.errors.full_messages.to_sentence).to eq("")    
		expect(object.errors.count).to eq(0)
	end

	it "gets term list" do
    full_path = test_file_path(sub_dir, "term_example_1.xlsx")
    object = TermExcel.new(full_path)
    result = object.list("SN")
  #write_yaml_file(result, sub_dir, "list_expected.yaml")
    expected = read_yaml_file(sub_dir, "list_expected.yaml")
		expect(result).to eq(expected)
		expect(object.errors.count).to eq(0)
	end

  it "gets terminology, SN000011" do
    full_path = test_file_path(sub_dir, "term_example_1.xlsx")
    object = TermExcel.new(full_path)
    result = object.code_list("SN000011")
    expect(object.errors.count).to eq(0)
  #write_yaml_file(result, sub_dir, "code_list_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "code_list_expected_1.yaml")
    expect(result).to eq(expected)
  end

	it "reads the excel fle, error 1" do
    full_path = test_file_path(sub_dir, "term_error_1.xlsx")
    object = TermExcel.new(full_path)
    item = object.code_list("SN000012")
    expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Harmonized_Terminology_Listing sheet in the excel file, incorrect 1st column name, indicates format error.")	
	end
   
end