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

  it "returns label" do
    full_path = test_file_path(sub_dir, "new_input_1.xlsx")
    object = Excel.new(full_path)
    expect(object.full_path).to eq(full_path)
    expect(object.label).to eq(File.basename(full_path))
  end

  it "checks a sheet, success" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({selection: {label: "First"}, columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, error length, more" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({selection: {label: "First"}, columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN", "EXTRA"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count. Expected 4, found 3.")    
  end

  it "checks a sheet, error length, less" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({selection: {label: "First"}, columns: ["NOT EMPTY", "CAN BE EMPTY"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect column count. Expected 2, found 3.")    
  end

  it "checks a sheet, error mismatch" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({selection: {label: "First"}, columns: ["NOT EMPTYXXX", "CAN BE EMPTY", "THIRD COLUMN"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("First sheet in the excel file, incorrect 1st column name. Expected NOT EMPTYXXX, found NOT EMPTY.")    
  end

  it "checks a sheet, include the name check" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_return({selection: {label: "irs"}, columns: ["NOT EMPTY", "CAN BE EMPTY", "THIRD COLUMN"]})
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a sheet, sheet not found label" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test_4, :sheet_1)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Exception raised 'Failed to find sheet with name containing 'hee'.' checking worksheet for import 'import' using sheet 'sheet'.")
  end

  it "checks a sheet, sheet not found date" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test_5, :sheet_1)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Exception raised 'Failed to find sheet with name including a date.' checking worksheet for import 'import' using sheet 'sheet'.")
  end

  it "checks a sheet, sheet not found first" do
    expect_any_instance_of(Roo::Excelx).to receive(:sheets).and_raise(StandardError)
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test_6, :sheet_1)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Exception raised 'Failed to find the first sheet.' checking worksheet for import 'import' using sheet 'sheet'.")
  end

  it "checks a sheet, sheet not found, invalid mechanism" do
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test_7, :sheet_1)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Exception raised 'Invalid mechanism to find sheet.' checking worksheet for import 'import' using sheet 'sheet'.")
  end

  it "checks a sheet, exception" do
    expect_any_instance_of(Excel::Engine).to receive(:sheet_info).with(:test, :something).and_raise(StandardError)
    full_path = test_file_path(sub_dir, "check_sheets_input_1.xlsx")
    object = Excel.new(full_path)
    result = object.check_sheet(:test, :something)
    expect(result).to eq(false)
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Exception raised 'StandardError' checking worksheet for import 'import' using sheet 'sheet'.")
  end

  it "process engine" do
    full_path = test_file_path(sub_dir, "process_input_2.xlsx")
    object = Excel.new(full_path)
    object.process_sheet(:cdisc_adam_ig, :main)
    result = object.engine.parent_set
    result.each {|k,v| result[k] = v.to_json}
  #Xwrite_yaml_file(result, sub_dir, "process_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "process_expected_2.yaml")
    result.each do |k,v|
      expected[k][:creation_date] = v[:creation_date]
      expected[k][:last_changed_date] = v[:last_changed_date]
      expected[k][:registration_state][:effective_date] = v[:registration_state][:effective_date]
    end
    expect(result).to hash_equal(expected)
    expect(object.errors.count).to eq(0)
  end

end