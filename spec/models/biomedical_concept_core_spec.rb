require 'rails_helper'
require 'biomedical_concept_core'

describe BiomedicalConceptCore do
  
  include DataHelpers

  def sub_dir
    return "models"
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
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows validity of the object to be checked - error" do
    result = BiomedicalConceptCore.new
    result.valid?
    expect(result.errors.count).to eq(3)
    expect(result.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Namespace error: Short name contains invalid characters")
    expect(result.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Number does not contains 9 digits")
    expect(result.errors.full_messages[2]).to eq("Scoped Identifier error: Identifier contains invalid characters")
    expect(result.valid?).to eq(false)
  end

    it "allows validity of the object to be checked" do
    result = BiomedicalConceptCore.new
    result.registrationState.registrationAuthority.namespace.shortName = "AAA"
    result.registrationState.registrationAuthority.namespace.name = "USER AAA"
    result.registrationState.registrationAuthority.number = "123456789"
    result.scopedIdentifier.identifier = "123 DEF edr"
    valid = result.valid?
    expect(result.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

  it "allows the object to be found" do
    item = BiomedicalConceptCore.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(item.identifier).to eq("Obs PQR")
  end

  it "allows the properties to be returned" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    #write_hash_to_yaml_file_2(json, sub_dir, "bc_core_properties_find.yaml")
    properties_json = read_yaml_file_to_hash_2(sub_dir, "bc_core_properties_find.yaml")
    expect(json).to eq(properties_json)
  end

  it "allows the properties to be update the object" do
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    json[:children][3][:question_text] = "Updated Question text"
    item.set_properties(json)
    json = item.get_properties
    #write_hash_to_yaml_file_2(json, sub_dir, "bc_core_properties_update.yaml")
    properties_json = read_yaml_file_to_hash_2(sub_dir, "bc_core_properties_update.yaml")
    expect(json).to eq(properties_json)
  end

  it "allows the object to be exported as JSON" 

  it "allows the object to be created from JSON" 

  it "allows an object to be exported as SPARQL" 
  
end
  