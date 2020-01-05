require 'rails_helper'

describe "Cdisc Term Reader" do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/cdisc_term_reader"
  end

	before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl"]
    load_files(schema_files, data_files)
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel.new(full_path) 
    expect(object.errors.count).to eq(0)
  end

  it "process engine, no errors" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel.new(full_path) 
    object.check_and_process_sheet(:cdisc_term, :version_5)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(0)
  end

  it "process engine, various errors" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel.new(full_path) 
    object.check_and_process_sheet(:cdisc_term, :version_5)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(10)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_2.yaml", equate_method: :hash_equal)
  end

end