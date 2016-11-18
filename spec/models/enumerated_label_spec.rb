require 'rails_helper'

describe EnumeratedLabel do
	
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("enumerated_label.ttl")
  end

  it "allows all labels to be returned" do
    result = 
    [ 
      {
        :rdf_type => "VariableCompliance", 
        :id => "IG-CDISC_SDTMIGMH_C_PERMISSIBLE", 
        :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
        :label => "Permissible",
        :properties => [],
        :links => [],
        :extension_properties => [],
        :triples => {}
      }, 
      {
        :rdf_type => "VariableCompliance", 
        :id => "IG-CDISC_SDTMIGMH_C_EXPECTED", 
        :namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V1", 
        :label => "Expected",
        :properties => [],
        :links => [],
        :extension_properties => [],
        :triples => {}
      }, 
      {
        :rdf_type => "VariableCompliance", 
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

end