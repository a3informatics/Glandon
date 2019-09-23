require 'rails_helper'

describe OdmXml::Terminology do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/odm_xml/terminology"
  end

	before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", 
      "BusinessOperational.ttl", "BusinessForm.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..49)
    th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V49#TH"))
    th.has_state.make_current
  end

  it "initialize object, fails to read the odm file" do
    full_path = test_file_path(sub_dir, "odmXXX.xml") #dodgy filename
    error_msg = "Exception raised opening ODM XML file, filename=#{full_path}. No such file or directory @ rb_sysopen - #{full_path}"
		object = OdmXml::Terminology.new(full_path)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq(error_msg)		
	end

	it "initialize object, success" do
		full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    expect(object.errors.full_messages.to_sentence).to eq("")    
	end

	it "gets CL list" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.list
  #write_yaml_file(result, sub_dir, "list_expected.yaml")
    expected = read_yaml_file(sub_dir, "list_expected.yaml")
		expect(result).to eq(expected)
	end

  it "gets CL, CL_SEX example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.code_list("CL_SEX")
  #write_yaml_file(result, sub_dir, "code_list_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "code_list_expected_1.yaml")
    expect(result).to eq(expected)
  end

  it "gets CL, CL_AE_SEVERITY example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.code_list("CL_AE_SEVERITY")
  #write_yaml_file(result, sub_dir, "code_list_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "code_list_expected_2.yaml")
    expect(result).to eq(expected)
  end

  it "gets CL, CL_ORRES_ACQ02 example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.code_list("CL_ORRES_ACQ02")
  #write_yaml_file(result, sub_dir, "code_list_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "code_list_expected_3.yaml")
    expect(result).to eq(expected)
  end

  it "gets CL, CL_AE_SEVERITY example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.code_list("CL_ANNOTATION_TYPE")
  #write_yaml_file(result, sub_dir, "code_list_expected_4.yaml")
    expected = read_yaml_file(sub_dir, "code_list_expected_4.yaml")
    expect(result).to eq(expected)
  end

	it "reads the odm fle, error I" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    items = object.code_list("CL_ERROR")
    expect(items).to eq({})
	end
   
  it "reads the odm fle, error I" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Terminology.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.code_list("CL_ANNOTATION_TYPEXXX")
    expect(result).to eq({})
  end

end