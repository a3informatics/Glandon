require 'rails_helper'

describe ModelHelpers do
	
	include DataHelpers
  
  def sub_dir
    return "models/concerns/model_helpers"
  end

  class KlassA 
		include ModelHelpers
	end

	it "builds a URI" do
		expect(KlassA.uri("http://www.example.com/", "fred" ).to_s).to eq("http://www.example.com/#fred")
		a = KlassA
		expect(a.uri("http://www.example.com/", "fred" ).to_s).to eq("http://www.example.com/#fred")
	end

  it "obtains a URI in reference form" do
    expect(KlassA.uri_ref("http://www.example.com/", "fred" )).to eq("<http://www.example.com/#fred>")
		a = KlassA
    expect(a.uri_ref("http://www.example.com/", "fred" )).to eq("<http://www.example.com/#fred>")
  end

  it "extracts the Id from an URI" do
    expect(KlassA.extract_id("http://www.example.com/path#fred")).to eq("fred")
		a = KlassA
    expect(a.extract_id("http://www.example.com/path#fred")).to eq("fred")
  end

  it "extracts the namespace from an URI" do
    expect(KlassA.extract_namespace("http://www.example.com/path#fred")).to eq("http://www.example.com/path")
		a = KlassA
    expect(a.extract_namespace("http://www.example.com/path#fred")).to eq("http://www.example.com/path")
  end

  it "allows values to be extracted from XML" do
    a = KlassA
    xml = "<?xml version=\"1.0\"?>" +
      "<sparql xmlns=\"http://www.w3.org/2005/sparql-results#\">" +
        "<head>" +
          "<variable name=\"a\"/>" +
          "<variable name=\"b\"/>" +
        "</head>" +
        "<results>" +
          "<result>" +
            "<binding name=\"a\">" +
              "<uri>http://www.assero.co.uk/BusinessForm#Question</uri>" +
            "</binding>" +
            "<binding name=\"b\">" +
              "<literal>Race</literal>" +
            "</binding>" +
          "</result>" +
        "</results>" +
      "</sparql>"
    xmlDoc = Nokogiri::XML(xml)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      expect(KlassA.node_value('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(a.node_value('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(KlassA.node_value('b', false, node)).to eq ("Race")
      expect(a.node_value('b', false, node)).to eq ("Race")
    end
  end

  it "allows detects multiple values and prevents from being extracted from XML" do
    a = KlassA
    xml = "<?xml version=\"1.0\"?>" +
      "<sparql xmlns=\"http://www.w3.org/2005/sparql-results#\">" +
        "<head>" +
          "<variable name=\"a\"/>" +
          "<variable name=\"b\"/>" +
        "</head>" +
        "<results>" +
          "<result>" +
            "<binding name=\"a\">" +
              "<uri>http://www.assero.co.uk/BusinessForm#Question</uri>" +
            "</binding>" +
            "<binding name=\"b\">" +
              "<literal>Race1</literal>" +
            "</binding>" +
            "<binding name=\"b\">" +
              "<literal>Race2</literal>" +
            "</binding>" +
          "</result>" +
        "</results>" +
      "</sparql>"
    xmlDoc = Nokogiri::XML(xml)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      expect(KlassA.node_value('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(a.node_value('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(KlassA.node_value('b', false, node)).to eq ("")
      expect(a.node_value('b', false, node)).to eq ("")
    end
  end

  it "performs a query and returns the results" do
  	a = KlassA
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    query = %Q{
    	#{UriManagement.buildNs("", [])}
      SELECT ?a ?b ?c WHERE
      {
        ?a rdf:type ?b .
        ?a rdfs:label ?c .
      } ORDER BY ASC(?c)
    }
    nodes = KlassA.query_and_result(query)
  #write_text_file_2(nodes.to_s, sub_dir, "query_and_result_expected.txt")
    expected = read_text_file_2(sub_dir, "query_and_result_expected.txt")
    expect(nodes.count).to eq(18)
    expect(nodes.to_s).to eq(expected)
    nodes = a.query_and_result(query)
    expect(nodes.count).to eq(18)
    expect(nodes.to_s).to eq(expected)
  end

end