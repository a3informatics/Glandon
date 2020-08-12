require 'rails_helper'

describe SdtmExcel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/sdtm_excel"
  end

	# before :all do
 #    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
 #    load_files(schema_files, data_files)
 #    clear_iso_concept_object
 #    clear_iso_namespace_object
 #    clear_iso_registration_authority_object
 #    clear_iso_registration_state_object
 #  end

 #  it "fails to read the model file" do
	# 	object = Background.new
	# 	result = SdtmExcel.read_model({:files => ["xxx.ttl"]}, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Could not open the import file.")		
	# end

	# it "reads the excel fle, model" do
	# 	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_model(params, object.errors)
	# #Xwrite_yaml_file(result, sub_dir, "model_build_expected.yaml")
 #    expected = read_yaml_file(sub_dir, "model_build_expected.yaml")
 #    # Need to align the timestamps to allow simple comparison to work
 #    expected.each_with_index do |x, index|
 #    	x[:instance][:managed_item][:last_changed_date] = result[index][:instance][:managed_item][:last_changed_date]
 #    end
	# 	expect(result).to eq(expected)
	# 	expect(object.errors.count).to eq(0)
	# end

	# it "reads the excel fle, implementation guide" do
	# 	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "1.0", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_ig(params, object.errors)
	# #Xwrite_yaml_file(result, sub_dir, "ig_build_expected.yaml")
 #    expected = read_yaml_file(sub_dir, "ig_build_expected.yaml")
 #    # Need to align the timestamps to allow simple comparison to work
 #    expected.each_with_index do |x, index|
 #    	x[:instance][:managed_item][:last_changed_date] = result[index][:instance][:managed_item][:last_changed_date]
 #    end
	# 	expect(result).to eq(expected)
	# 	expect(object.errors.count).to eq(0)
	# end

	# it "reads the excel fle, implementation guide, semantic version check" do
	# 	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "2", 
	# 		version_label: "2.1.3", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_ig(params, object.errors)
	# #Xwrite_yaml_file(result, sub_dir, "ig_build_expected_2.yaml")
 #    expected = read_yaml_file(sub_dir, "ig_build_expected_2.yaml")
 #    # Need to align the timestamps to allow simple comparison to work
 #    expected.each_with_index do |x, index|
 #    	x[:instance][:managed_item][:last_changed_date] = result[index][:instance][:managed_item][:last_changed_date]
 #    end
	# 	expect(result).to eq(expected)
	# 	expect(object.errors.count).to eq(0)
	# end

	# it "reads the excel fle, error 1" do
	# 	filename = test_file_path(sub_dir, "sdtmError1.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_model(params, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect 1st column name, indicates format error.")	
	# end

	# it "reads the excel fle, error 2" do
	# 	filename = test_file_path(sub_dir, "sdtmError2.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_ig(params, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Missing 'Extra' sheet in the excel file.")	
	# end

	# it "reads the excel fle, error 3" do
	# 	filename = test_file_path(sub_dir, "sdtmError3.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_model(params, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Unexpected exception. Possibly an empty Main sheet.")	
	# end
    
	# it "reads the excel fle, error 4" do
	# 	filename = test_file_path(sub_dir, "sdtmError4.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_model(params, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect column count, indicates format error.")	
	# end
    
	# it "reads the excel fle, error 5" do
	# 	filename = test_file_path(sub_dir, "sdtmError5.xlsx")
	# 	object = Background.new
	# 	params = {
	# 		version: "1", 
	# 		version_label: "Version Label", 
	# 		date: "2017-01-01", 
	# 		:files => ["#{filename}"]
	# 	}
	# 	result = SdtmExcel.read_model(params, object.errors)
	# 	expect(object.errors.count).to eq(1)
	# 	expect(object.errors.full_messages.to_sentence).to eq("Unexpected exception. Possibly an empty Main sheet.")	
	# end
    
end