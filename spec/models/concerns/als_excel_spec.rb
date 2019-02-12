require 'rails_helper'

describe AlsExcel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/als_excel"
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
    full_path = test_file_path(sub_dir, "alsX.xlsx") #dodgy filename
    error_msg = "Exception raised opening Excel workbook filename=#{full_path}."
		object = AlsExcel.new(full_path)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq(error_msg)		
	end

	it "initialize object, success" do
		full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = AlsExcel.new(full_path)
    expect(object.errors.full_messages.to_sentence).to eq("")    
		expect(object.errors.count).to eq(0)
	end

	it "gets form list" do
    full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = AlsExcel.new(full_path)
    result = object.list
  #write_yaml_file(result, sub_dir, "list_expected.yaml")
    expected = read_yaml_file(sub_dir, "list_expected.yaml")
		expect(result).to eq(expected)
		expect(object.errors.count).to eq(0)
	end

  it "gets form, DM example" do
    full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DM_ALL")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_1.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("AE")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_2.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, DMOG example" do
    full_path = test_file_path(sub_dir, "als_2.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DMOG")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_3.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

	it "reads the excel fle, error 1" do
    full_path = test_file_path(sub_dir, "als_error_1.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DM_ALL")
    expect(object.errors.count).to eq(2)
		expect(object.errors.full_messages.to_sentence).to eq("Forms sheet in the excel file, incorrect 1st column name, indicates format error and Failed to find the form label, possible identifier mismatch")	
	end

  it "reads the excel fle, error 2" do
    full_path = test_file_path(sub_dir, "als_error_2.xlsx")
    object = AlsExcel.new(full_path)
    item = object.list
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Forms sheet in the excel file, incorrect column count, indicates format error") 
  end

  it "reads the excel fle, error 3" do
    full_path = test_file_path(sub_dir, "als_error_3.xlsx")
    object = AlsExcel.new(full_path)
    item = object.list
    expect(object.errors.count).to eq(2)
    expect(object.errors.full_messages.to_sentence).to eq("Blank line detected before row 81, row ignored and Blank line detected before row 82, row ignored") 
  end

  it "reads the excel fle, error 4" do
    full_path = test_file_path(sub_dir, "als_error_4.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DM")
    expect(object.errors.count).to eq(2)
    expect(object.errors.full_messages.to_sentence).to eq("Blank line detected before row 1034, row ignored and Blank line detected before row 1035, row ignored") 
  end

  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "als_3.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("AE")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #Xwrite_yaml_file(result, sub_dir, "form_expected_4.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_4.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, HOSP example" do
    full_path = test_file_path(sub_dir, "als_3.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("AE")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #Xwrite_yaml_file(result, sub_dir, "form_expected_5.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_5.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end
  
  it "gets form, DM example" do
    full_path = test_file_path(sub_dir, "als_4.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DM")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #Xwrite_yaml_file(result, sub_dir, "form_expected_6.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_6.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end
  
  it "gets form, DS3 example" do
    full_path = test_file_path(sub_dir, "als_4.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("DS3")
    expect(object.errors.count).to eq(0)
    result = item.to_json
  #Xwrite_yaml_file(result, sub_dir, "form_expected_7.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_7.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end
  
  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "als_error_2.xlsx")
    object = AlsExcel.new(full_path)
    item = object.form("AE")
    expect(object.errors.count).to eq(2)
    expect(object.errors.full_messages.to_sentence).to eq("Forms sheet in the excel file, incorrect column count, indicates format error and Failed to find the form label, possible identifier mismatch") 
  end

end