require 'rails_helper'

describe Sparql::Query::Results::Result do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/query/results/result"
  end

  def get_nodes
    xml = read_text_file_2(sub_dir, "xml_1.xml")
    xmlDoc = Nokogiri::XML(xml)
    xmlDoc.remove_namespaces!
    @nodes = xmlDoc.xpath("//result")
  end

  before :each do
    clear_triple_store
    get_nodes
  end

  it "allows for the class to be created, string" do
    result = Sparql::Query::Results::Result.new(@nodes.first)
  #Xwrite_yaml_file(result.to_hash, sub_dir, "new_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "new_expected_1.yaml")
    expect(result.to_hash).to eq(expected)
	end

end