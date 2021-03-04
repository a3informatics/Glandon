require 'rails_helper'

describe BiomedicalConceptTemplate do
  
  include DataHelpers

  def sub_dir
    return "models/biomedical_concept_template"
  end

  before :all do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_local_bc_template_and_instances
  end


  it "allows validity of the object to be checked - error" do
    result = BiomedicalConceptTemplate.new
    result.valid?
    expect(result.errors.count).to eq(3)
    expect(result.errors.full_messages[0]).to eq("Uri can't be blank")
    expect(result.errors.full_messages[1]).to eq("Has identifier empty object")
    expect(result.errors.full_messages[2]).to eq("Has state empty object")
    expect(result.valid?).to eq(false)
  end

  it "allows validity of the object to be checked" do
    result = BiomedicalConcept.new
    ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
    result.has_state = IsoRegistrationStateV2.new
    result.has_state.uri = "na"
    result.has_state.by_authority = ra
    result.has_identifier = IsoScopedIdentifierV2.new
    result.has_identifier.uri = "na"
    result.has_identifier.identifier = "HELLO WORLD"
    result.has_identifier.semantic_version = "0.1.0"
    result.uri = "xxx"
    valid = result.valid?
    expect(result.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

  it "allows a BCT to be found" do
    item = BiomedicalConceptTemplate.find(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
  end

  it "allows a BCT to be found, full" do
    item = BiomedicalConceptTemplate.find_full(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
    check_file_actual_expected(item.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
  end

  it "allows a BCT to be found, minimum" do
    item = BiomedicalConceptTemplate.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS_PQR/V1#BCT"))
    check_file_actual_expected(item.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
  end

end
  