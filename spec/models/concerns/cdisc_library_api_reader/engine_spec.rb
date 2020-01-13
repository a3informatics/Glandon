require 'rails_helper'

describe CDISCLibraryAPIReader::Engine do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/cdisc_library_api_reader/engine"
  end

	before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl"]
    load_files(schema_files, data_files)
  end

  it "initialize object, success" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    expect(object.parent_set). to eq({})
    expect(parent.errors.count).to eq(0)
  end

  it "process protocol" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    object.process("/mdr/ct/packages/protocolct-2019-09-27")
    result = object.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "process_expected_1.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result, sub_dir, "process_check_1.yaml", equate_method: :hash_equal) # Results file from equivalent Excel import.
  end

  it "process sdtm" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    object.process("/mdr/ct/packages/sdtmct-2019-09-27")
    result = object.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "process_expected_2.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result, sub_dir, "process_check_2.yaml", equate_method: :hash_equal) # Results file from equivalent Excel import.
  end

  it "process send" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    object.process("/mdr/ct/packages/sendct-2019-09-27")
    result = object.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "process_expected_3.yaml", equate_method: :hash_equal, write_file: true)
    check_file_actual_expected(result, sub_dir, "process_check_3.yaml", equate_method: :hash_equal) # Results file from equivalent Excel import.
  end

  it "process adam" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    object.process("/mdr/ct/packages/adamct-2019-03-29")
    result = object.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "process_expected_4.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result, sub_dir, "process_check_4.yaml", equate_method: :hash_equal) # Results file from equivalent Excel import.
  end

  it "process cdash" do
    parent = IsoConceptV2.new
    object = CDISCLibraryAPIReader::Engine.new(parent) 
    object.process("/mdr/ct/packages/cdashct-2019-06-28")
    result = object.parent_set.map{|k,v| v.to_h}
    check_file_actual_expected(result, sub_dir, "process_expected_5.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result, sub_dir, "process_check_5.yaml", equate_method: :hash_equal) # Results file from equivalent Excel import.
  end

end