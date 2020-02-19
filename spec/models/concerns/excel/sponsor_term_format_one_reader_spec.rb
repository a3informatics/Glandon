require 'rails_helper'

describe "Sponsor Term Format One Reader" do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/sponsor_term_format_one_reader"
  end

	before :each do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel.new(full_path) 
    expect(object.errors.count).to eq(0)
  end

  it "process engine, version 2 no errors" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_2)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "check_and_process_sheet_expected_1.yaml", equate_method: :hash_equal)
  end

  it "process engine, version 3 no errors" do
    full_path = test_file_path(sub_dir, "read_input_5.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_3)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "check_and_process_sheet_expected_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, various errors, version 2" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_2)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(32)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_1.yaml", equate_method: :hash_equal)
  end

  it "process engine, various errors, version 3" do
    full_path = test_file_path(sub_dir, "read_input_4.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_3)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(40)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, format check for version 2" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_3)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Harmonized_Terminology_Listing sheet in the excel file, incorrect column count. Expected 20, found 18.")
  end

  it "process engine, format check for version 3" do
    full_path = test_file_path(sub_dir, "read_input_3.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :sponsor_term_format_one, format: :version_2)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Harmonized_Terminology_Listing sheet in the excel file, incorrect column count. Expected 18, found 20.")
  end

end