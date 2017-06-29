require 'rails_helper'

describe SdtmModelDomain do

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

  it "allows a domain to be found" do
    item = SdtmModelDomain.find("M-CDISC_SDTMMODEL_INTERVENTIONS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_model_domain_find.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_domain_find.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a domain to be found, not found error" do
    expect{SdtmModelDomain.find("M-CDISC_SDTMMODEL_INTERVENTIONSxx", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all domains to be found" do
    results = SdtmModelDomain.all 
    expect(results.count).to eq(6)
  #write_yaml_file(results, sub_dir, "sdtm_model_domain_all.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_domain_all.yaml")
    results.each do |result|
      found = expected.find { |x| x.identifier == result.identifier }
      expect(result.identifier).to eq(found.identifier)
    end
  end
  
  it "allows all released domains to be found" do
    result = SdtmModelDomain.list
    expect(result.count).to eq(6)    
  end
  
  #it "allows an item's history to be found" do
  #  owner = IsoRegistrationAuthority.find_by_short_name("CDISC")
  #  result = SdtmModelDomain.history({:identifier => "SDTM IG PR", :scope_id => owner.namespace.id})
  #  expect(result.count).to eq(1)
  #end
  
  it "allows the domain to be exported as JSON" do
    item = SdtmModelDomain.find("M-CDISC_SDTMMODEL_INTERVENTIONS", "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3")
  #write_yaml_file(item.to_json, sub_dir, "sdtm_model_domain_to_json.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_domain_to_json.yaml")
    expect(item.to_json).to eq(expected)
  end
  
end