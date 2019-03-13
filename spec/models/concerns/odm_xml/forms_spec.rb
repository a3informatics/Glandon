require 'rails_helper'

describe OdmXml::Forms do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/odm_xml/forms"
  end

	before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V49.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
    IsoRegistrationState.make_current(th.registrationState.id)
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
    item = object.form("F_BASELINE")
    expect(item).to_not be_nil
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_1.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("F_AE")
    expect(item).to_not be_nil
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_2.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, DM example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("DM")
    expect(item).to_not be_nil
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_3.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, IE example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("IE")
    expect(item).to_not be_nil
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_4.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_4.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, another DM example" do
    full_path = test_file_path(sub_dir, "odm_3.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("f.dm")
    expect(item).to_not be_nil
    result = item.to_json
  #write_yaml_file(result, sub_dir, "form_expected_5.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_5.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, another DM-ish example" do
    full_path = test_file_path(sub_dir, "odm_4.xml")
    object = OdmXml::Forms.new(full_path)
    expect(object.errors.count).to eq(0)
    item = object.form("f.screenid")
    expect(item).to_not be_nil
    result = item.to_json
  #Xwrite_yaml_file(result, sub_dir, "form_expected_6.yaml")
    expected = read_yaml_file(sub_dir, "form_expected_6.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
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