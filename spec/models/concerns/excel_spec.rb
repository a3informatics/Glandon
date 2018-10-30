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
    expect(object.full_path).to eq(full_path)
    expect(object.engine).to_not be_nil
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, success" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, error length, more" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN", "EXTRA"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error length, less" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({label: "First", columns: ["NOT EMPTY", "CAN BE EMPTY"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count, indicates format error.")    
  end

  it "checks a sheet, error mismatch" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({label: "First", columns: ["NOT EMPTYXXX", "CAN BE EMPTY", "THIRD COLUMN"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect 1st column name, indicates format error.")    
  end

  it "process engine" do
    full_path = test_file_path(sub_dir, "process_input_1.xlsx")
    object = Excel.new(full_path)
    object.process(:adam_ig, :main)
    result = object.parent_set
byebug
  write_yaml_file(result, sub_dir, "process_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "process_expected_1.yaml")
    expect(result).to eq(expected)
    expect(object.errors.count).to eq(0)
  end

end