require 'rails_helper'

describe TermChangeExcel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/term_change_excel"
  end

	before :all do
  end

  it "fails to read the change file" do
		object = Background.new
		result = TermChangeExcel.read_changes({:files => ["xxx.ttl"]}, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Could not open the import file.")		
	end

	it "reads the change file, March 2016" do
		filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2016-03-25.xlsx")
		object = Background.new
		params = {
			version: "21", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
	#write_yaml_file(result, sub_dir, "change_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "change_expected_1.yaml")
		expect(result).to match_array(expected)
		expect(object.errors.count).to eq(0)
	end

	it "reads the change file, June 2017" do
		filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2017-06-30.xlsx")
		object = Background.new
		params = {
			version: "21", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
	#write_yaml_file(result, sub_dir, "change_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "change_expected_2.yaml")
		expect(result).to match_array(expected)
		expect(object.errors.count).to eq(0)
	end

	it "reads the excel fle, empty sheet" do
		filename = test_file_path(sub_dir, "change_input_1.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Unexpected exception. Possibly an empty Main sheet.")	
	end
   
	it "reads the excel fle, missing columns" do
		filename = test_file_path(sub_dir, "change_input_2.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect column count, indicates format error.")	
	end
    
	it "reads the excel fle, missing columns" do
		filename = test_file_path(sub_dir, "change_input_2.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Main sheet in the excel file, incorrect column count, indicates format error.")	
	end
   
	it "reads the excel fle, missing data, previous codelist" do
		filename = test_file_path(sub_dir, "change_input_3.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 2, column 13.")	
	end

	it "reads the excel fle, missing data, new codelist" do
		filename = test_file_path(sub_dir, "change_input_4.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 2, column 15.")	
	end

	it "reads the excel fle, missing data, comment" do
		filename = test_file_path(sub_dir, "change_input_5.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Empty cell detected in row 2, column 17.")	
	end

	it "reads the excel fle, missing data, multiple new" do
		filename = test_file_path(sub_dir, "change_input_6.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Multiple new Code Lists with Code List Items.")	
	end

	it "reads the excel fle, missing data, multiple mappings" do
		filename = test_file_path(sub_dir, "change_input_7.xlsx")
		object = Background.new
		params = {
			version: "31", 
			:files => ["#{filename}"]
		}
		result = TermChangeExcel.read_changes(params, object.errors)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Multiple previous to new mappings.")	
	end

end