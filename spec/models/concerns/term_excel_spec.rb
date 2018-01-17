require 'rails_helper'

describe TermExcel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/term_excel"
  end

	before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V49.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
    IsoRegistrationState.make_current(th.registrationState.id)
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