require 'rails_helper'

describe IsoScopedIdentifier do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
    load_test_file_into_triple_store("IsoScopedIdentifier.ttl")
  end

  it "validates a valid object" do
    result = IsoScopedIdentifier.new
    result.version = 123
    result.versionLabel = "Draft 123"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid version object" do
    result = IsoScopedIdentifier.new
    result.version = "123s"
    result.versionLabel = "Draft 123s"
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid version label object" do
    result = IsoScopedIdentifier.new
    result.version = 123
    result.versionLabel = "Draft 123£"
    expect(result.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id=>"SI-ACME_TEST-1", 
        :identifier => "TEST", 
        :version => 1, 
        :version_label => "0.1", 
        :namespace => 
          {
            :namespace => "http://www.assero.co.uk/MDRItems",
            :id => "NS-AAA",
            :name => "AAA Long",
            :shortName => "AAA"
          }
      }
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(IsoScopedIdentifier.new(triples).to_json).to eq(result)    
  end

  it "returns a list of all identifiers" do
    results = Array.new
    results << {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    results << {:identifier => "TEST2", :label => "Test Item 2", :owner_id => "NS-BBB", :owner => "BBB"}
    results << {:identifier => "TEST1", :label => "Test Item 1", :owner_id => "NS-BBB", :owner => "BBB"}
    expect(IsoScopedIdentifier.allIdentifier("TestItem", "http://www.assero.co.uk/MDRItems")).to eq(results)
  end

  it "allows the owner to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.owner).to eq("BBB")
  end

  it "allows the owner id to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.owner_id).to eq("NS-BBB")
  end

  it "allows the next version to be retrieved" do
    result = IsoScopedIdentifier.find("SI-TEST_1-1")
    expect(result.next_version).to eq(2)
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
    org = IsoNamespace.find("NS-BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.version = 3
    si.namespace = org
    expect(si.version_exists?).to eq(true)
  end

  it "detects if a identifier with version does not exist" do
    org = IsoNamespace.find("NS-BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.version = 2
    si.namespace = org
    expect(si.version_exists?).to eq(false)
  end

  it "detects if a identifier exists" do
    org = IsoNamespace.find("NS-BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3"
    si.namespace = org
    expect(si.exists?).to eq(true)
  end

  it "detects if a identifier does not exist" do
    org = IsoNamespace.find("NS-BBB")
    si = IsoScopedIdentifier.new
    si.identifier = "TEST3x"
    si.namespace = org
    expect(si.exists?).to eq(false)
  end

  it "finds a given id" do
    iso_namespace = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    result = {:id=>"SI-TEST_1-1", :identifier => "TEST1", :version => 1, :version_label => "0.1", :namespace => iso_namespace.to_json}
    expect(IsoScopedIdentifier.find("SI-TEST_1-1").to_json).to eq(result)
  end

  it "does not find an unknown id" do
    result = nil
    expect(IsoScopedIdentifier.find("SI-TEST_1-1x")).to eq(result)
  end

  it "allows all records to be returned" do
    results = Array.new
    iso_namespace = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    results << IsoScopedIdentifier.from_json({:id=>"SI-TEST_1-1", :identifier => "TEST1", :version => 1, :version_label => "0.1", :namespace => iso_namespace.to_json})
    results << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-3", :identifier => "TEST3", :version => 3, :version_label => "0.3", :namespace => iso_namespace.to_json})
    results << IsoScopedIdentifier.from_json({:id=>"SI-TEST_2-2", :identifier => "TEST2", :version => 2, :version_label => "0.2", :namespace => iso_namespace.to_json})
    results << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-4", :identifier => "TEST3", :version => 4, :version_label => "0.4", :namespace => iso_namespace.to_json})
    results << IsoScopedIdentifier.from_json({:id=>"SI-TEST_3-5", :identifier => "TEST3", :version => 5, :version_label => "0.5", :namespace => iso_namespace.to_json})
    expect(IsoScopedIdentifier.all.to_json).to eq(results.to_json)
  end

  it "allows an object to be created in the triple store" do
    org = IsoNamespace.find("NS-BBB")
    result = {:id=>"SI-BBB_NEW_1-1", :identifier => "NEW_1", :version => 1, :version_label => "0.1", :namespace => org.to_json}
    expect(IsoScopedIdentifier.create("NEW_1", 1, "0.1", org).to_json).to eq(result)
  end

  it "allows an object to be created from data" do
    org = IsoNamespace.find("NS-BBB")
    result = {:id=>"SI-BBB_NEW_1-1", :identifier => "NEW_1", :version => 1, :version_label => "0.1", :namespace => org.to_json}
    expect(IsoScopedIdentifier.from_data("NEW_1", 1, "0.1", org).to_json).to eq(result)
  end
  
  it "allows an object to be created from JSON" do
    org = IsoNamespace.find("NS-BBB")
    result = {:id=>"SI-NEW_1-1", :identifier => "NEW_1", :version => 1, :version_label => "0.1", :namespace => org.to_json}
    json = { :id => "SI-NEW_1-1", :identifier => "NEW_1", :version_label => "0.1", :version => 1, :namespace => org.to_json }
    expect(IsoScopedIdentifier.from_json(json).to_json).to eq(result)
  end
  
  it "allows an object to be exported as JSON" do
    org = IsoNamespace.find("NS-BBB")
    result = {:id=>"SI-TEST_3-4", :identifier => "TEST3", :version => 4, :version_label => "0.4", :namespace => org.to_json}
    expect(IsoScopedIdentifier.find("SI-TEST_3-4").to_json).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX mdrItems: <http://www.assero.co.uk/MDRItems#>\n" +
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
      "<http://www.assero.co.uk/MDRItems#SI-TEST_3-4> isoI:hasScope mdrItems:NS-BBB . \n" +
      "}"
    IsoScopedIdentifier.find("SI-TEST_3-4").to_sparql_v2(sparql)
    expect(sparql.to_s).to eq(result)
  end
  
  it "allows for an object to be updated" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.update({versionLabel: "0.10"})
    # Something here    
  end
  
  it "allows for an object to be destroyed" do
    object = IsoScopedIdentifier.find("SI-TEST_3-4")
    object.destroy
  end

  it "clears triple store" do
    clear_triple_store
  end

  it "allIdentifier handles empty response" do
    results = Array.new
    expect(IsoScopedIdentifier.allIdentifier("BBB", "http://www.assero.co.uk/MDRItems")).to eq(results)
  end

end
  