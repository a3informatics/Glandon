require 'rails_helper'

describe ThesaurusConcept do

  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_test_file_into_triple_store("thesaurus_concept.ttl")
    clear_iso_concept_object
  end

  it "allows an object to be initialised" do
    tc = ThesaurusConcept.new
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
    tc = ThesaurusConcept.new
    valid = tc.valid?
    expect(valid).to eq(false)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Identifier is empty")
  end 

  it "allows validity of the object to be checked" do
    tc = ThesaurusConcept.new
    tc.identifier = "AAA"
    tc.notation = "A"
    valid = tc.valid?
    expect(valid).to eq(true)
  end 

  it "allows a TC to be found" do
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.identifier).to eq("A00001")    
  end

  it "allows a TC to be found - error" do
    expect{ThesaurusConcept.find("THC-A00001x", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")}.to raise_error(Exceptions::NotFoundError)  
  end

  it "allows the existance of a TC to be determined" do
    tc = ThesaurusConcept.new
    tc.identifier = "A00001"
    expect(tc.exists?).to eq(true)
  end

  it "allows the existance of a TC to be determined - not there" do
    tc = ThesaurusConcept.new
    tc.identifier = "A00001x"
    expect(tc.exists?).to eq(false)
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    new_json =
      {
        :children  => 
          [
            {
              :type=>"http://www.assero.co.uk/ISO25964#ThesaurusConcept",
              :id=>"THC-A00003",
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/ACME/V1",
              :label=>"Mid upper arm circumference",
              :extension_properties=>[],
              :identifier=>"A00003",
              :notation=>"MUAC",
              :synonym=>"",
              :definition=>"The measurement of the mid upper arm circumference",
              :preferredTerm=>"",
              :topLevel=>false,
              :parentIdentifier=>"A00001",
              :children=>[]
            },
            {
              :type=>"http://www.assero.co.uk/ISO25964#ThesaurusConcept",
              :id=>"THC-A00002",
              :namespace=>"http://www.assero.co.uk/MDRThesaurus/ACME/V1",
              :label=>"APGAR Score",
              :extension_properties=>[],
              :identifier=>"A00002",
              :notation=>"APGAR",
              :synonym=>"",
              :definition=>"An APGAR Score",
              :preferredTerm=>"",
              :topLevel=>false,
              :parentIdentifier=>"A00001",
              :children=>[]
            },
            {
              :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
              :id => "THC-A00001_A00004",
              :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
              :label => "New",
              :extension_properties => [],
              :identifier => "A00001.A00004",
              :notation => "NEWNEW",
              :synonym => "",
              :definition => "Other or mixed race",
              :preferredTerm => "New Stuff",
              :topLevel => false,
              :parentIdentifier=>"A00001",
              :children => []
            }
          ],
        :definition => "A set of additional Vital Sign Test Codes to extend the CDISC set.",
        :extension_properties => [],
        :id => "THC-A00001",
        :identifier => "A00001",
        :label => "Vital Sign Test Codes Extension",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :notation => "VSTEST",
        :parentIdentifier => "",
        :preferredTerm => "",
        :synonym => "",
        :topLevel => false,
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    new_object = tc.add_child(json)
    expect(new_object.errors.count).to eq(0)
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(new_json)
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
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
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
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
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end
  
  it "allows a TC to be updated, character test" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :label => "New",
        :notation => "NEWNEW AND",
        :synonym => "THE BROWN FOX JUMPS OVER THE LAZY DOG. the brown fox jumps over the lazy dog. 0123456789 .!?,'\"_-/\\()[]~#*=:;&|",
        :definition => "Other or 'mixed' race new",
        :preferredTerm => "New Stuff \"and\" new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
        :id => "THC-A00001_A00004",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1",
        :label => "New",
        :extension_properties => [],
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND",
        :synonym => "THE BROWN FOX JUMPS OVER THE LAZY DOG. the brown fox jumps over the lazy dog. 0123456789 .!?,'\"_-/\\()[]~#*=:;&|",
        :definition => "Other or 'mixed' race new",
        :preferredTerm => "New Stuff \"and\" new stuff",
        :topLevel => false,
        :parentIdentifier=>"",
        :children => []
      }
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(updated).to eq(true)
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.to_json).to eq(result)
  end
  
  it "prevents a TC being updated with invalid data" do
    new_tc = 
      {
        :identifier => "A00001.A00004",
        :notation => "NEWNEW AND!@£$%^&*()",
        :synonym => "And",
        :definition => "Other or mixed race new",
        :preferredTerm => "New Stuff and new stuff"
      }
    result =
      {
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
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
    tc = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    updated = tc.update(new_tc)
    expect(tc.errors.count).to eq(1)
    expect(tc.errors.full_messages[0]).to eq("Notation contains invalid characters")
  end

  it "allows to determine if TCs different" do
    tc1 = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc2 = ThesaurusConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = ThesaurusConcept.diff?(tc1, tc2)
    expect(results).to eq(true)
  end

  it "allows to determine if TCs same" do
    tc1 = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc2 = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = ThesaurusConcept.diff?(tc1, tc2)
    expect(results).to eq(false)
  end

  it "allows to determine if TCs different - notation" do
    tc1 = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    tc1.notation = "X"
    tc2 = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    results = ThesaurusConcept.diff?(tc1, tc2)
    expect(results).to eq(true)
  end

  it "allows the object to be exported as JSON" do
    tc = ThesaurusConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    tc = ThesaurusConcept.from_json(json)
    expect(tc.to_json).to eq(json)
  end

  it "allows a TC to be exported as SPARQL" do
    tc = ThesaurusConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    result_uri = "http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021"
    parent_uri = UriV2.new({:id => "THC-A000XX", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"})
    result_sparql = "PREFIX iso25964: <http://www.assero.co.uk/ISO25964#>\n" +
       "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A000XX_A00021> rdf:type <http://www.assero.co.uk/ISO25964#ThesaurusConcept> . \n" +
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
    tc = ThesaurusConcept.find("THC-A00021", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(tc.exists?).to eq(true)
    result = tc.destroy
    expect(result).to eq(true)
    tc = ThesaurusConcept.new
    tc.identifier = "A00021"
    expect(tc.exists?).to eq(false)
  end

  it "does not allow a TC to be destroyed if it has children" do
    tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
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
        :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
      }
    object = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    allow_any_instance_of(ThesaurusConcept).to receive(:exists?).and_return(false) 
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
    object = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{object.update(new_tc)}.to raise_error(Exceptions::UpdateError)
  end

  it "handles a bad response error - destroy" do
    object = ThesaurusConcept.find("THC-A00001_A00004", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{object.destroy}.to raise_error(Exceptions::DestroyError)
  end

end