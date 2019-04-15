require 'rails_helper'

describe Thesaurus::ManagedConcept do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers

  def sub_dir
    return "models/thesaurus/managed_concept"
  end

  before :all  do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl"]
    data_files = ["thesaurus_concept.ttl"]
    load_files(schema_files, data_files)
  end

  it "allows an object to be initialised" do
    tc = Thesaurus::ManagedConcept.new
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
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    expect(tc.to_json).to eq(result)
  end

  it "allows validity of the object to be checked - error" do
    tc = Thesaurus::ManagedConcept.new
    valid = tc.valid?
    expect(valid).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Identifier is empty")
  end 

  it "allows validity of the object to be checked" do
    tc = Thesaurus::ManagedConcept.new
    tc.identifier = "AAA"
    tc.notation = "A"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00001"))
    expect(tc.identifier).to eq("A00001")    
  end

  it "allows a TC to be found - error" do
    expect{Thesaurus::ManagedConcept.find("THC-A00001x", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")}.to raise_error(Exceptions::NotFoundError)  
  end

  it "allows the existance of a TC to be determined" do
    tc = Thesaurus::ManagedConcept.new
    tc.identifier = "A00001"
    expect(tc.exists?).to eq(true)
  end

  it "allows the existance of a TC to be determined - not there" do
    tc = Thesaurus::ManagedConcept.new
    tc.identifier = "A00001x"
    expect(tc.exists?).to eq(false)
  end

  it "finds by properties, single" do
  	tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expected = Thesaurus::ManagedConcept.find("THC-A00002", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
  	results = tc.find_by_property({identifier: "A00002"})
  	expect(results[0].to_json).to eq(expected.to_json)
	end

  it "finds by properties, multiple" do
    tc = Thesaurus::ManagedConcept.find("THC-A00010", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
  	expected = Thesaurus::ManagedConcept.find("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
  	results = tc.find_by_property({notation: "ETHNIC SUBGROUP [1]", preferredTerm: "Ethnic Subgroup 1"})
  	expect(results[0].to_json).to eq(expected.to_json)
	end

  it "allows a new child TC to be added" do
    json = 
      {
        :children => [],
        :definition => "Other or mixed race",
        :extension_properties => [],
        :id => "",
        :identifier => "A00004",
        :label => "New",
        :namespace => "",
        :notation => "NEWNEW",
        :parentIdentifier => "",
        :preferredTerm => "New Stuff",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    new_object = tc.add_child(json)
    expect(new_object.errors.count).to eq(0)
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
	#write_yaml_file(tc.to_json, sub_dir, "thesaurus_concept_example_1.yaml")
		expected = read_yaml_file(sub_dir, "thesaurus_concept_example_1.yaml")
    expect(tc.to_json).to be_eql(expected)
  end

  it "prevents a duplicate TC being added" do
    json = 
      {
        :children => [],
        :definition => "Other or mixed race",
        :extension_properties => [],
        :id => "",
        :identifier => "A00004",
        :label => "New",
        :namespace => "",
        :notation => "NEWNEW",
        :parentIdentifier => "",
        :preferredTerm => "New Stuff",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    new_object = tc.add_child(json)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("The Thesaurus Concept, identifier A00001.A00004, already exists")
  end

  it "prevents a TC being added with invalid identifier" do
    json = 
      {
        :children => [],
        :definition => "Other or mixed race!",
        :extension_properties => [],
        :id => "THC-A00004",
        :identifier => "£",
        :label => "New",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :notation => "NEWNEW",
        :parentIdentifier => "",
        :preferredTerm => "New Stuff",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    new_object = tc.add_child(json)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("Identifier contains a part with invalid characters")
  end

  it "prevents a TC being added with invalid data" do
    json = 
      {
        :children => [],
        :definition => "Other or mixed race!@£$%^&*(){}",
        :extension_properties => [],
        :id => "THC-A00004",
        :identifier => "A0000411",
        :label => "New",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :notation => "NEWNEW",
        :parentIdentifier => "",
        :preferredTerm => "New Stuff",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    new_object = tc.add_child(json)
    expect(new_object.errors.count).to eq(1)
    expect(new_object.errors.full_messages[0]).to eq("Definition contains invalid characters")
  end

  it "allows a TC to be updated" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => "New",
        :notation => "NEWNEW AND",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => "New",
        :extension_properties => [],
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff",
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end

  it "allows a TC to be updated, label test" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => "New, really really new",
        :notation => "NEWNEW AND",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => "New, really really new",
        :extension_properties => [],
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff",
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end

  it "allows a TC to be updated, quotes test" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => "New",
        :notation => "NEWNEW AND",
        :synonym => "\"Quote\"",
        :definition => "Other or 'mixed' race new",
        :preferredTerm => "New Stuff \"and\" new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => "New",
        :extension_properties => [],
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND",
        :synonym => "\"Quote\"",
        :definition => "Other or 'mixed' race new",
        :preferredTerm => "New Stuff \"and\" new stuff",
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end
  
  it "allows a TC to be updated, character test" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => vh_all_chars,
        :notation => vh_all_chars + "^",
        :synonym => vh_all_chars,
        :definition => vh_all_chars,
        :preferredTerm => vh_all_chars
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => vh_all_chars,
        :extension_properties => [],
        :identifier => "A00001.A00004",
        :notation => vh_all_chars + "^",
        :synonym => vh_all_chars,
        :definition => vh_all_chars,
        :preferredTerm => vh_all_chars,
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end
  
  it "prevents a TC being updated with invalid data" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND!@£$%^&*()+^ and then the bad char ±",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => "",
        :extension_properties => [],
        :identifier => "A00004",
        :notation => "NEWNEW AND",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff",
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Notation contains invalid characters")
  end

  it "allows to determine if TCs different" do
    tc1 = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc2 = Thesaurus::ManagedConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = Thesaurus::ManagedConcept.diff?(tc1, tc2)
    expect(results).to eq(true)
  end

  it "allows to determine if TCs same" do
    tc1 = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc2 = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = Thesaurus::ManagedConcept.diff?(tc1, tc2)
    expect(results).to eq(false)
  end

  it "allows to determine if TCs different - notation" do
    tc1 = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc1.notation = "X"
    tc2 = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = Thesaurus::ManagedConcept.diff?(tc1, tc2)
    expect(results).to eq(true)
  end

  it "allows the object to be exported as JSON" do
    tc = Thesaurus::ManagedConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    result = 
      {
        :children => [],
        :definition => "Other or mixed race",
        :extension_properties => [],
        :id => "THC-A00021",
        :identifier => "A00021",
        :label => "Other or Mixed",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :notation => "OTHER OR MIXED",
        :parentIdentifier => "",
        :preferredTerm => "Other / Mixed",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    expect(tc.to_json).to eq(result)
  end

  it "allows a TC to be created from JSON" do
    json = 
      {
        :children => [],
        :definition => "Other or mixed race",
        :extension_properties => [],
        :id => "THC-A00021",
        :identifier => "A00021",
        :label => "Other or Mixed",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :notation => "OTHER OR MIXED",
        :parentIdentifier => "",
        :preferredTerm => "Other / Mixed",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    tc = Thesaurus::ManagedConcept.from_json(json)
    expect(tc.to_json).to eq(json)
  end

  it "allows a TC to be exported as SPARQL" do
    tc = Thesaurus::ManagedConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    result_uri = "http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021"
    parent_uri = UriV2.new({:id => "THC-A000XX", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"})
    result_sparql = "PREFIX iso25964: <http://www.assero.co.uk/ISO25964#>\n" +
       "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> rdf:type <http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept> . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> rdfs:label \"Other or Mixed\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> iso25964:identifier \"A00021\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> iso25964:notation \"OTHER OR MIXED\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> iso25964:preferredTerm \"Other / Mixed\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> iso25964:synonym \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> iso25964:definition \"Other or mixed race\"^^xsd:string . \n" +
       "}"
    sparql = SparqlUpdateV2.new
    expect(tc.to_sparql_v2(parent_uri, sparql).to_s).to eq(result_uri)
    expect(sparql.to_s).to eq(result_sparql)
  end
  
  it "allows a TC to be destroyed" do
    tc = Thesaurus::ManagedConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.exists?).to eq(true)
    result = tc.destroy
    expect(result).to eq(true)
    tc = Thesaurus::ManagedConcept.new
    tc.identifier = "A00021"
    expect(tc.exists?).to eq(false)
  end

  it "does not allow a TC to be destroyed if it has children I, called with children=true" do
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.exists?).to eq(true)
    result = tc.destroy
    expect(result).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("The Thesaurus Concept, identifier A00001, has children. It cannot be deleted.")
  end

  it "does not allow a TC to be destroyed if it has children II, called with children=false" do
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1", false)
    expect(tc.exists?).to eq(true)
    result = tc.destroy
    expect(result).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("The Thesaurus Concept, identifier A00001, has children. It cannot be deleted.")
  end

  it "handles a bad response error - add_child" do
    new_tc = 
      {
        :children => [],
        :definition => "Other or mixed race",
        :extension_properties => [],
        :id => "",
        :identifier => "A00005",
        :label => "New",
        :namespace => "",
        :notation => "NEWNEW",
        :parentIdentifier => "",
        :preferredTerm => "New Stuff",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#Thesaurus::ManagedConcept"
      }
    object = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    allow_any_instance_of(Thesaurus::ManagedConcept).to receive(:exists?).and_return(false) 
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{object.add_child(new_tc)}.to raise_error(Exceptions::CreateError)
  end

  it "handles a bad response error - update" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => "New",
        :notation => "NEWNEW AND",
        :synonym => "\"Quote\"",
        :definition => "Other or 'mixed' race new",
        :preferredTerm => "New Stuff \"and\" new stuff"
      }
    object = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{object.update(new_tc)}.to raise_error(Exceptions::UpdateError)
  end

  it "handles a bad response error - destroy" do
    object = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{object.destroy}.to raise_error(Exceptions::DestroyError)
  end

  it "set parent" do
    object = Thesaurus::ManagedConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(object.parentIdentifier).to eq("")
    object.set_parent
		expect(object.parentIdentifier).to eq("A00001")
  end

  it "generates a CSV record with no header" do
    tc = Thesaurus::ManagedConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expected = 
    [ 
      "A00001", "Vital Sign Test Codes Extension", 
      "VSTEST", "", "A set of additional Vital Sign Test Codes to extend the CDISC set.", ""
    ]
    expect(tc.to_csv_no_header).to eq(expected)
   end

end