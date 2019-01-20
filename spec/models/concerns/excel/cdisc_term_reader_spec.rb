require 'rails_helper'

describe Excel::CdiscTermReader do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/cdisc_term_reader"
  end

	before :each do
    clear_triple_store
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::CdiscTermReader.new(full_path) 
    expect(object.errors.count).to eq(0)
  end

  it "process engine, no errors" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::CdiscTermReader.new(full_path) 
    object.check_and_process_sheet(:cdisc_term, :version_3)
    result = object.engine.parent_set
  #Xwrite_yaml_file(result, sub_dir, "read_expected_1.yaml")
    #expected = read_yaml_file(sub_dir, "read_expected_1.yaml")
    #expect(result).to operation_hash_equal(expected)
    expect(object.errors.count).to eq(0)
  end

  it "process engine, various errors" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel::CdiscTermReader.new(full_path) 
    object.check_and_process_sheet(:cdisc_term, :version_3)
    result = object.engine.parent_set
  #Xwrite_yaml_file(result, sub_dir, "read_expected_2.yaml")
    #expected = read_yaml_file(sub_dir, "read_expected_2.yaml")
    #expect(result).to operation_hash_equal(expected)
  #Xwrite_yaml_file(object.errors.full_messages.to_yaml, sub_dir, "read_errors_2.yaml")
    expected = read_yaml_file(sub_dir, "read_errors_2.yaml")
    expect(object.errors.count).to eq(10)
    expect(object.errors.full_messages.to_yaml).to eq(expected)
  end

end