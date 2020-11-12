require 'rails_helper'

describe Rest do
	
	include DataHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("crud_spec.ttl")
  end

  def query_results(response)
    results = []
    doc = Nokogiri::XML(response.body)
    doc.remove_namespaces!
    doc.xpath("//result").each do |result|
      results << result
    end
    results
  end

  def get_value(name, uri, node)
    path = "binding[@name='" + name + "']/"
    if uri 
      path = path + "uri"
    else
      path = path + "literal"
    end
    valueArray = node.xpath(path)
    if valueArray.length == 1
      return valueArray[0].text
    else
      return ""
    end
  end

  it "sends a request, simple" do
  	endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b 'Adverse Events' .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(1)
    expect(get_value("b", true, results[0])).to eq("http://www.w3.org/2000/01/rdf-schema#label")
	end

  it "sends a request, escaped characters I" do
    endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c . filter contains(?c,'Are:\\r\\n\\r\\n*') .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(1)
    expect(get_value("b", true, results[0])).to eq("http://www.assero.co.uk/schema#explanatoryComment")
  end

  it "sends a request, escaped characters II" do
    endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c . filter contains(?c,'\\\\') .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(2)
    expect(get_value("b", true, results[0])).to eq("http://www.assero.co.uk/schema#extra2")
    expect(get_value("b", true, results[1])).to eq("http://www.assero.co.uk/schema#extra1")
  end

  it "sends a request, escaped characters III" do
    endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c . filter contains(?c,'\\\\\\\\') .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(1)
    expect(get_value("b", true, results[0])).to eq("http://www.assero.co.uk/schema#extra1")
  end

  it "sends a request, escaped characters IV" do
    endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c . filter contains(?c,'%26') .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(1)
    expect(get_value("b", true, results[0])).to eq("http://www.assero.co.uk/schema#extra3")
  end

  it "sends a request, escaped characters V" do
    endpoint = "http://localhost:3030/test/query"
    method = :post
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c . filter contains(?c,'%25') .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(1)
    expect(get_value("b", true, results[0])).to eq("http://www.assero.co.uk/schema#extra3")
  end

  it "sends a file" do
    # Simple test data
    testDir = Rails.root.join("db","load", "test")
    filename = File.join(testDir, "crud_spec.ttl")
    endpoint = "http://localhost:3030/test/upload"
    method = :post
    headers = {"Content-type" => "multipart/form-data"}
    response = Rest.send_file(endpoint, method, "", "", filename, headers)
    endpoint = "http://localhost:3030/test/query"
    data = "query=SELECT ?a ?b ?c WHERE {?a ?b ?c .}"
    headers = {"Accept" => "application/sparql-results+xml", "Content-type" => "application/x-www-form-urlencoded"}
    response = Rest.send_request(endpoint, method, "", "", data, headers)
    results = query_results(response)
    expect(results.count).to eq(9)
  end

end