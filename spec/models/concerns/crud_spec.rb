require 'rails_helper'

describe CRUD do
	
	include DataHelpers

  it "clears triple store" do
    clear_triple_store
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
    expect(CRUD.query(sparql_query).body).to eq(sparql_result)
	end

  it "sends an insert update" do
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "INSERT DATA { tst:egbook3 dc:title \"This is an example title\" }"
    sparql_result = 
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
    expect(CRUD.update(sparql_query).body).to eq(sparql_result)
  end

  it "sends an delete update" do
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE DATA { tst:egbook3 dc:title \"This is an example title\" }"
    sparql_result = 
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
    expect(CRUD.update(sparql_query).body).to eq(sparql_result)
  end

  it "loads a file" do
    testDir = Rails.root.join("db","load", "test")
    filename = File.join(testDir, "crud_spec.ttl")
    sparql_result = "<html>\n<head>\n</head>\n<body>\n<h1>Success</h1>\n<p>\nTriples = 6\n\n<p>\n</p>\n<button onclick=\"timeFunction()\">Back to Fuseki</button>\n</p>\n<script type=\"text/javascript\">\nfunction timeFunction(){\nwindow.location.href = \"/fuseki.html\";}\n</script>\n</body>\n</html>\n"
    expect(CRUD.file(filename).body).to eq(sparql_result)
  end

  it "deletes triples" do
    sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE { <http://www.assero.co.uk/test#F-TEST> ?b ?c } WHERE { <http://www.assero.co.uk/test#F-TEST> ?b ?c }"
    sparql_result = 
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
    expect(CRUD.update(sparql_query).body).to eq(sparql_result)
  end

end