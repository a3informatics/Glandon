require 'rails_helper'

describe CdiscCli do

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
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V39.ttl")
    load_test_file_into_triple_store("CT_V40.ttl")
    load_test_file_into_triple_store("CT_V41.ttl")
    clear_iso_concept_object
  end

  it "allows an object to be initialised" do
    tc = CdiscCli.new
    result = 
      {
        :children => [],
        :definition => "",
        :extension_properties => [],
        :id => "",
        :identifier => "",
        :label => "",
        :namespace => "",
        :notation => "",
        :parentIdentifier => "",
        :preferredTerm => "",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    expect(tc.to_json).to eq(result)
  end

  it "allows validity of the object to be checked - error" do
    tc = CdiscCli.new
    valid = tc.valid?
    expect(valid).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Identifier is empty")
  end 

  it "allows validity of the object to be checked" do
    tc = CdiscCli.new
    tc.identifier = "AAA"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = CdiscCli.find("CLI-C105135_C105274", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc.identifier).to eq("C105274")    
  end

  it "allows a TC to be found - error" do
    tc = CdiscCli.find("CLI-C105135_C105274x", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc).to eq(nil)    
  end

  it "allows two CLs to be compared, same" do
    tc1 = CdiscCli.find("CLI-C105135_C105274", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    tc2 = CdiscCli.find("CLI-C105135_C105274", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    result = CdiscCli.diff?(tc1, tc2)
    expect(result).to eq(false)    
  end

  it "allows two CLs to be compared, different" do
    tc1 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCli.diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "generates a CSV record with no header" do
    tc = CdiscCli.find("CLI-C66741_C84372", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    expected = 
    [
      "C84372", 
      "Knee to Heel Length Measurement", 
      "KNEEHEEL", 
      "Knee to Heel Length; Lower Leg Length", 
      "A measurement of the length of the lower leg from the top of the knee to the bottom of the heel. " + 
        "This measurement may be taken with a knemometer or calipers. (NCI)",
      "Knee to Heel Length Measurement"
    ]
    expect(tc.to_csv_no_header).to eq(expected)
  end

end