require 'rails_helper'

describe BiomedicalConceptCore do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("MDRIdentificationACME.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
  end

  it "validates a valid object" do
    result = BiomedicalConceptCore.new
    puts result.errors.count
    result.valid?
    expect(result.errors.full_messages[0]).to eq("")
    expect(result.valid?).to eq(true)
  end

  it "allows the object to be found" do
    item = BiomedicalConceptCore.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
    expect(item.identifier).to eq("Obs PQR")
  end

  it "allows the properties to be returned" do
    properties_json = read_yaml_file_to_hash("bc_core_properties_2.yaml")
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    expect(json).to eq(properties_json)
  end

  it "allows the properties to be update the object" do
    properties_json = read_yaml_file_to_hash("bc_core_properties_3.yaml")
    item = BiomedicalConceptCore.find("BC-ACME_BC_C25206", "http://www.assero.co.uk/MDRBCs/V1")
    json = item.get_properties
    json[:children][3][:question_text] = "Updated Question text"
    item.set_properties(json)
    json = item.get_properties
    expect(json).to eq(properties_json)
  end

  it "allows the object to be exported as JSON" 

  it "allows the object to be created from JSON" 

  it "allows an object to be exported as SPARQL" 
  
end
  