require 'rails_helper'

describe IsoConcept::ExtendedProperty do
	
	it "allows for a property to be created" do  
    test_json = 
      { 
        identifier: "new 1", 
        datatype: "integer", 
        label: "A value to decided how many stars you get", 
        definition: "Definition" 
      }
    object = IsoConcept::ExtendedProperty.new(test_json)
    expect(object.to_json).to eq(test_json)
  end

  it "allows for a property to be output as SPARQL" do  
    test_json = 
      { 
        identifier: "new 1", 
        datatype: "integer", 
        label: "A value to decided how many stars you get", 
        definition: "Definition" 
      }
    test_sparql = "PREFIX owl: <http://www.w3.org/2002/07/owl#>\n" +
       "PREFIX isoC: <http://www.assero.co.uk/ISO11179Concepts#>\n" +
       "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" +
       "{ \n" +
       "<http://wwww.xyz.com/test#new1> rdf:type owl:DatatypeProperty . \n" +
       "<http://wwww.xyz.com/test#new1> rdfs:subPropertyOf isoC:extensionProperty . \n" +
       "<http://wwww.xyz.com/test#new1> rdfs:domain <http://wwww.xyz.com/test#BBB> . \n" +
       "<http://wwww.xyz.com/test#new1> rdfs:label \"A value to decided how many stars you get\"^^xsd:string . \n" +
       "<http://wwww.xyz.com/test#new1> rdfs:range xsd:integer . \n" +
       "<http://wwww.xyz.com/test#new1> skos:definition \"Definition\"^^xsd:string . \n" +
       "}"
    object = IsoConcept::ExtendedProperty.new(test_json)
    uri1 = UriV2.new ({id: "AAA", namespace: "http://wwww.xyz.com/test"})
    uri2 = UriV2.new ({id: "BBB", namespace: "http://wwww.xyz.com/test"})
    uri3 = UriV2.new ({id: "new1", namespace: "http://wwww.xyz.com/test"})
    sparql = SparqlUpdateV2.new
    expect(object.to_sparql_v2(sparql, uri1, uri2).to_json).to eq(uri3.to_json)
    expect(sparql.to_s).to eq(test_sparql)
  end

  it "allows for a property to be output as JSON" do  
    test_json = 
      { 
        identifier: "new 1", 
        datatype: "integer", 
        label: "A value to decided how many stars you get", 
        definition: "Definition" 
      }
    object = IsoConcept::ExtendedProperty.new(test_json)
    expect(object.to_json).to eq(test_json)
  end

end