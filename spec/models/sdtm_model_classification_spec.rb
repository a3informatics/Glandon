require 'rails_helper'

describe SdtmModelClassification do
	
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
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "", 
      :namespace => "", 
      :label => "", 
      :extension_properties => []
    }
    result = SdtmModelClassification.new
    expect(result.to_json).to eq(expected)
  end

  it "allows the object to be validated"

  it "allows the object to be created from JSON" do
    json = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "X", 
      :namespace => "http://www.example.com", 
      :label => "My Label", 
      :extension_properties => []
    }
    result = SdtmModelClassification.from_json(json)
    expect(result.to_json).to eq(json)
  end

  it "allows the object to be exported as JSON" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "", 
      :namespace => "", 
      :label => "NEW LABEL", 
      :extension_properties => []
    }
    result = SdtmModelClassification.new
    result.label = "NEW LABEL"
    expect(result.to_json).to eq(expected)
  end

  it "allows all leaf labels to be returned" do
    result = SdtmModelClassification.all_leaf("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    json = []
    result.each {|tc| json << tc.to_json}
    #write_yaml_file(json, sub_dir, "sdtm_model_classification_all_leaf.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_leaf.yaml")
    expect(json).to eq(expected)
  end

  it "allows all parent labels to be returned" do
    result = SdtmModelClassification.all_parent("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    json = []
    result.each {|tc| json << tc.to_json}
    #write_yaml_file(json, sub_dir, "sdtm_model_classification_all_parent.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_parent.yaml")
    expect(json).to eq(expected)
  end

  it "allows all child labels to be returned" do
    result = SdtmModelClassification.all_children("M-CDISC_SDTMMODEL_C_QUALIFIER", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    json = []
    result.each {|tc| json << tc.to_json}
    #write_yaml_file(json, sub_dir, "sdtm_model_classification_all_child.yaml")
    expected = read_yaml_file(sub_dir, "sdtm_model_classification_all_child.yaml")
    expect(json).to eq(expected)
  end

  it "allows default parent label to be returned" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "M-CDISC_SDTMMODEL_C_QUALIFIER", 
      :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3", 
      :label => "Qualifier", 
      :extension_properties => []
    }
    result = SdtmModelClassification.all_parent("http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    default = SdtmModelClassification.default_parent(result)
    expect(default.to_json).to eq(expected)
  end

  it "allows default child label to be returned" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableClassification", 
      :id => "M-CDISC_SDTMMODEL_SC_RECORDQUALIFIER", 
      :namespace => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3", 
      :label => "Record Qualifier", 
      :extension_properties => []
    }
    result = SdtmModelClassification.all_children("M-CDISC_SDTMMODEL_C_QUALIFIER", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
    default = SdtmModelClassification.default_child(result)
    expect(default.to_json).to eq(expected)
  end

end