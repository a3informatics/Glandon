require 'rails_helper'

describe Excel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel"
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
    result = object.check_sheet({name: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN"]})
    expect(result).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, error length, more" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({name: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN", "EXTRA"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error length, less" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({name: "First", columns: ["NOT EMPTY", "CAN BE EMPTY"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error mismatch" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet({name: "First", columns: ["NOT EMPTYXXX", "CAN BE EMPTY", "THIRD COLUMN"]})
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect 1st column name, indicates format error.")    
  end

end