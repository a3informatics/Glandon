require 'rails_helper'
require_dependency 'import/odm' # Needed becuase Odm is alos name of a gem.

describe Odm do
	
	include DataHelpers

	def sub_dir
    return "models/import/odm"
  end

	before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
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

	it "gets form list" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = Import::Odm.new
    expect(object.errors.count).to eq(0)
    result = object.list({filename: full_path})
  #write_yaml_file(result, sub_dir, "list_expected.yaml")
    expected = read_yaml_file(sub_dir, "list_expected.yaml")
		expect(result).to eq(expected)
	end

  it "gets form, AE example" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = Import::Odm.new
    expect(object.errors.count).to eq(0)
    item = object.import({identifier: "F_AE", filename: full_path})
    expect(item.errors.count).to eq(0)
    result = item.to_json
  #write_yaml_file(result, sub_dir, "import_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_1.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

  it "gets form, DM example" do
    full_path = test_file_path(sub_dir, "odm_2.xml")
    object = Import::Odm.new
    expect(object.errors.count).to eq(0)
    item = object.import({identifier: "DM", filename: full_path})
    expect(item.errors.count).to eq(0)
    result = item.to_json
  #write_yaml_file(result, sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    expected[:last_changed_date] = result[:last_changed_date] # Dates will need fixing
    expected[:creation_date] = result[:creation_date]
    expect(result).to eq(expected)
  end

end