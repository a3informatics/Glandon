require 'rails_helper'

describe EnumeratedLabel do
	
  include DataHelpers

  before :all do
    data_files = ["enumerated_label.ttl"]
    load_files(schema_files, data_files)
    # clear_triple_store
    # load_schema_file_into_triple_store("ISO11179Types.ttl")
    # load_schema_file_into_triple_store("ISO11179Identification.ttl")
    # load_schema_file_into_triple_store("ISO11179Registration.ttl")
    # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    # load_test_file_into_triple_store("enumerated_label.ttl")
  end

  it "allows all labels to be returned" do
    result = 
    [ 
      {
        :rdf_type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
        :id => "IG-CDISC_SDTMIGMH_C_PERMISSIBLE", 
        :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
        :label => "Permissible",
        :properties => [],
        :links => [],
        :extension_properties => [],
        :triples => {}
      }, 
      {
        :rdf_type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
        :id => "IG-CDISC_SDTMIGMH_C_EXPECTED", 
        :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
        :label => "Expected",
        :properties => [],
        :links => [],
        :extension_properties => [],
        :triples => {}
      }, 
      {
        :rdf_type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
        :id => "IG-CDISC_SDTMIGMH_C_REQUIRED", 
        :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
        :label => "Required",
        :properties => [],
        :links => [],
        :extension_properties => [],
        :triples => {}
      } 
    ]
    expect(EnumeratedLabel.all("VariableCompliance", "bd", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1").to_json).to eq(result.to_json)
  end

  it "finds an item" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "IG-CDISC_SDTMIGMH_C_REQUIRED", 
      :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
      :label => "Required",
      :extension_properties => []
    }
    item = EnumeratedLabel.find("IG-CDISC_SDTMIGMH_C_REQUIRED", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
    expect(item.to_json).to eq(expected)
  end

  it "will cache a found item" do
    clear_enumerated_label_object
    expected = EnumeratedLabel.new
    expected.rdf_type = "http://www.assero.co.uk/BusinessDomain#VariableCompliance"
    expected.id = "IG-CDISC_SDTMIGMH_C_REQUIRED"
    expected.namespace = "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1" 
    expected.label = "Required"
    expect(IsoConcept).to receive(:find).and_return(expected)
    item1 = EnumeratedLabel.find("IG-CDISC_SDTMIGMH_C_REQUIRED", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
    item2 = EnumeratedLabel.find("IG-CDISC_SDTMIGMH_C_REQUIRED", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
    expect(item1.to_json).to eq(expected.to_json)
    expect(item2.to_json).to eq(expected.to_json)
  end    

  it "will find the default value" do
    expected = 
    {
      :type => "http://www.assero.co.uk/BusinessDomain#VariableCompliance", 
      :id => "IG-CDISC_SDTMIGMH_C_EXPECTED", 
      :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
      :label => "Expected",
      :extension_properties => []
    }
    value_set = EnumeratedLabel.all("VariableCompliance", "bd", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
    default = EnumeratedLabel.default(value_set, "EXPECTED")
    expect(default.to_json).to eq(expected)
  end

  it "will raise a logic expectption if cannot find the default value" do
    value_set = EnumeratedLabel.all("VariableCompliance", "bd", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1")
    expect{EnumeratedLabel.default(value_set, "EXPECTEDXXX")}.to raise_error(Exceptions::ApplicationLogicError)
  end
  
end