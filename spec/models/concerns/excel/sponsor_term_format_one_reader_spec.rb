require 'rails_helper'

describe Excel::SponsorTermFormatOneReader do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/sponsor_term_format_one_reader"
  end

	before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl", "iso_concept_systems_process.ttl"]
    load_files(schema_files, data_files)
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    expect(object.errors.count).to eq(0)
  end

  it "process engine, no errors" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    object.check_and_process_sheet(:sponsor_term_format_one, :version_2)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "check_and_process_sheet_expected_1.yaml", equate_method: :hash_equal)
  end

  it "process engine, various errors, version 2" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    object.check_and_process_sheet(:sponsor_term_format_one, :version_2)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(23)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_1.yaml", equate_method: :hash_equal)
  end

  it "process engine, various errors, version 3" do
    full_path = test_file_path(sub_dir, "read_input_4.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    object.check_and_process_sheet(:sponsor_term_format_one, :version_3)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(11)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, format check for version 2" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    object.check_and_process_sheet(:sponsor_term_format_one, :version_3)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Harmonized_Terminology_Listing sheet in the excel file, incorrect column count. Expected 20, found 18.")
  end

  it "process engine, format check for version 3" do
    full_path = test_file_path(sub_dir, "read_input_3.xlsx")
    object = Excel::SponsorTermFormatOneReader.new(full_path) 
    object.check_and_process_sheet(:sponsor_term_format_one, :version_2)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Harmonized_Terminology_Listing sheet in the excel file, incorrect column count. Expected 18, found 20.")
  end

end