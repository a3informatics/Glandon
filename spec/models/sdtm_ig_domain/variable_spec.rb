require 'rails_helper'

describe SdtmIgDomain::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_ig_domain/variable"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
  end

  it "validates a valid object" do
    result = SdtmIgDomain::Variable.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    item = SdtmIgDomain::Variable.new
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank")
    expect(result).to eq(false)
  end

  it "does not validate an invalid object" do
    item = SdtmIgDomain::Variable.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/VAR1")
    item.format = "XXX"
    result = item.valid?
    expect(result).to eq(true)
    item.format = "XX§§§§§§§X"
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Format contains invalid characters")
    expect(result).to eq(false)
  end

  it "return compliance" do
    compliance = SdtmIgDomain::Variable.compliance
    check_file_actual_expected(compliance, sub_dir, "compliance_expected_1.yaml", equate_method: :hash_equal)
  end

end
  