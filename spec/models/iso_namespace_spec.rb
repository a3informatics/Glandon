require 'rails_helper'

describe IsoNamespace do
	
	it "is valid with a id, namespace, name and shortName" do
		namespace = IsoNamespace.new()
		expect(namespace).to be_valid
	end
	
	it "determines namespace exists" do
		sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"AAA\"^^xsd:string . \n" +
      "}"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
        </head>
        <results>
          <result>
            <binding name="a">
              <uri>http://www.assero.co.uk/MDRItems#NS-ACME</uri>
            </binding>
          </result>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.exists?("AAA")).to eq(true)   
	end

	it "determines namespace does not exists" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"AAA\"^^xsd:string . \n" +
      "}"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
        </head>
        <results>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.exists?("AAA")).to eq(false)   
  end

  it "exists handles empty response" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"AAA\"^^xsd:string . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.exists?("AAA")).eql?(false)   
  end

	it "finds namespace by short name" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a ?c WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"AAA\"^^xsd:string . \n" +
      "  ?b isoB:name ?c . \n" +
      "}"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
          <variable name="c"/>
        </head>
        <results>
          <result>
            <binding name="a">
              <uri>http://www.assero.co.uk/MDRItems#NS-AAA</uri>
            </binding>
            <binding name="c">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">AAA Long</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.findByShortName("AAA")).eql?(result)   
  end

	it "determines namespace exists without query" do
    expect(IsoNamespace.exists?("AAA")).to eq(true)
  end

  it "finds namespace by short name without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(IsoNamespace.findByShortName("AAA")).eql?(result)  
  end

	it "findByShortName handles empty response" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a ?c WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"XXX\"^^xsd:string . \n" +
      "  ?b isoB:name ?c . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    result = IsoNamespace.new
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.findByShortName("XXX")).eql?(result)
  end

	it "finds namespace" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?b ?c WHERE \n" +
      "{\n" +
      "  :NS-BBB isoI:ofOrganization ?a . \n" +
      "  ?a isoB:shortName ?b . \n" +
      "  ?a isoB:name ?c . \n" +
      "}"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="b"/>
          <variable name="c"/>
        </head>
        <results>
          <result>
            <binding name="a">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">BBB</literal>
            </binding>
            <binding name="c">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">BBB Long</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    result = IsoNamespace.new
    result.id = "NS-BBB"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "BBB Long"
    result.shortName = "BBB"
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.find("NS-BBB")).eql?(result)   
  end

	it "finds namespace without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(IsoNamespace.find("NS-AAA")).eql?(result)  
  end

	it "find handles empty response" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?b ?c WHERE \n" +
      "{\n" +
      "  :NS-XXX isoI:ofOrganization ?a . \n" +
      "  ?a isoB:shortName ?b . \n" +
      "  ?a isoB:name ?c . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    result = IsoNamespace.new
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.find("NS-XXX")).eql?(result)  
  end

	it "all namespace" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a ?c ?d WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:Namespace . \n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName ?c . \n" +
      "  ?b isoB:name ?d . \n" +
      "}"
    sparql_result = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
          <variable name="c"/>
          <variable name="d"/>
        </head>
        <results>
          <result>
            <binding name="a">
              <uri>http://www.assero.co.uk/MDRItems#NS-AAA</uri>
            </binding>
            <binding name="c">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">AAA</literal>
            </binding>
            <binding name="d">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">AAA Long</literal>
            </binding>
          </result>
          <result>
            <binding name="a">
              <uri>http://www.assero.co.uk/MDRItems#NS-BBB</uri>
            </binding>
            <binding name="c">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">BBB</literal>
            </binding>
            <binding name="d">
              <literal datatype="http://www.w3.org/2001/XMLSchema#string">BBB Long</literal>
            </binding>
          </result>
        </results>
      </sparql>'
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    results = Hash.new
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    results["NS-AAA"] = result
    result = IsoNamespace.new
    result.id = "NS-BBB"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "BBB Long"
    result.shortName = "BBB"
    results["NS-BBB"] = result
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.all).eql?(results)   
  end

	it "all handles empty response" do
    sparql_query = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a ?c ?d WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:Namespace . \n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName ?c . \n" +
      "  ?b isoB:name ?d . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: sparql_result)
    results = Hash.new
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(IsoNamespace.all).eql?(results)  
  end

	it "create a namespace" do
    sparql_query1 = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"CCC\"^^xsd:string . \n" +
      "}"
    sparql_result1 = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
        </head>
        <results>
        </results>
      </sparql>'
    response1 = Typhoeus::Response.new(code: 200, body: sparql_result1)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query1, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response1)
    sparql_query2 = "update=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{\n" +
      "  :O-CCC rdf:type isoB:Organization . \n" +
      "  :O-CCC isoB:name \"CCC Long\"^^xsd:string . \n" +
      "  :O-CCC isoB:shortName \"CCC\"^^xsd:string . \n" +
      "  :NS-CCC rdf:type isoI:Namespace . \n" +
      "  :NS-CCC isoI:ofOrganization :O-CCC . \n" +
      "}"
    sparql_result2 = ""
    result = IsoNamespace.new
    result.id = "NS-CCC"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "CCC Long"
    result.shortName = "CCC"
    response2 = Typhoeus::Response.new(code: 200, body: sparql_result2)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/update', 
      :post, 
      '', 
      '', 
      sparql_query2, 
      {"Content-type"=> "application/x-www-form-urlencoded"}).and_return(response2)
    expect(response2).to receive(:success?).and_return(true)
    expect(IsoNamespace.create({shortName: "CCC", name: "CCC Long"})).eql?(result)  
	end

  it "create a namespace, error response" do
    sparql_query1 = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"CCC\"^^xsd:string . \n" +
      "}"
    sparql_result1 = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
        </head>
        <results>
        </results>
      </sparql>'
    response1 = Typhoeus::Response.new(code: 200, body: sparql_result1)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query1, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response1)
    sparql_query2 = "update=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{\n" +
      "  :O-CCC rdf:type isoB:Organization . \n" +
      "  :O-CCC isoB:name \"CCC Long\"^^xsd:string . \n" +
      "  :O-CCC isoB:shortName \"CCC\"^^xsd:string . \n" +
      "  :NS-CCC rdf:type isoI:Namespace . \n" +
      "  :NS-CCC isoI:ofOrganization :O-CCC . \n" +
      "}"
    sparql_result2 = ""
    response2 = Typhoeus::Response.new(code: 200, body: sparql_result2)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/update', 
      :post, 
      '', 
      '', 
      sparql_query2, 
      {"Content-type"=> "application/x-www-form-urlencoded"}).and_return(response2)
    expect(response2).to receive(:success?).and_return(false)
    expect {
      IsoNamespace.create({shortName: "CCC", name: "CCC Long"})
    }.to raise_error(Exceptions::CreateError)
  end

  it "does not create a namespace with an invalid shortname" do
    predicted_result = IsoNamespace.new
    actual_result = IsoNamespace.create({shortName: "CCC%$£@", name: "CCC Long"})
    expect(actual_result).eql?(predicted_result)
    expect(actual_result.errors.messages[:short_name]).to include("contains invalid characters or is empty") 
  end

	it "does not create a namespace with an invalid name" do
    predicted_result = IsoNamespace.new
    actual_result = IsoNamespace.create({shortName: "CCC", name: "CCC%$£@ Long"})
    expect(actual_result).eql?(predicted_result)
    expect(actual_result.errors.messages[:name]).to include("contains invalid characters or is empty") 
  end

  it "does not create a namespace that already exists" do
    sparql_query1 = "query=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName \"CCC\"^^xsd:string . \n" +
      "}"
    sparql_result1 = '<?xml version="1.0"?>
      <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
          <variable name="a"/>
        </head>
        <result>
            <binding name="a">
              <uri>http://www.assero.co.uk/MDRItems#NS-ACME</uri>
            </binding>
          </result>
      </sparql>'
    response1 = Typhoeus::Response.new(code: 200, body: sparql_result1)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/query', 
      :post, 
      '', 
      '', 
      sparql_query1, 
      {"Accept" => "application/sparql-results+xml", "Content-type"=> "application/x-www-form-urlencoded"}).and_return(response1)
    predicted_result = IsoNamespace.new
    actual_result = IsoNamespace.create({shortName: "CCC", name: "CCC Long"})
    expect(actual_result).eql?(predicted_result)
    expect(actual_result.errors.messages[:base]).to include("The short name entered is already in use.")
  end
  	
	it "destroy a namespace" do
    sparql_query = "update=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "DELETE DATA \n" +
      "{ \n" +
      "  :O-CCC rdf:type isoB:Organization . \n" +
      "  :O-CCC isoB:name \"CCC Long\"^^xsd:string . \n" +
      "  :O-CCC isoB:shortName \"CCC\"^^xsd:string . \n" +
      "  :NS-CCC rdf:type isoI:Namespace . \n" +
      "  :NS-CCC isoI:ofOrganization :O-CCC . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/update', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(response).to receive(:success?).and_return(true)
    object = IsoNamespace.new
    object.id = "NS-CCC"
    object.namespace = "http://www.assero.co.uk/MDRItems"
    object.name = "CCC Long"
    object.shortName = "CCC"
    object.destroy
  end

	it "destroy a namespace, error response" do
    sparql_query = "update=PREFIX : <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "DELETE DATA \n" +
      "{ \n" +
      "  :O-CCC rdf:type isoB:Organization . \n" +
      "  :O-CCC isoB:name \"CCC Long\"^^xsd:string . \n" +
      "  :O-CCC isoB:shortName \"CCC\"^^xsd:string . \n" +
      "  :NS-CCC rdf:type isoI:Namespace . \n" +
      "  :NS-CCC isoI:ofOrganization :O-CCC . \n" +
      "}"
    sparql_result = ""
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/mdr/update', 
      :post, 
      '', 
      '', 
      sparql_query, 
      {"Content-type"=> "application/x-www-form-urlencoded"}).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    object = IsoNamespace.new
    object.id = "NS-CCC"
    object.namespace = "http://www.assero.co.uk/MDRItems"
    object.name = "CCC Long"
    object.shortName = "CCC"
    expect {
      object.destroy
    }.to raise_error(Exceptions::DestroyError)
  end

end