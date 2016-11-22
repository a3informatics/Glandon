require 'rails_helper'

describe IsoNamespace do
	
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
  end

	it "can be filled from JSON" do
    result = IsoNamespace.new
    result.id = "NS-XXX"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "XXX Long"
    result.shortName = "XXX"
    expect(IsoNamespace.from_json({id: "NS-XXX", namespace: "http://www.assero.co.uk/MDRItems", name: "XXX Long", shortName: "XXX"}).to_json).to eq(result.to_json)
  end

	it "can be returned as JSON" do
    result = IsoNamespace.new
    result.id = "NS-XXX"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "XXX Long"
    result.shortName = "XXX"
    expect(result.to_json).to eq({id: "NS-XXX", namespace: "http://www.assero.co.uk/MDRItems", name: "XXX Long", shortName: "XXX"})
  end

  it "determines namespace exists" do
    namespace = IsoNamespace.new
    namespace.shortName = "AAA"
		expect(namespace.exists?).to eq(true)   
	end

	it "determines namespace does not exists" do
    namespace = IsoNamespace.new
    namespace.shortName = "AAA1"
    expect(namespace.exists?).to eq(false)   
  end

  it "finds namespace by short name" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(IsoNamespace.findByShortName("AAA").to_json).to eq(result.to_json)   
  end

	it "determines namespace exists without query" do
    namespace = IsoNamespace.new
    namespace.shortName = "AAA"
    expect(namespace.exists?).to eq(true) 
  end

  it "finds namespace by short name without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(IsoNamespace.findByShortName("AAA").to_json).to eq(result.to_json)  
  end

	it "finds namespace" do
    result = IsoNamespace.new
    result.id = "NS-BBB"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "BBB Pharma"
    result.shortName = "BBB"
    expect(IsoNamespace.find("NS-BBB").to_json).to eq(result.to_json)   
  end

	it "finds namespace without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(IsoNamespace.find("NS-AAA").to_json).to eq(result.to_json)  
  end

	it "all namespace" do
    results = Array.new
    result = IsoNamespace.new
    result.id = "NS-BBB"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "BBB Pharma"
    result.shortName = "BBB"
    results << result
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    results << result
    expect(IsoNamespace.all.to_json).to eq(results.to_json)   
  end

	it "create a namespace" do
    result = IsoNamespace.new
    result.id = "NS-CCC_NS"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "CCC Long"
    result.shortName = "CCC"
    ns = IsoNamespace.create({shortName: "CCC", name: "CCC Long"})
    expect(ns.to_json).to eq(result.to_json)  
	end

  it "does not create a namespace with an invalid shortname" do
    predicted_result = IsoNamespace.new
    predicted_result.name = "CCC Long"
    predicted_result.shortName = "CCC%$£@"
    actual_result = IsoNamespace.create({shortName: "CCC%$£@", name: "CCC Long"})
    expect(actual_result.to_json).to eq(predicted_result.to_json)
    expect(actual_result.errors.messages[:short_name]).to include("contains invalid characters") 
  end

  it "does not create a namespace with an invalid name" do
    predicted_result = IsoNamespace.new
    predicted_result.name = "CCC%$£@ Long"
    predicted_result.shortName = "CCC"
    actual_result = IsoNamespace.create({shortName: "CCC", name: "CCC%$£@ Long"})
    expect(actual_result.to_json).to eq(predicted_result.to_json)
    expect(actual_result.errors.messages[:name]).to include("contains invalid characters or is empty") 
  end

  it "does not create a namespace that already exists" do
    predicted_result = IsoNamespace.new
    predicted_result.name = "CCC Long"
    predicted_result.shortName = "CCC"
    actual_result = IsoNamespace.create({shortName: "CCC", name: "CCC Long"})
    expect(actual_result.to_json).to eq(predicted_result.to_json)
    expect(actual_result.errors.messages[:base]).to include("The short name entered is already in use.")
  end
    
  it "destroy a namespace" do
    object = IsoNamespace.new
    object.id = "NS-CCC"
    object.namespace = "http://www.assero.co.uk/MDRItems"
    object.name = "CCC Long"
    object.shortName = "CCC"
    object.destroy
  end

  it "determines if the namespace is valid" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAA"
    expect(result.valid?).to eq(true)   
  end

  it "determines the namespace is invalid with a invalid short name" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.shortName = "AAAaaa123^"
    expect(result.valid?).to eq(false)   
  end

  it "determines the namespace is invalid with a invalid name" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long£"
    result.shortName = "AAAaaa123XX"
    expect(result.valid?).to eq(false)   
  end

  it "clears triple store" do
    clear_triple_store
  end

  it "exists handles empty response" do
    namespace = IsoNamespace.new
    namespace.shortName = "AAA"
    expect(namespace.exists?).to eq(false)   
  end

  it "findByShortName handles empty response" do
    result = IsoNamespace.new
    expect(IsoNamespace.findByShortName("XXX").to_json).to eq(result.to_json)
  end

  it "find handles empty response" do
    result = IsoNamespace.new
    expect(IsoNamespace.find("NS-XXX").to_json).to eq(result.to_json)  
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
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/test/query', 
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
      "  :O-CCC_NS rdf:type isoB:Organization . \n" +
      "  :O-CCC_NS isoB:name \"CCC Long\"^^xsd:string . \n" +
      "  :O-CCC_NS isoB:shortName \"CCC\"^^xsd:string . \n" +
      "  :NS-CCC_NS rdf:type isoI:Namespace . \n" +
      "  :NS-CCC_NS isoI:ofOrganization :O-CCC_NS . \n" +
      "}"
    sparql_result2 = ""
    response2 = Typhoeus::Response.new(code: 200, body: sparql_result2)
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/test/update', 
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

  it "all handles empty response" do
    results = Array.new
    expect(IsoNamespace.all.to_json).to eq(results.to_json)  
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
    expect(Rest).to receive(:sendRequest).with('http://localhost:3030/test/update', 
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

  it "clears triple store" do
    clear_triple_store
  end

end