require 'rails_helper'

describe IsoScopedIdentifier do
  
  it "returns a list of all identifiers" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/ns#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoT: <http://www.assero.co.uk/ISO11179Types#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT DISTINCT ?d ?e ?f ?g WHERE \n" +
      "{\n" +
      "  ?a rdf:type :AAA . \n" +
      "  ?a isoI:hasIdentifier ?c . \n" +
      "  ?a rdfs:label ?e . \n" +
      "  ?c isoI:identifier ?d . \n" +
      "  ?c isoI:version ?g . \n" +
      "  ?c isoI:hasScope ?f . \n" +
      "} ORDER BY DESC(?g)"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="d"/>
          <variable name="e"/>
          <variable name="f"/>
          <variable name="g"/>
        </head>
        <results>
          <result>
            <binding name="d">
              <literal>CDISC_CT</literal>
            </binding>
            <binding name="e">
              <literal>Label for V3</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">3</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_CT</literal>
            </binding>
            <binding name="e">
              <literal>Label for V2</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">2</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_CT</literal>
            </binding>
            <binding name="e">
              <literal>label for V1</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">1</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_EXT</literal>
            </binding>
            <binding name="e">
              <literal>Label for V1</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-ACME</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">1</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    #rest = double(Rest)
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    namespace1 = IsoNamespace.new
    namespace1.shortName = "SHORT1"
    namespace1.id = "111"
    namespace2 = IsoNamespace.new
    namespace2.shortName = "SHORT2"
    namespace2.id = "222"
    results = Array.new
    results << {:identifier => "CDISC_CT", :label => "Label for V3", :owner_id => "111", :owner => "SHORT1"}
    results << {:identifier => "CDISC_EXT", :label => "Label for V1", :owner_id => "222", :owner => "SHORT2"}
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace).to receive(:find).with('NS-CDISC').and_return(namespace1)
    expect(IsoNamespace).to receive(:find).with('NS-CDISC').and_return(namespace1)
    expect(IsoNamespace).to receive(:find).with('NS-CDISC').and_return(namespace1)
    expect(IsoNamespace).to receive(:find).with('NS-ACME').and_return(namespace2)
    expect(IsoScopedIdentifier.allIdentifier("AAA", "http://www.assero.co.uk/ns")).to eq(results)
  end

  it "returns a list of all identifiers, ignoring blank identifiers" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/ns#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoT: <http://www.assero.co.uk/ISO11179Types#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT DISTINCT ?d ?e ?f ?g WHERE \n" +
      "{\n" +
      "  ?a rdf:type :AAA . \n" +
      "  ?a isoI:hasIdentifier ?c . \n" +
      "  ?a rdfs:label ?e . \n" +
      "  ?c isoI:identifier ?d . \n" +
      "  ?c isoI:version ?g . \n" +
      "  ?c isoI:hasScope ?f . \n" +
      "} ORDER BY DESC(?g)"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="d"/>
          <variable name="e"/>
          <variable name="f"/>
          <variable name="g"/>
        </head>
        <results>
          <result>
            <binding name="d">
              <literal></literal>
            </binding>
            <binding name="e">
              <literal>Label for V3</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">3</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_CT</literal>
            </binding>
            <binding name="e">
              <literal>Label for V2</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">2</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_CT</literal>
            </binding>
            <binding name="e">
              <literal>label for V1</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-CDISC</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">1</literal>
            </binding>
          </result>
          <result>
            <binding name="d">
              <literal>CDISC_EXT</literal>
            </binding>
            <binding name="e">
              <literal>Label for V1</literal>
            </binding>
            <binding name="f">
              <uri>http://www.assero.co.uk/MDRItems#NS-ACME</uri>
            </binding>
            <binding name="g">
              <literal datatype="http://www.w3.org/2001/XMLSchema#integer">1</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    #rest = double(Rest)
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    namespace1 = IsoNamespace.new
    namespace1.shortName = "SHORT1"
    namespace1.id = "111"
    namespace2 = IsoNamespace.new
    namespace2.shortName = "SHORT2"
    namespace2.id = "222"
    results = Array.new
    results << {:identifier => "CDISC_CT", :label => "Label for V2", :owner_id => "111", :owner => "SHORT1"}
    results << {:identifier => "CDISC_EXT", :label => "Label for V1", :owner_id => "222", :owner => "SHORT2"}
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace).to receive(:find).with('NS-CDISC').and_return(namespace1)
    expect(IsoNamespace).to receive(:find).with('NS-CDISC').and_return(namespace1)
    expect(IsoNamespace).to receive(:find).with('NS-ACME').and_return(namespace2)
    expect(IsoScopedIdentifier.allIdentifier("AAA", "http://www.assero.co.uk/ns")).to eq(results)
  end

  it "allIdentifier handles empty response" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/ns#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoT: <http://www.assero.co.uk/ISO11179Types#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT DISTINCT ?d ?e ?f ?g WHERE \n" +
      "{\n" +
      "  ?a rdf:type :AAA . \n" +
      "  ?a isoI:hasIdentifier ?c . \n" +
      "  ?a rdfs:label ?e . \n" +
      "  ?c isoI:identifier ?d . \n" +
      "  ?c isoI:version ?g . \n" +
      "  ?c isoI:hasScope ?f . \n" +
      "} ORDER BY DESC(?g)"
    sparql_result = ""
    #rest = double(Rest)
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    results = Array.new
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoScopedIdentifier.allIdentifier("AAA", "http://www.assero.co.uk/ns")).to eq(results)
  end

end
  