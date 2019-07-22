require 'rails_helper'

describe Sparql::Query::Results::Result::Column do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/query/results/result/column"
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

  it "allows for the class to be created, URI" do
    bindings = @nodes.first.xpath("binding")
		result = Sparql::Query::Results::Result::Column.new(bindings.first)
    expect(result.name).to eq("s")
    expect(result.value.to_s).to eq("http://www.assero.co.uk/MDRItems#RAI-123456789")
	end

  it "allows for the hash to be returned" do
    bindings = @nodes[3].xpath("binding")
    result = Sparql::Query::Results::Result::Column.new(bindings.first)
    expect(result.to_hash).to eq({:name=>"s", :value=>"http://www.assero.co.uk/MDRItems#RA-123456789"})
  end

  it "allows for the class to be created, literal with <>" do
    bindings = @nodes.last.xpath("binding")
    result = Sparql::Query::Results::Result::Column.new(bindings.last)
    expect(result.to_hash).to eq({:name=>"o", :value=> "AAA << TEST >> Long"})
  end

  it "speed test" do
    bindings = @nodes.first.xpath("binding")
    timer_start
    (1..1000).each {|x| result = Sparql::Query::Results::Result::Column.new(bindings.first)}
    timer_stop("1000 new calls")
  end

end