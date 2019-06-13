require 'rails_helper'

describe Sparql::CRUD do
	
	include DataHelpers

  def update_success
"<html>
<head>
</head>
<body>
<h1>Success</h1>
<p>
Update succeeded
</p>
</body>
</html>\n"
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

  class SCTest
    include Sparql::CRUD
  end

  before :each do
    clear_triple_store
    @test_class = SCTest.new
  end

  it "sends a query" do
  	sparql_query = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a ?b ?c . \n" +
      "}"
    sparql_result = 
"<?xml version=\"1.0\"?>
<sparql xmlns=\"http://www.w3.org/2005/sparql-results#\">
  <head>
    <variable name=\"a\"/>
  </head>
  <results>
  </results>
</sparql>\n"
    expect(@test_class.send_query(sparql_query).body).to eq(sparql_result)
	end

  it "sends an insert update" do
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "INSERT DATA { tst:egbook3 dc:title \"This is an example title\" }"
    sparql_result = update_success
    expect(@test_class.send_update(sparql_query).body).to eq(sparql_result)
  end

  it "sends an delete update" do
    # Create simple data
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "INSERT DATA { tst:egbook3 dc:title \"This is an example title\" }"
    @test_class.send_update(sparql_query)
    # Test
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE DATA { tst:egbook3 dc:title \"This is an example title\" }"
    sparql_result = update_success
    expect(@test_class.send_update(sparql_query).body).to eq(sparql_result)
  end

  it "loads a file" do
    testDir = Rails.root.join("db","load", "test")
    filename = File.join(testDir, "crud_spec.ttl")
    sparql_result = "<html>\n<head>\n</head>\n<body>\n<h1>Success</h1>\n<p>\nTriples = 9\n\n<p>\n</p>\n<button onclick=\"timeFunction()\">Back to Fuseki</button>\n</p>\n<script type=\"text/javascript\">\nfunction timeFunction(){\nwindow.location.href = \"/fuseki.html\";}\n</script>\n</body>\n</html>\n"
    expect(@test_class.send_file(filename).body).to eq(sparql_result)
  end

  it "deletes triples" do
    # Simple test data
    testDir = Rails.root.join("db","load", "test")
    filename = File.join(testDir, "crud_spec.ttl")
    @test_class.send_file(filename)
    # Test
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE { <http://www.assero.co.uk/test#F-TEST> ?b ?c } WHERE { <http://www.assero.co.uk/test#F-TEST> ?b ?c }"
    sparql_result = update_success
    expect(@test_class.send_update(sparql_query).body).to eq(sparql_result)
  end

  it "update, encoding test I" do
    data = "This is an ++ &&& % \% \%\% [] \\\\\\\\ // \\\" \\n example title"
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "INSERT DATA { tst:egbook3 dc:title \"#{data}\" }"
    sparql_result = update_success
    expect(@test_class.send_update(sparql_query).body).to eq(sparql_result)
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "SELECT ?a ?c WHERE \n" +
      "{\n" +
      "  ?a dc:title ?c . \n" +
      "}"
    results = query_results(@test_class.send_query(sparql_query))
    expect(results.count).to eq(1)
    expect(get_value("c", false, results[0])).to eq("This is an ++ &&& % % %% [] \\\\ // \" \n example title")
  end

end