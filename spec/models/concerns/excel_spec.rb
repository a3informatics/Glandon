require 'rails_helper'

describe Excel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel"
  end

  class TestMi < IsoManaged
  end

	before :each do
    clear_triple_store
  end

  it "initialize object, fails to read the excel file" do
    full_path = test_file_path(sub_dir, "missing.xlsx") #dodgy filename
    error_msg = "Exception raised opening Excel workbook filename=#{full_path}."
    object = Excel.new(full_path)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq(error_msg)  
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "new_input_1.xlsx")
    object = Excel.new(full_path)
    expect(object.errors.count).to eq(0)
  end

  it "checks a row, with array, no errors" do
    full_path = test_file_path(sub_dir, "check_rows_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_row(2, [false, true, false, true])
    expect(result).to eq(["1", "1", "A", "Y"])
    expect(object.errors.count).to eq(0)
  end

  it "checks a row, with array, errors" do
    full_path = test_file_path(sub_dir, "check_rows_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_row(3, [false, true, false, true])
    expect(result).to eq(["2", "2", "", ""])
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 3, column 2.")    
  end

  it "checks a row, no array, no errors" do
    full_path = test_file_path(sub_dir, "check_rows_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_row(4, nil)
    expect(result).to eq(["3", "C", "C", "Y"])
    expect(object.errors.count).to eq(0)
  end

  it "checks a row, no array, errors" do
    full_path = test_file_path(sub_dir, "check_rows_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_row(5, nil)
    expect(result).to eq(["4", "4", "", ""])
    expect(object.errors.count).to eq(2)
    expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 5, column 2. and Empty cell detected in row 5, column 3.")    
  end

  it "checks a cell, empty, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_value(4, 2, true)
    expect(result).to eq("")
    expect(object.errors.count).to eq(0)
  end

  it "checks a cell, empty, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_value(4, 2, false)
    expect(result).to eq("")
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 4, column 2.")    
  end

  it "checks a cell, full, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_value(4, 1, true)
    expect(result).to eq("3")
    expect(object.errors.count).to eq(0)
  end

  it "checks a cell, full, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_value(4, 1, false)
    expect(result).to eq("3")
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, success" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN"]})
    expect(result).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, error length, more" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN", "EXTRA"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error length, less" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error mismatch" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({label: "First", columns: ["NOT EMPTYXXX", "CAN BE EMPTY", "THIRD COLUMN"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect 1st column name, indicates format error.")    
  end

  it "returns a filled operation hash" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    mi = TestMi.new
    result = object.operation_hash(mi, {label: "xxx", identifier: "IDENT", semantic_version: "6.2.1", version_label: "some label", version: "1", 
      date: "2018-01-01", ordinal: 4})
  #Xwrite_hash_to_yaml_file_2(result, sub_dir, "operation_hash_expected.yaml")
    expected = read_yaml_file_to_hash_2(sub_dir, "operation_hash_expected.yaml")
    expected[:managed_item][:last_changed_date] = result[:managed_item][:last_changed_date]
    expect(result).to eq(expected)
  end

  it "returns the compliance" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.core_classification(2, 1, {A: "This is A", B: "This is B", C: "This is C"})
    expect(result).to be_a(SdtmModelCompliance)
    expect(result.label).to eq("This is A")
    expect(object.errors.any?).to eq(false)
    result = object.core_classification(4, 1, {A: "This is A", B: "This is B", C: "This is C"})
    expect(result).to be_a(SdtmModelCompliance)
    expect(result.label).to eq("This is C")
    expect(object.errors.any?).to eq(false)
    result = object.core_classification(5, 1, {A: "This is A", B: "This is B", C: "This is C"})
    expect(result).to be_nil
    expect(object.errors.any?).to eq(true)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Mapping error. 'ERROR' detected in row 5 column: 1.")
  end

  it "returns the datatype" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.datatype_classification(2, 2, {X: "This is X", Y: "This is Y"})
    expect(result).to be_a(SdtmModelDatatype)
    expect(result.label).to eq("This is X")
    expect(object.errors.any?).to eq(false)
    result = object.datatype_classification(3, 2, {X: "This is X", Y: "This is Y"})
    expect(result).to be_a(SdtmModelDatatype)
    expect(result.label).to eq("This is Y")
    expect(object.errors.any?).to eq(false)
    result = object.datatype_classification(4, 2, {X: "This is X", Y: "This is Y"})
    expect(result).to be_nil
    expect(object.errors.any?).to eq(true)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Mapping error. 'NONE' detected in row 4 column: 2.")
  end

  it "returns the CT Reference" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    expect(object.ct_reference(2, 3,)).to eq("X1X")
    expect(object.ct_reference(3, 3,)).to eq("")
    expect(object.ct_reference(4, 3,)).to eq("")
    expect(object.ct_reference(5, 3,)).to eq("")
  end

  it "returns the CT Other information" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    expect(object.ct_other(2, 3,)).to eq("")
    expect(object.ct_other(3, 3,)).to eq("(X1")
    expect(object.ct_other(4, 3,)).to eq("X1)")
    expect(object.ct_other(5, 3,)).to eq("X1")
  end

  it "returns the sheet info" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.sheet_info(:adam_ig, :main)
  #Xwrite_yaml_file(result, sub_dir, "sheet_info_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "sheet_info_expected_1.yaml")
    expect(result).to eq(expected)
  end

  it "returns the map info" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.map_info(:adam_ig, :main)
  #Xwrite_yaml_file(result, sub_dir, "map_info_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "map_info_expected_1.yaml")
    expect(result).to eq(expected)
  end

end