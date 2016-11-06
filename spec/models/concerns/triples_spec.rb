require 'rails_helper'

describe Triples do
  
  include DataHelpers

  it "allows a property to be found in triples" do
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(Triples.get_property_value(triples, "isoI", "version")).to eq("1")    
  end

  it "allows to determine if links exist within a set of triples" do
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(Triples.link_exists?(triples, "isoI", "hasScope")).to eq(true)    
  end

  it "allows to determine if links do not exist within a set of triples" do
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(Triples.link_exists?(triples, "isoI", "hasScopeX")).to eq(false)    
  end

  it "allows links to be found in triples" do
    result = []
    result[0] = "http://www.assero.co.uk/MDRItems#NS-AAA"
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(Triples.get_links(triples, "isoI", "hasScope")).to eq(result)    
  end

  it "does not allow links to be found that do not exist in triples" do
    result = []
    triples = [ 
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#hasScope", object: "http://www.assero.co.uk/MDRItems#NS-AAA" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#identifier", object: "TEST" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#version", object: "1" },
      { subject: "http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Identification#versionLabel", object: "0.1" }
    ]
    expect(Triples.get_links(triples, "isoI", "hasScopex")).to eq(result)    
  end
end
  