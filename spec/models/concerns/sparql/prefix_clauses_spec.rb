require 'rails_helper'

describe Sparql::PrefixClauses do
	
  include Sparql::PrefixClauses

	it "no default" do
  expected = 
    %Q{PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
}
  	expect(build_clauses("", [:bd, :isoI])).to eq(expected)
	end

  it "default symbol" do
  expected = 
    %Q{PREFIX : <http://www.assero.co.uk/ISO11179Concepts#>
PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
}
    expect(build_clauses(:isoC, [:bd, :isoI])).to eq(expected)
  end

  it "default namespace" do
  expected = 
    %Q{PREFIX : <http://www.example/com#>
PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
}
    expect(build_clauses("http://www.example/com", [:bd, :isoI])).to eq(expected)
  end

  it "empty array, namespace" do
  expected = 
    %Q{PREFIX : <http://www.example/com#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
}
    expect(build_clauses("http://www.example/com", [])).to eq(expected)
  end

  it "empty array, symbol" do
  expected = 
    %Q{PREFIX : <http://www.assero.co.uk/BusinessDomain#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
}
    expect(build_clauses(:bd, [])).to eq(expected)
  end

end