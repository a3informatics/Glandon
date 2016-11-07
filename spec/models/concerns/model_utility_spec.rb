require 'rails_helper'

describe ModelUtility do
	
  it "builds a URI reference" do
    expect(ModelUtility.buildUri("http://www.example.com/", "fragment")).to eq("<http://www.example.com/#fragment>")
  end

  it "allows the fragment (CID) to be extracted from a URI" do
    expect(ModelUtility.extractCid("http://www.example.com/#fragment")).to eq("fragment")
  end

  it "handles error when attempting to extract the fragment from a URI with no fragement" do
    expect(ModelUtility.extractCid("http://www.example.com/")).to eq("")
  end

  it "handles error when attempting to extract the fragment from a invalid URI" do
    expect(ModelUtility.extractCid("string")).to eq("")
  end

  it "allows the namespace to be extracted from a URI" do
    expect(ModelUtility.extractNs("http://www.example.com/#fragment")).to eq("http://www.example.com/")
  end

  it "allows values to be extracted from XML" do
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
      expect(ModelUtility.getValue('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(ModelUtility.getValue('b', false, node)).to eq ("Race")
    end
  end

  it "allows detects multiple values and prevents from being extracted from XML" do
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
      expect(ModelUtility.getValue('a', true, node)).to eq ("http://www.assero.co.uk/BusinessForm#Question")
      expect(ModelUtility.getValue('b', false, node)).to eq ("")
    end
  end

end