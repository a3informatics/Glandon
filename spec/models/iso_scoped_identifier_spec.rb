require 'rails_helper'

describe IsoScopedIdentifier do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_triple_store("IsoNamespace.ttl")
    load_triple_store("IsoScopedIdentifier.ttl")
  end

  it "shows an identifier exist" do
    expect(IsoScopedIdentifier.exists?("TEST1", "NS-BBB")).to eq(true)
  end

  it "shows an identifier does not exist" do
    expect(IsoScopedIdentifier.exists?("TEST11", "NS-BBB")).to eq(false)
  end

  it "returns a list of all identifiers" do
    results = Array.new
    results << {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    results << {:identifier => "TEST2", :label => "Test Item 2", :owner_id => "NS-BBB", :owner => "BBB"}
    results << {:identifier => "TEST1", :label => "Test Item 1", :owner_id => "NS-BBB", :owner => "BBB"}
    expect(IsoScopedIdentifier.allIdentifier("TestItem", "http://www.assero.co.uk/MDRItems")).to eq(results)
  end

  it "finds an item" do
    iso_namespace = IsoNamespace.from_json({id: "NS-XXX", namespace: "http://www.assero.co.uk/MDRItems", name: "XXX Long", shortName: "XXX"})
    result = {:identifier => "TEST1", :label => "Test Item 1", :owner_id => "NS-BBB", :owner => "BBB", :namespace => iso_namespace}
    expect(IsoScopedIdentifier.find("SI-TEST_1-1")).eql?(result)
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

  it "detects if a version exists" do
    expect(IsoScopedIdentifier.versionExists?("TEST3", 3, "NS-BBB")).to eq(true)
  end

  it "detects if a version exists" do
    expect(IsoScopedIdentifier.versionExists?("TEST3", 2, "NS-BBB")).to eq(false)
  end

  it "detects if a version exists" do
    expect(IsoScopedIdentifier.versionExists?("TEST3x", 1, "NS-BBB")).to eq(false)
  end

  it "detects if a version exists" do
    expect(IsoScopedIdentifier.versionExists?("TEST3", 1, "NS-BBBx")).to eq(false)
  end

  it "detects a given version" do
    org = IsoNamespace.find("NS-BBB")
    expect(IsoScopedIdentifier.versionExists?("TEST3", 3, org.id)).eql?(true)
  end

  it "finds a given id" do
    result = {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    expect(IsoScopedIdentifier.find("BC-TEST_3B")).eql?(result)
  end

  it "allows all records to be returned" do
    result = {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    expect(IsoScopedIdentifier.all).eql?(result)
  end

  it "allows an object to be created in the triple store" do
    result = {:identifier => "NEW_1", :owner_id => "NS-BBB", :owner => "BBB"}
    org = IsoNamespace.find("NS-BBB")
    expect(IsoScopedIdentifier.create("NEW_1", 1, "0.1", org)).eql?(result)
  end

  it "allows an object to be created from data" do
    result = {:identifier => "NEW_1", :owner_id => "NS-BBB", :owner => "BBB"}
    org = IsoNamespace.find("NS-BBB")
    expect(IsoScopedIdentifier.from_data("NEW_1", 1, "0.1", org)).eql?(result)
  end
  
  it "allows an object to be created from JSON" do
    result = {:identifier => "NEW_1", :owner_id => "NS-BBB", :owner => "BBB"}
    org = IsoNamespace.find("NS-BBB")
    json = { :id => "SI-NEW_1-1", :identifier => "NEW_1", :version_label => "0.1", :version => 1, :namespace => org.to_json }
    expect(IsoScopedIdentifier.from_data("NEW_1", 1, "0.1", org)).eql?(result)
  end
  
  it "allows an object to be exported as JSON" do
    result = {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    expect(IsoScopedIdentifier.find("BC-TEST_3B").to_json).eql?(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = {:identifier => "TEST3", :label => "Test Item 3", :owner_id => "NS-BBB", :owner => "BBB"}
    IsoScopedIdentifier.find("SI-TEST_3-4").to_sparql_v2(sparql)
    puts sparql.to_s
    expect(sparql.to_s).eql?(result)
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
  