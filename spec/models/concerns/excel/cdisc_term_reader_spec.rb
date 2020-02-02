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
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_1.yaml", equate_method: :hash_equal)
  end

  it "process engine, various errors" do
    full_path = test_file_path(sub_dir, "read_input_2.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    result = object.engine.parent_set
    expect(object.errors.count).to eq(10)
    check_file_actual_expected(object.errors.full_messages, sub_dir, "read_errors_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, protocol 2019-09-27 for comparison" do
    full_path = test_file_path(sub_dir, "read_input_3.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, sdtm 2019-09-27 for comparison" do
    full_path = test_file_path(sub_dir, "read_input_4.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_3.yaml", equate_method: :hash_equal)
  end

  it "process engine, send 2019-09-27 for comparison" do
    full_path = test_file_path(sub_dir, "read_input_5.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_4.yaml", equate_method: :hash_equal)
  end

  it "process engine, adam 2019-03-29 for comparison" do
    full_path = test_file_path(sub_dir, "read_input_6.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_5.yaml", equate_method: :hash_equal)
  end

  it "process engine, cdash 2019-06-28 for comparison" do
    full_path = test_file_path(sub_dir, "read_input_7.xlsx")
    object = Excel.new(full_path) 
    object.execute(import_type: :cdisc_term, format: :version_5)
    expect(object.errors.count).to eq(0)
    result = object.engine.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "execute_expected_6.yaml", equate_method: :hash_equal)
  end

end