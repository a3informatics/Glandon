require 'rails_helper'

describe OdmXml::Forms do
	
	include DataHelpers
  include IsoManagedHelpers

	def sub_dir
    return "models/concerns/odm_xml/forms"
  end

	before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..49)
    th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V49#TH"))
    th.has_state.make_current
  end

  it "initialize object, fails to read the odm file" do
    full_path = test_file_path(sub_dir, "odmXXX.xml") #dodgy filename
    error_msg = "Exception raised opening ODM XML file, filename=#{full_path}. No such file or directory @ rb_sysopen - #{full_path}"
		object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq(error_msg)		
	end

	it "initialize object, success" do
		full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    expect(object.errors.full_messages.to_sentence).to eq("")    
	end

	it "gets form list" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    result = object.list
  #write_yaml_file(result, sub_dir, "list_expected.yaml")
    expected = read_yaml_file(sub_dir, "list_expected.yaml")
		expect(result).to eq(expected)
	end

  it "gets form, BASELINE example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("F_BASELINE")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_1.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_1.yaml", equate_method: :hash_equal)
  end

  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("F_AE")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_2.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_2.yaml", equate_method: :hash_equal)
  end

  it "gets form, DM example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("DM")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_3.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_3.yaml", equate_method: :hash_equal)
  end

  it "gets form, IE example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("IE")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_4.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_4.yaml", equate_method: :hash_equal)
  end

  it "gets form, another DM example" do
    full_path = test_file_path(sub_dir, "odm_3.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("f.dm")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_5.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_5.yaml", equate_method: :hash_equal)
  end

  it "gets form, another DM-ish example" do
    full_path = test_file_path(sub_dir, "odm_4.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    actual = object.form("f.screenid")
    expect(actual).to_not be_nil
    fix_dates(actual, sub_dir, "form_expected_6.yaml", :creation_date)
    check_file_actual_expected(actual.to_h, sub_dir, "form_expected_6.yaml", equate_method: :hash_equal)
  end

  it "reads the odm fle, error I" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("F_ERROR")
    expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq("Exception raised building form. undefined method `attributes' for nil:NilClass")	
	end
   
end