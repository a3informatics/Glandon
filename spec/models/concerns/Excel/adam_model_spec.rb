require 'rails_helper'

describe Excel::AdamModel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/adam_model"
  end

	before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "fails to read the model file" do
		object = Background.new
		result = SdtmExcel.read_model({:files => ["xxx.ttl"]}, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Could not open the import file.")		
	end

	it "reads the excel fle, model" do
		filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_model(params, object.errors)
	#write_yaml_file(result, sub_dir, "model_build_expected.yaml")
    expected = read_yaml_file(sub_dir, "model_build_expected.yaml")
    # Need to align the timestamps to allow simple comparison to work
    expected.each_with_index do |x, index|
    	x[:instance][:managed_item][:last_changed_date] = result[index][:instance][:managed_item][:last_changed_date]
    end
		expect(result).to eq(expected)
		expect(object.errors.count).to eq(0)
	end

	it "reads the excel fle, error 1" do
		filename = test_file_path(sub_dir, "sdtmError1.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_model(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect 1st column name, indicates format error.")	
	end

	it "reads the excel fle, error 2" do
		filename = test_file_path(sub_dir, "sdtmError2.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_ig(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Missing 'Extra' sheet in the excel file.")	
	end

	it "reads the excel fle, error 3" do
		filename = test_file_path(sub_dir, "sdtmError3.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_model(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Unexpected exception. Possibly an empty Main sheet.")	
	end
    
	it "reads the excel fle, error 4" do
		filename = test_file_path(sub_dir, "sdtmError4.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_model(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect column count, indicates format error.")	
	end
    
	it "reads the excel fle, error 5" do
		filename = test_file_path(sub_dir, "sdtmError5.xlsx")
		object = Background.new
		params = {
			version: "1", 
			version_label: "Version Label", 
			date: "2017-01-01", 
			:files => ["#{filename}"]
		}
		result = SdtmExcel.read_model(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Unexpected exception. Possibly an empty Main sheet.")	
	end
    
end