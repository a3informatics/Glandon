require 'rails_helper'

describe CdiscCl do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/cdisc_cl"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("CT_V39.ttl")
    load_test_file_into_triple_store("CT_V40.ttl")
    load_test_file_into_triple_store("CT_V41.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V47.ttl")
    load_test_file_into_triple_store("CT_V48.ttl")
    clear_iso_concept_object
  end

  it "allows an object to be initialised" do
    tc = CdiscCl.new
    result = 
      {
        :children => [],
        :definition => "",
        :extensible => false,
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
    expect(tc.errors.full_messages[0]).to eq("Identifier is empty")
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

  it "allows two CLs to be compared, same, new" do
    tc1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    tc2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    result = CdiscCl.new_diff?(tc1, tc2)
    expect(result).to eq(false)    
  end

  it "allows two CLs to be compared, different 1" do
    tc1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCl.diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "allows two CLs to be compared, different 1, new" do
    tc1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCl.new_diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "allows two CLs to be compared, different 2" do
    tc1 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    tc2 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    result = CdiscCl.diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "allows two CLs to be compared, different 2, new" do
    tc1 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    tc2 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    result = CdiscCl.new_diff?(tc1, tc2)
    expect(result).to eq(true)    
  end

  it "allows two CLs to be compared, different 3" do
    tc1 = CdiscCl.find("CL-C100129", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    tc2 = CdiscCl.find("CL-C100129", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    result1 = CdiscCl.diff?(tc1, tc2)
    result2 = CdiscCl.new_diff?(tc1, tc2)
    expect(result1).to eq(true)    
    expect(result2).to eq(true)    
  end

  it "allows the difference between two CLs to be found, same" do
    tc1 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    tc2 = CdiscCl.find("CL-C101843", "http://www.assero.co.uk/MDRThesaurus/CDISC/V39")
    result = CdiscCl.difference(tc1, tc2)
  #write_yaml_file(result, sub_dir, "differences_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "differences_expected_1.yaml")
    expect(result).to eq(expected) 
  end

  it "allows the difference between two CLs to be found, different 1" do
    tc1 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V40")
    tc2 = CdiscCl.find("CL-C66741", "http://www.assero.co.uk/MDRThesaurus/CDISC/V41")
    result = CdiscCl.difference(tc1, tc2)
  #write_yaml_file(result, sub_dir, "differences_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "differences_expected_2.yaml")
    expect(result).to eq(expected) 
  end

  it "allows the difference between two CLs to be found, different 2" do
    tc1 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    tc2 = CdiscCl.find("CL-C105137", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    result = CdiscCl.difference(tc1, tc2)
  #write_yaml_file(result, sub_dir, "differences_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "differences_expected_3.yaml")
    expect(result).to eq(expected) 
  end

  it "returns child identifiers" do
  	cl = CdiscCl.find("CL-C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47", false)
  	result = CdiscCl.child_identifiers(cl)
  	expected = ["C16352", "C41219", "C41259", "C41260", "C41261"] # RACE
    expect(result).to match_array(expected) 
    cl = CdiscCl.find("CL-C66731", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47", false)
  	result = CdiscCl.child_identifiers(cl)
  	expected = ["C16576", "C17998", "C20197", "C45908"] # SEX
    expect(result).to match_array(expected) 
  end

  it "generates a hash" do
    cl = CdiscCl.find("CL-C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47", false)
  #Xwrite_yaml_file(cl.to_hash, sub_dir, "to_hash_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_hash_expected.yaml")
    expect(cl.to_hash).to eq(expected)
    expect(cl.to_json).to eq(expected)
  end

  it "creates from a hash" do
    input = read_yaml_file(sub_dir, "from_hash_input.yaml")    
    cl = CdiscCl.from_hash(input)
  #Xwrite_yaml_file(cl.to_hash, sub_dir, "from_hash_expected.yaml")
    expected = read_yaml_file(sub_dir, "from_hash_expected.yaml")
    expect(cl.to_hash).to eq(expected)
    cl = CdiscCl.from_json(input)
    expect(cl.to_json).to eq(expected)
  end

  it "finds a child by parent and child identifier" do
    cl_1 = CdiscCl.find_child("C74457", "C41219", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    cl_2 = CdiscCl.find_child("C74457", "C41219", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    expect(cl_1.identifier).to eq(cl_2.identifier)
  #Xwrite_yaml_file(cl_1.to_json, sub_dir, "find_child_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "find_child_expected_1.yaml")
    expect(cl_1.to_json).to eq(expected)
  #Xwrite_yaml_file(cl_2.to_json, sub_dir, "find_child_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "find_child_expected_2.yaml")
    expect(cl_2.to_json).to eq(expected)
  end

  it "finds a child by parent and child identifier, not found" do
    cl_1 = CdiscCl.find_child("C74457", "C41219XXX", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    expect(cl_1).to be_nil
  end

  it "finds a code list by identifier" do
    cl_1 = CdiscCl.find_by_identifier("C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    cl_2 = CdiscCl.find_by_identifier("C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
    expect(cl_1.identifier).to eq(cl_2.identifier)
  #Xwrite_yaml_file(cl_1.to_json, sub_dir, "find_by_identifier_1.yaml")
    expected = read_yaml_file(sub_dir, "find_by_identifier_1.yaml")
    expect(cl_1.to_json).to eq(expected)
  #Xwrite_yaml_file(cl_2.to_json, sub_dir, "find_by_identifier_2.yaml")
    expected = read_yaml_file(sub_dir, "find_by_identifier_2.yaml")
    expect(cl_2.to_json).to eq(expected)
  end    

  it "finds a child by parent and child identifier, not found" do
    cl_1 = CdiscCl.find_by_identifier("C74457XXX", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
    expect(cl_1).to be_nil
  end

  it "generates a CSV record with no header" do
    cl = CdiscCl.find_by_identifier("C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
  #Xwrite_yaml_file(cl.to_csv_no_header(cl.identifier), sub_dir, "to_csv_no_header_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "to_csv_no_header_expected_1.yaml")
    expect(cl.to_csv_no_header(cl.identifier)).to eq(expected)
  end

  it "generates a CSV 'file'" do
    cl = CdiscCl.find_by_identifier("C74457", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
  #Xwrite_text_file_2(cl.to_csv, sub_dir, "to_csv_expected_1.txt")
    expected = read_text_file_2(sub_dir, "to_csv_expected_1.txt")
    expect(cl.to_csv).to eq(expected)
  end

end