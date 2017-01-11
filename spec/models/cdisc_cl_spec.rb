require 'rails_helper'

describe CdiscCl do

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
    load_test_file_into_triple_store("CT_V42.ttl")
    clear_iso_concept_object
  end

  it "allows an object to be initialised" do
    tc = CdiscCl.new
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
    tc = CdiscCl.new
    valid = tc.valid?
    expect(valid).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Identifier contains invalid characters")
  end 

  it "allows validity of the object to be checked" do
    tc = CdiscCl.new
    tc.identifier = "AAA"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = CdiscCl.find("CL-C85491", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc.identifier).to eq("C85491")    
  end

  it "allows a TC to be found - error" do
    tc = CdiscCl.find("CL-C85491x", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc).to eq(nil)    
  end

  it "allows a TC to be found, check extensible" do
    tc = CdiscCl.find("CL-C85491", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc.identifier).to eq("C85491")    
    expect(tc.extensible).to eq(true)    
  end

  it "allows a TC to be found, check extensible" do
    tc = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    expect(tc.identifier).to eq("C101843")    
    expect(tc.extensible).to eq(false)    
  end

  it "allows the existance of a TC to be determined" do
    tc = CdiscCl.new
    tc.identifier = "C85491"
    expect(tc.exists?).to eq(true)
  end

  it "allows the existance of a TC to be determined - not there" do
    tc = CdiscCl.new
    tc.identifier = "C85491x"
    expect(tc.exists?).to eq(false)
  end

  it "allows two CLs to be compared, same" do
    tc1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    tc2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    result = CdiscCl.diff?(tc1, tc2)
    expect(result).to eq(false)    
  end

  it "allows two CLs to be compared, different" do
    tc1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCl.diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "allows the difference between two CLs to be found, same" do
    tc1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    tc2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    result = CdiscCl.difference(tc1, tc2)
    #write_yaml_file(result, sub_dir, "cdisc_cl_differences_1.yaml")
    expected = read_yaml_file(sub_dir, "cdisc_cl_differences_1.yaml")
    expect(result).to eq(expected) 
  end

  it "allows the difference between two CLs to be found, different" do
    tc1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCl.difference(tc1, tc2)
    #write_yaml_file(result, sub_dir, "cdisc_cl_differences_2.yaml")
    expected = read_yaml_file(sub_dir, "cdisc_cl_differences_2.yaml")
    expect(result).to eq(expected) 
  end

end