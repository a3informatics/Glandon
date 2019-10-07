require 'rails_helper'

describe SparqlUpdateV2 do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql_update_v2"
  end

  before :each do
    data_files = []
    load_files(schema_files, data_files)
  end

  it "allows for the class to be created" do
		sparql = SparqlUpdateV2.new()
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
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\"^^xsd:string . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\" . \n" +
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
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"2012-01-01T12:34:56%2B01:00\"^^xsd:dateTime . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"2012-01-01T12:34:56%2B01:00\" . \n" +
      "<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\"^^xsd:string . \n" +
      #"<http://www.example.com/test#sss> <http://www.example.com/test#ooo2> \"hello world\" . \n" +
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
    expect{sparql.triple({:uri => s_uri}, {:literal => "error", :primitive_type => "string"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: {:literal=>\"error\", :primitive_type=>\"string\"}")
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
    expect{sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:literal => "hello world", :primitive_type => "string"})}.to raise_error(Errors::ApplicationLogicError, "No default namespace available and namespace not set. Args: {:namespace=>\"\", :id=>\"#ooo2\"}")
  end

  it "put a empty prefix in the object position with no default namespace" do
    sparql = SparqlUpdateV2.new()
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, {:uri => o_uri})
    literal = {:prefix => "", :id => "ooo3"}
    expect{sparql.triple({:uri => s_uri}, {:namespace => "http://www.example.com/test", :id => "#ooo2"}, literal)}.to raise_error(Errors::ApplicationLogicError, "No default namespace available and prefix not set. Args: #{literal}")
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

  it "encodes update query and reads back" do
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo4"}, {:literal => "+/aaa&\n\r\t", :primitive_type => "string"})
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
      expect(obj).to eq("+/aaa&\n\r\t")
    end
  end

  it "encodes updates and loads file and reads back" do
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/default")
    s_uri = UriV2.new({:uri => "http://www.example.com/test#sss"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    sparql.triple({:uri => s_uri}, {:namespace => "", :id => "#ooo4"}, {:literal => "+/ \\ \"test\" 'aaa \\ \" ' / & \n\r\t", :primitive_type => "string"})
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
    sparql = SparqlUpdateV2.new()
    sparql.default_namespace("http://www.example.com/def")
    s1_uri = UriV2.new({:uri => "http://www.example.com/def#sss1"})
    s2_uri = UriV2.new({:uri => "http://www.example.com/test#sss2"})
    s3_uri = UriV2.new({:uri => "http://www.example.com/test#sss3"})
    s4_uri = UriV2.new({:uri => "http://www.example.com/test#sss4"})
    s5_uri = UriV2.new({:uri => "http://www.example.com/test#sss5"})
    s6_uri = UriV2.new({:uri => "http://www.example.com/test#sss6"})
    s7_uri = UriV2.new({:uri => "http://www.example.com/test#sss7"})
    o_uri = UriV2.new({:uri => "http://www.example.com/test#ooo"})
    p_uri = UriV2.new({:uri => "http://www.example.com/test#ppp"})
    sparql.triple({:uri => s1_uri}, {:uri => p_uri}, {:uri => o_uri},)
    sparql.triple({:uri => s1_uri}, {:namespace => "", :id => "#ooo2"}, {:uri => o_uri})
    sparql.triple({:uri => s1_uri}, {:namespace => "", :id => "#ooo3"}, {:prefix => "", :id => "#ooo4"})
    sparql.triple({:uri => s1_uri}, {:namespace => "", :id => "#ooo4"}, {:literal => "+/%aaa&\n\r\t", :primitive_type => "string"})
    sparql.triple({:uri => s7_uri}, {:prefix => "bd", :id => "#ooo5"}, {:literal => "A \"string\" 1", :primitive_type => "string"})
    sparql.triple({:uri => s7_uri}, {:prefix => "bd", :id => "#ooo6"}, {:literal => "A string 2", :primitive_type => "string"})
    sparql.triple({:uri => s7_uri}, {:prefix => "bd", :id => "#ooo7"}, {:literal => "A string 3", :primitive_type => "string"})
    bulk = 200000
    count = bulk + 40
    (1..10).each {|c| sparql.triple({:uri => s2_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.triple({:uri => s3_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.triple({:uri => s4_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..10).each {|c| sparql.triple({:uri => s5_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    (1..bulk).each {|c| sparql.triple({:uri => s6_uri}, {:namespace => "", :id => "#o#{c}"}, {:literal => "literal #{c}", :primitive_type => "string"})}
    timer_start    
    full_path = sparql.to_file
    timer_stop("#{count} triple file took: ")
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "to_file_expected_1.txt")
    actual = read_text_file_full_path(full_path)
    expected = read_text_file_2(sub_dir, "to_file_expected_1.txt")
    expect(actual).to eq(expected)
  end
end