require 'rails_helper'

describe SdtmModelCompliance do
	
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
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
  end

  it "allows a new item to be created" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "", 
      :namespace => "", 
      :label => "", 
      :extension_properties => []
    }
    result = SdtmModelCompliance.new
    expect(result.to_json).to eq(expected)
  end

  it "allows the object to be created from JSON" do
    json = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "X", 
      :namespace => "http://www.example.com", 
      :label => "My Label", 
      :extension_properties => []
    }
    result = SdtmModelCompliance.from_json(json)
    expect(result.to_json).to eq(json)
  end

  it "allows the object to be exported as JSON" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "", 
      :namespace => "", 
      :label => "NEW LABEL", 
      :extension_properties => []
    }
    result = SdtmModelCompliance.new
    result.label = "NEW LABEL"
    expect(result.to_json).to eq(expected)
  end

  it "allows all labels to be returned" do
    result = SdtmModelCompliance.all("IG-CDISC_SDTMIGVS", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    json = []
    result.each {|tc| json << tc.to_json}
    #write_yaml_file(json, sub_dir, "sdtm_model_compliance_all.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_compliance_all.yaml")
    expect(json).to eq(expected)
  end

  it "allows default label to be returned" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "IG-CDISC_SDTMIGVS_C_PERMISSIBLE", 
      :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3", 
      :label => "Permissible", 
      :extension_properties => []
    }
    result = SdtmModelCompliance.all("IG-CDISC_SDTMIGVS", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    default = SdtmModelCompliance.default(result)
    expect(default.to_json).to eq(expected)
  end

end