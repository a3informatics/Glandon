require 'rails_helper'

describe Sparql::Update do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/update"
  end


  def create_simple_triple
    sparql = Sparql::Update.new()
    @s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    @p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    @o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    sparql.add({:uri => @s_uri}, {:uri => @p_uri}, {:uri => @o_uri},)
    return sparql
  end

  def check_simple_triple(s_uri, p_uri, o_uri, ontology=false)
    triples = [
      [s_uri.to_s, p_uri.to_s, o_uri.to_s],
      ["http://www.example.com/test", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.w3.org/2002/07/owl#Ontology"]
    ]
    xmlDoc = Nokogiri::XML(CRUD.query("#{UriManagement.buildNs("", [])}SELECT ?s ?p ?o WHERE { ?s ?p ?o }").body)
    xmlDoc.remove_namespaces!
    count = ontology ? 2 : 1
    expect(xmlDoc.xpath("//result").count). to eq(count) 
    xmlDoc.xpath("//result").each_with_index do |node, index|
      sub = ModelUtility.getValue('s', true, node)
      expect(sub.to_s).to eq(triples[index][0])
      pre = ModelUtility.getValue('p', true, node)
      expect(pre.to_s).to eq(triples[index][1])
      obj = ModelUtility.getValue('o', true, node)
      expect(obj.to_s).to eq(triples[index][2])
    end
  end

  before :each do
    clear_triple_store
  end

  after :all do
    delete_all_public_test_files
  end
  
  it "allows for the class to be created" do
		sparql = Sparql::Update.new()
    expect(sparql.to_json).to eq("{\"default_namespace\":\"\",\"prefix_used\":{},\"triples\":{}}")
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
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    expect(sparql.to_create_sparql).to eq(result)
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
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:uri => o_uri})
    expect(sparql.to_create_sparql).to eq(result)
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
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:prefix => "owl", :fragment => "ooo3"})
    expect(sparql.to_create_sparql).to eq(result)
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
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\"^^xsd:string . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\" . \n" +
      "}"
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:prefix => "owl", :fragment => "ooo3"})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect(sparql.to_create_sparql).to eq(result)
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
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"2012-01-01T12:34:56%2B01:00\"^^xsd:dateTime . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"2012-01-01T12:34:56%2B01:00\" . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\"^^xsd:string . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\" . \n" +
      "}"
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:prefix => "owl", :fragment => "ooo3"})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:literal => "2012-01-01T12:34:56+01:00", :primitive_type => "dateTime"})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect(sparql.to_create_sparql).to eq(result)
  end

  it "put a literal triple in the predicate position" do
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    expect{sparql.add({:uri => s_uri}, {:literal => "error", :primitive_type => "string"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: {:literal=>\"error\", :primitive_type=>\"string\"}")
  end

  it "put a empty namespace in the predicate position with no default namespace" do
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "#ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "#ooo2"}, {:prefix => "owl", :fragment => "ooo3"})
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})
    expect{sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo2"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(Errors::ApplicationLogicError, "No default namespace available and namespace not set. Args: {:namespace=>\"\", :fragment=>\"ooo2\"}")
  end

  it "put a empty prefix in the object position with no default namespace" do
    sparql = Sparql::Update.new()
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, {:uri => o_uri})
    literal = {:prefix => "", :fragment => "ooo3"}
    expect{sparql.add({:uri => s_uri}, {:namespace => "http://www.example.com/test", :fragment => "ooo2"}, literal)}.to raise_error(Errors::ApplicationLogicError, "No default namespace available and prefix not set. Args: #{literal}")
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
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo3"}, {:prefix => "", :fragment => "ooo4"})
    expect(sparql.to_create_sparql).to eq(result)
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
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo3"}, {:prefix => "", :fragment => "ooo4"})
    expect(sparql.to_create_sparql).to eq(result)
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
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo3"}, {:prefix => "", :fragment => "ooo4"})
    expect(sparql.to_update_sparql(s_uri)).to eq(result)
  end

  it "encodes update query and reads back" do
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo3"}, {:prefix => "", :fragment => "ooo4"})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "ooo4"}, {:literal => "+/aaa&\n\r\t", :primitive_type => "string"})
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
    expect(CRUD.update(sparql.to_create_sparql).body).to eq(sparql_result)
    xmlDoc = Nokogiri::XML(CRUD.query("#{UriManagement.buildNs("", [])}SELECT ?s ?p ?o WHERE { ?s ?p ?o }").body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      pre = ModelUtility.getValue('p', true, node)
      next if pre != "http://www.example.com/default#ooo4"
      obj = ModelUtility.getValue('o', false, node)
      expect(obj).to eq("+/aaa&\n\r\t")
    end
  end

  it "encodes updates and loads file and reads back" do
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV4.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "#ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "#ooo3"}, {:prefix => "", :fragment => "#ooo4"})
    sparql.add({:uri => s_uri}, {:namespace => "", :fragment => "#ooo4"}, {:literal => "+/ \\ \"test\" 'aaa \\ \" ' / & \n\r\t", :primitive_type => "string"})
    sparql_result = 
"<html>
<head>
</head>
<body>
<h1>Success</h1>
<p>
Triples = 5

<p>
</p>
<button onclick=\"timeFunction()\">Back to Fuseki</button>
</p>
<script type=\"text/javascript\">
function timeFunction(){
window.location.href = \"/fuseki.html\";}
</script>
</body>
</html>\n"
    file = sparql.to_file
    result_body = CRUD.file(file).body
    expect(result_body).to eq(sparql_result)
    xmlDoc = Nokogiri::XML(CRUD.query("#{UriManagement.buildNs("", [])}SELECT ?s ?p ?o WHERE { ?s ?p ?o }").body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      pre = ModelUtility.getValue('p', true, node)
      next if pre != "http://www.example.com/default#ooo4"
      obj = ModelUtility.getValue('o', false, node)
      expect(obj).to eq("+/ \\ \"test\" 'aaa \\ \" ' / & \n\r\t")
    end
  end

  it "saves triples to a file, large" do
    sparql = Sparql::Update.new()
    sparql.default_namespace("http://www.example.com/def")
    s1_uri = UriV4.new({:uri => "http://www.example.com/def#sss1"})
    s2_uri = UriV4.new({:uri => "http://www.example.com/test#sss2"})
    s3_uri = UriV4.new({:uri => "http://www.example.com/test#sss3"})
    s4_uri = UriV4.new({:uri => "http://www.example.com/test#sss4"})
    s5_uri = UriV4.new({:uri => "http://www.example.com/test#sss5"})
    s6_uri = UriV4.new({:uri => "http://www.example.com/test#sss6"})
    s7_uri = UriV4.new({:uri => "http://www.example.com/test#sss7"})
    o_uri = UriV4.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV4.new({:uri => "http://www.example.com/test#ppp"})
    sparql.add({:uri => s1_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.add({:uri => s1_uri}, {:namespace => "", :fragment => "ooo2"}, {:uri => o_uri})
    sparql.add({:uri => s1_uri}, {:namespace => "", :fragment => "ooo3"}, {:prefix => "", :fragment => "ooo4"})
    sparql.add({:uri => s1_uri}, {:namespace => "", :fragment => "ooo4"}, {:literal => "+/%aaa&\n\r\t", :primitive_type => "string"})
    sparql.add({:uri => s7_uri}, {:prefix => "bd", :fragment => "ooo5"}, {:literal => "A \"string\" 1", :primitive_type => "string"})
    sparql.add({:uri => s7_uri}, {:prefix => "bd", :fragment => "ooo6"}, {:literal => "A string 2", :primitive_type => "string"})
    sparql.add({:uri => s7_uri}, {:prefix => "bd", :fragment => "ooo7"}, {:literal => "A string 3", :primitive_type => "string"})
    bulk = 200000
    count = bulk + 40
    (1..10).each {|c| sparql.add({:uri => s2_uri}, {:namespace => "", :fragment => "o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.add({:uri => s3_uri}, {:namespace => "", :fragment => "o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.add({:uri => s4_uri}, {:namespace => "", :fragment => "o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.add({:uri => s5_uri}, {:namespace => "", :fragment => "o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..bulk).each {|c| sparql.add({:uri => s6_uri}, {:namespace => "", :fragment => "o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    timer_start    
    full_path = sparql.to_file
    timer_stop("#{count} triple file took: ")
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "to_file_expected_1.txt")
    actual = read_text_file_full_path(full_path)
    expected = read_text_file_2(sub_dir, "to_file_expected_1.txt")
    expect(actual).to eq(expected)
  end

  it "executes an create" do
    sparql = create_simple_triple
    sparql.create
    check_simple_triple(@s_uri, @p_uri, @o_uri)
  end

  it "executes an create, error" do
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    sparql = create_simple_triple
    expect(ConsoleLogger).to receive(:info)
    expect{sparql.create}.to raise_error(Errors::CreateError, "Failed to create an item in the database. SPARQL create failed.")
  end

  it "executes an update" do
    sparql = create_simple_triple
    sparql.create
    sparql = Sparql::Update.new()
    o_uri_new = UriV4.new({:uri => "http://www.example.com/test#oooNEW"})
    sparql.add({:uri => @s_uri}, {:uri => @p_uri}, {:uri => o_uri_new},)
    sparql.update(@s_uri)
    check_simple_triple(@s_uri, @p_uri, o_uri_new)
  end

  it "executes an update, error" do
    sparql = create_simple_triple
    sparql.create
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    sparql = Sparql::Update.new()
    o_uri_new = UriV4.new({:uri => "http://www.example.com/test#oooNEW"})
    sparql.add({:uri => @s_uri}, {:uri => @p_uri}, {:uri => o_uri_new},)
    expect(ConsoleLogger).to receive(:info)
    expect{sparql.update(@s_uri)}.to raise_error(Errors::UpdateError, "Failed to update an item in the database. SPARQL update failed.")
  end

  it "executes an file upload" do
    sparql = create_simple_triple
    sparql.default_namespace("http://www.example.com/test")
    sparql.upload
    check_simple_triple(@s_uri, @p_uri, @o_uri, true)
  end

  it "executes an file upload, error" do
    sparql = create_simple_triple
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendFile).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect(ConsoleLogger).to receive(:info)
    expect{sparql.upload}.to raise_error(Errors::CreateError, "Failed to upload and create an item in the database.")
  end

end