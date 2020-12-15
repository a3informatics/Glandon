require 'rails_helper'

describe SdtmClass::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_class/variable"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
  end

  it "validates a valid object" do
    item = SdtmClass::Variable.new
    item.uri = Uri.new(uri: "http://www.example.com/a#b")
    item.ordinal = 1
    result = item.valid?
    expect(item.rdf_type.to_s).to eq("http://www.assero.co.uk/Tabulation#SdtmClassVariable")
    expect(item.errors.empty?).to eq(true)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, ordinal WILL CURRENTLY FAIL - Fails in overall run, passes in isolation (double validation error)" do
    item = SdtmClass::Variable.new
    item.uri = Uri.new(uri: "http://www.example.com/a#b")
    item.ordinal = -1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  it "allows an object to be found" do
    item = SdtmClass::Variable.find(Uri.new(uri: "http://www.cdisc.org/SDTM_MODEL_EVENTS/V1#CL_--SCAT"))
    check_file_actual_expected(item.to_h, sub_dir, "find_input.yaml", equate_method: :hash_equal)
  end

  it "return datatypes" do
    datatypes = SdtmClass::Variable.datatypes
    check_file_actual_expected(datatypes, sub_dir, "datatypes_expected_1.yaml", equate_method: :hash_equal)
  end

  it "return classification" do
    classification = SdtmClass::Variable.classification
  byebug
    check_file_actual_expected(classification, sub_dir, "datatypes_expected_1.yaml", equate_method: :hash_equal, write_file: true)
  end

end
  