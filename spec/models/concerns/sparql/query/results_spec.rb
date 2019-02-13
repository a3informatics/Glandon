require 'rails_helper'

describe Sparql::Query::Results do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/query/results"
  end

  def get_nodes
    @xml = read_text_file_2(sub_dir, "xml_1.xml")
  end

  before :each do
    clear_triple_store
    get_nodes
  end

  it "allows for the class to be created" do
    result = Sparql::Query::Results.new(@xml)
  #Xwrite_yaml_file(result.to_hash, sub_dir, "new_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "new_expected_1.yaml")
    expect(result.to_hash).to eq(expected)
	end

  it "allows for the results to be presented by subject, default" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject
  #Xwrite_yaml_file(result, sub_dir, "by_subject_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
  end

  it "allows for the results to be presented by subject, string names" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject({subject: "s", predicate: "p", object: "o"})
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
  end

  it "allows for the results to be presented by subject, symbol names" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject({subject: :s, predicate: :p, object: :o})
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
  end

end