require 'rails_helper'

describe IsoScopedIdentifier do
  
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
    load_test_file_into_triple_store("iso_scoped_identifier.ttl")
  end

  it "cleans an identifier" do
    result = IsoScopedIdentifier.clean_identifier("ACD123^&*")
    expect(result).to eq("ACD123")
    result = IsoScopedIdentifier.clean_identifier("acd123^&*")
    expect(result).to eq("ACD123")
    result = IsoScopedIdentifier.clean_identifier("acd 123^")
    expect(result).to eq("ACD 123")
    result = IsoScopedIdentifier.clean_identifier("acd@123^&*")
    expect(result).to eq("ACD 123")
  end

  it "validates a valid object" do
    result = IsoScopedIdentifier.new
    result.identifier = "ABC"
    result.version = 123
    result.versionLabel = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid version" do
    result = IsoScopedIdentifier.new
    result.identifier = "ABC"
    result.version = "123s"
    result.versionLabel = "Draft 123s"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid version label" do
    result = IsoScopedIdentifier.new
    result.identifier = "ABC"
    result.version = 123
    result.versionLabel = "Draft 123£"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid identifier" do
    result = IsoScopedIdentifier.new
    result.identifier = "ABC@"
    result.version = 123
    result.versionLabel = "Draft 123"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id=>"SI-ACME_TEST-1", 
        :identifier => "TEST", 
        :version => 1, 
        :version_label => "0.1", 
        :semantic_version => "1.2.4",
        :namespace => 
          {
            :uri => "http://www.assero.co.uk/NS#AAA",
            :name => "AAA Long",
            :short_name => "AAA",
            authority: "www.aaa.com",
            rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace" 
          }
      }
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/NS#AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#semanticVersion", object: "1.2.4" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(IsoScopedIdentifier.new(triples).to_json).to eq(result)    
  end

  it "returns a list of all identifiers" do
    expected = Array.new
    expected << {:identifier => "TESTSV 1", :label => "Test Item SV 1", :owner_uri => "http://www.assero.co.uk/NS#BBB", :owner => "BBB"}
    expected << {:identifier => "TESTSV 2", :label => "Test Item SV 2", :owner_uri => "http://www.assero.co.uk/NS#BBB", :owner => "BBB"}
    expected << {:identifier => "TEST3", :label => "Test Item 3", :owner_uri => "http://www.assero.co.uk/NS#BBB", :owner => "BBB"}
    expected << {:identifier => "TEST2", :label => "Test Item 2", :owner_uri => "http://www.assero.co.uk/NS#BBB", :owner => "BBB"}
    expected << {:identifier => "TEST1", :label => "Test Item 1", :owner_uri => "http://www.assero.co.uk/NS#BBB", :owner => "BBB"}
    results = IsoScopedIdentifier.allIdentifier("TestItem", "http://www.assero.co.uk/MDRItems")
    expect(results.count).to eq(5)
    results.each do |result|
      compare = expected.find{|x| x[:identifier] == result[:identifier]}
      expect(result.to_json).to eq(compare.to_json)
    end
  end

  it "allows the owner to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.owner).to eq("BBB")
  end

  it "allows the scoping namespace to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.scoping_namespace.uri).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "allows the next version to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.next_version).to eq(2)
  end

  it "allows the next semantic version to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_SV2-5")
    expect(result.next_semantic_version.to_s).to eq("3.2.0")
  end

  it "allows a check against a later version" do
    result = IsoScopedIdentifier.find("SI-TEST_3-3")
    expect(result.later_version?(2)).to eq(true)
  end

  it "allows a check against a later version" do
    result = IsoScopedIdentifier.find("SI-TEST_3-3")
    expect(result.later_version?(3)).to eq(false)
  end

  it "allows a check against a earlier version" do
    result = IsoScopedIdentifier.find("SI-TEST_3-3")
    expect(result.earlier_version?(4)).to eq(true)
  end

  it "allows a check against a earlier version" do
    result = IsoScopedIdentifier.find("SI-TEST_3-3")
    expect(result.earlier_version?(3)).to eq(false)
  end

  it "allows a check against a same version" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.same_version?(2)).to eq(false)
  end

  it "allows a check against a same version" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.same_version?(1)).to eq(true)
  end

  it "allows the first version to be found" do
    expect(IsoScopedIdentifier.first_version).to eq(1)
  end

  it "detects if a identifier exists" do
    result = IsoScopedIdentifier.find("SI-TEST_3-3")
    expect(result.exists?).to eq(true)
  end

  it "detects if a identifier with version exists" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.version = 3
    si.namespace = org
    expect(si.version_exists?).to eq(true)
  end

  it "detects if a identifier with version does not exist" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.version = 2
    si.namespace = org
    expect(si.version_exists?).to eq(false)
  end

  it "detects if a identifier exists" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.namespace = org
    expect(si.exists?).to eq(true)
  end

  it "detects if a identifier does not exist" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3x"
    si.namespace = org
    expect(si.exists?).to eq(false)
  end

  it "finds a given id" do
    iso_namespace = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      :id => "SI-TEST_1-1", 
      :identifier => "TEST1", 
      :version => 1, 
      :version_label => "0.1", 
      :semantic_version => "0.0.0", 
      :namespace => iso_namespace.to_h
    }
    expect(IsoScopedIdentifier.find("SI-TEST_1-1").to_json).to eq(result)
  end

  it "finds a given id, semantic version" do
    iso_namespace = IsoNamespace.find_by_short_name("BBB")
    result = 
    {
      :id => "SI-TEST_SV1-5", 
      :identifier => "TESTSV 1", 
      :version => 7, 
      :version_label => "0.7", 
      :semantic_version => "0.0.7", 
      :namespace => iso_namespace.to_h
    }
    expect(IsoScopedIdentifier.find("SI-TEST_SV1-5").to_json).to eq(result)
  end

  it "does not find an unknown id" do
    expect(IsoScopedIdentifier.find("SI-TEST_1-1x").id).to eq("")
  end

  it "allows all records to be returned" do
    expected = Array.new
    iso_namespace = IsoNamespace.find_by_short_name("BBB")
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_1-1", :identifier => "TEST1", :version => 1, :version_label => "0.1", :semantic_version => "0.0.0", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-3", :identifier => "TEST3", :version => 3, :version_label => "0.3", :semantic_version => "0.0.0", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_2-2", :identifier => "TEST2", :version => 2, :version_label => "0.2", :semantic_version => "0.0.0", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-4", :identifier => "TEST3", :version => 4, :version_label => "0.4", :semantic_version => "0.0.0", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-5", :identifier => "TEST3", :version => 5, :version_label => "0.5", :semantic_version => "0.0.0", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_SV1-5", :identifier => "TESTSV 1", :version => 7, :version_label => "0.7", :semantic_version => "0.0.7", :namespace => iso_namespace.to_h})
    expected << IsoScopedIdentifier.from_json({:id=>"SI-TEST_SV2-5", :identifier => "TESTSV 2", :version => 6, :version_label => "0.6", :semantic_version => "3.1.6", :namespace => iso_namespace.to_h})
    results = IsoScopedIdentifier.all
    expect(results.count).to eq(7)
    results.each do |result|
      compare = expected.find{|x| x.id == result.id}
      expect(result.to_json).to eq(compare.to_json)
    end
  end

  it "allows an object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {:id=>"SI-BBB_NEW1-1", :identifier => "NEW 1", :version => 1, :version_label => "0.1", :semantic_version => "1.2.3", :namespace => org.to_h}
    si = IsoScopedIdentifier.create("NEW 1", 1, "0.1", "1.2.3", org)
    expect(si.to_json).to eq(result)
    expect(si.errors.count).to eq(0)
  end

  it "does not allow a duplicate object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si1 = IsoScopedIdentifier.create("NEW 1", 1, "0.1", "1.2.3", org)
    si2 = IsoScopedIdentifier.create("NEW 1", 1, "0.1", "4.5.6", org)
    expect(si2.errors.count).to eq(1)
    expect(si2.errors.full_messages.to_sentence).to eq("The scoped identifier is already in use.")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {:id=>"SI-BBB_NEW_1-1", :identifier => "NEW@@@@ 1", :version => 1, :version_label => "0.1", :namespace => org.to_json}
    si = IsoScopedIdentifier.create("NEW@@@@ 1", 1, "0.1", "4.5.6", org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.create("NEW_1", 1, "0.1", "4.5.6", org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end

  it "does not allow an invalid object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    si = IsoScopedIdentifier.create("NEW-1", 1, "0.1", "4.5.6", org)
    expect(si.errors.count).to eq(1)
    expect(si.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
  end

  it "allows an object to be created from data" do
    org = IsoNamespace.find_by_short_name("BBB")
    sv = SemanticVersion.new major: 2, minor: 3
    result = {:id=>"SI-BBB_NEW_1-1", :identifier => "NEW_1", :version => 1, :version_label => "0.1", :semantic_version => "2.3.0", :namespace => org.to_h}
    expect(IsoScopedIdentifier.from_data("NEW_1", 1, "0.1", sv, org).to_json).to eq(result)
  end
  
  it "allows an object to be created from JSON" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {:id=>"SI-NEW_1-1", :identifier => "NEW_1", :version => 1, :version_label => "0.1", :semantic_version => "0.0.0", :namespace => org.to_h}
    json = { :id => "SI-NEW_1-1", :identifier => "NEW_1", :version_label => "0.1", :version => 1, :namespace => org.to_h }
    expect(IsoScopedIdentifier.from_json(json).to_json).to eq(result)
  end
  
  it "allows an object to be exported as JSON" do
    org = IsoNamespace.find_by_short_name("BBB")
    result = {:id=>"SI-TEST_3-4", :identifier => "TEST3", :version => 4, :version_label => "0.4", :semantic_version => "0.0.0", :namespace => org.to_h}
    expect(IsoScopedIdentifier.find("SI-TEST_3-4").to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:identifier \"TEST3\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> rdf:type isoI:ScopedIdentifier . \n" +
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:version \"4\"^^xsd:positiveInteger . \n" + 
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:versionLabel \"0.4\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:semanticVersion \"0.0.0\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:hasScope <http://www.assero.co.uk/NS#BBB> . \n" +
      "}"
    IsoScopedIdentifier.find("SI-TEST_3-4").to_sparql_v2(sparql)
    expect(sparql.to_s).to eq(result)
  end
  
  it "allows for an object to be updated, version label" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.update({versionLabel: "0.10"})
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    expect(object.errors.count).to eq(0)
    expect(object.versionLabel).to eq("0.10")
  end
  
  it "allows for an object to be updated, semantic version" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.update({semantic_version: :major})
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    expect(object.semantic_version.to_s).to eq("1.0.0")
    expect(object.errors.count).to eq(0)
  end
  
  it "allows for an object to be updated, semantic version & label" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.update({semantic_version: :major, versionLabel: "0.20"})
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    expect(object.versionLabel).to eq("0.20")
    expect(object.semantic_version.to_s).to eq("1.0.0")
    expect(object.errors.count).to eq(0)
  end
  
  it "prevents an object to be updated if invalid version label" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.update({versionLabel: "0.10±"})
    expect(object.errors.count).to eq(1)
  end
  
  it "allows for an object to be destroyed" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.destroy
  end

  it "handles a bad response error - update" do
    object = IsoScopedIdentifier.find("SI-TEST_3-5") # Note different object to previous test as it needs to exist.
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.update({versionLabel: "0.10"})}.to raise_error(Exceptions::UpdateError)
  end

  it "handles a bad response error - create" do
    org = IsoNamespace.find_by_short_name("BBB")
    allow_any_instance_of(IsoScopedIdentifier).to receive(:exists?).and_return(false)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{IsoScopedIdentifier.create("NEW1", 1, "0.1", "2.4.0", org)}.to raise_error(Exceptions::CreateError)
  end

  it "handles a bad response error - destroy" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.destroy}.to raise_error(Exceptions::DestroyError)
  end

  it "allIdentifier handles empty response" do
    results = Array.new
    expect(IsoScopedIdentifier.allIdentifier("BBB", "http://www.assero.co.uk/MDRItems")).to eq(results)
  end

  it "obtains the next version, does not exist" do
  	org = IsoNamespace.find_by_short_name("BBB")
  	version = IsoScopedIdentifier.next_version("XXXXXTEST1", org)
  	expect(version).to eq(1)
  end

  it "obtains the next version, exists" do
  	org = IsoNamespace.find_by_short_name("BBB")
  	version = IsoScopedIdentifier.next_version("TEST1", org)
  	expect(version).to eq(2)
  	version = IsoScopedIdentifier.next_version("TEST2", org)
  	expect(version).to eq(3)
  	version = IsoScopedIdentifier.next_version("TEST3", org)
  	expect(version).to eq(6)
  end

end
  