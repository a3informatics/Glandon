require 'rails_helper'

describe SparqlUpdateV2 do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql_update_v2"
  end

  before :each do
    clear_triple_store
  end

  it "allows for the class to be created" do
		sparql = SparqlUpdateV2.new()
    expect(sparql.to_json).to eq("{\"default_namespace\":\"\",\"prefix_set\":[],\"prefix_used\":{},\"triples\":[]}")
	end

  it "allows a URI triple to be added" do
    result = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    expect(sparql.to_s).to eq(result)
  end

  it "allows a Namespace Id triple to be added" do
    result = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> <http://www.example.com/test#ooo> . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    expect(sparql.to_s).to eq(result)
  end

  it "allows a Prefix Id triple to be added" do
    result = "PREFIX owl: <http://www.w3.org/2002/07/owl#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> owl:ooo3 . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "owl", :id => "ooo3"})
    expect(sparql.to_s).to eq(result)
  end

  it "allows a literal triple to be added" do
    result = "PREFIX owl: <http://www.w3.org/2002/07/owl#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> owl:ooo3 . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello+world\"^^xsd:string . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "owl", :id => "ooo3"})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect(sparql.to_s).to eq(result)
  end

  it "allows a literal triple to be added, dateTime" do
    result = "PREFIX owl: <http://www.w3.org/2002/07/owl#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> owl:ooo3 . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"2012-01-01T12%3A34%3A56%2B01%3A00\"^^xsd:dateTime . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello+world\"^^xsd:string . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "owl", :id => "ooo3"})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:literal => "2012-01-01T12:34:56+01:00", :primitive_type => "dateTime"})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect(sparql.to_s).to eq(result)
  end

  it "put a literal triple in the predicate position" do
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "owl", :id => "ooo3"})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect{sparql.triple({:uri => s_uri}, {:literal => "error", :primitive_type => "string"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(RuntimeError)
  end

  it "put a empty namespace in the predicate position with no default namespace" do
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "owl", :id => "ooo3"})
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect{sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(RuntimeError)
  end

  it "put a empty prefix in the object position with no default namespace" do
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    expect{sparql.triple(sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:prefix => "", :id => "ooo3"}))}.to raise_error(RuntimeError)
  end

  it "allows triples with a default namespace" do
    result = "PREFIX : <http://www.example.com/default#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo3> <http://www.example.com/default#ooo4> . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    expect(sparql.to_s).to eq(result)
  end

  it "creates new (overloaded name)" do
    result = "PREFIX : <http://www.example.com/default#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo3> <http://www.example.com/default#ooo4> . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    expect(sparql.create).to eq(result)
  end

  it "creates an update" do
    result = "PREFIX : <http://www.example.com/default#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "DELETE \n" +
      "{\n" +
      "<http://www.example.com/test#sss> ?p ?o . \n" +
      "}\n" +
      "INSERT \n" +
      "{\n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ppp> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo2> <http://www.example.com/test#ooo> . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/default#ooo3> <http://www.example.com/default#ooo4> . \n" +
      "}\n" +
      "WHERE \n" +
      "{\n" +
      "<http://www.example.com/test#sss> ?p ?o . \n" +
      "}"
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    expect(sparql.update(s_uri)).to eq(result)
  end

  it "encodes updates and loads and reads back" do
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo4"}, {:literal => "+/%aaa&\n\r\t", :primitive_type => "string"})
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
    expect(CRUD.update(sparql.to_s).body).to eq(sparql_result)
    xmlDoc = Nokogiri::XML(CRUD.query("#{UriManagement.buildNs("", [])}SELECT ?s ?p ?o WHERE { ?s ?p ?o }").body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      pre = ModelUtility.getValue('p', true, node)
      next if pre != "http://www.example.com/default#ooo4"
      obj = ModelUtility.getValue('o', false, node)
      expect(obj).to eq("+/%aaa&\n\r\t")
    end
  end

  it "saves triples to a file, large" do
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo4"}, {:literal => "+/%aaa&\n\r\t", :primitive_type => "string"})
    count = 200000
    (1..count).each {|c| sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    timer_start    
    full_path = sparql.to_file
    timer_stop("#{count} triple file took: ")
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "to_file_expected_1.txt")
    actual = read_text_file_full_path(full_path)
    expected = read_text_file_2(sub_dir, "to_file_expected_1.txt")
    expect(actual).to eq(expected)
  end
end