require 'rails_helper'

describe SdtmModel do

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
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a model to be found" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    write_yaml_file(item.to_json, sub_dir, "sdtm_model_find.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a model to be found, not found error" do
    expect{SdtmModel.find("M-CDISC_SDTMMODELvvv", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all models to be found" do
    result = SdtmModel.all 
    expect(result.count).to eq(1)
    expect(result[0].identifier).to eq("SDTM MODEL")
  end
  
  it "allows all released models to be found" do
    result = SdtmModel.list
    expect(result.count).to eq(1)    
  end
  
  #it "allows an item's history to be found" do
  #  owner = IsoRegistrationAuthority.find_by_short_name("CDISC")
  #  result = SdtmModel.history({:identifier => "SDTM IG PR", :scope_id => owner.namespace.id})
  #  expect(result.count).to eq(1)
  #end
  
  it "allows the model to be exported as JSON" do
    item = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    write_yaml_file(item.to_json, sub_dir, "sdtm_model_to_json.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end
  
end