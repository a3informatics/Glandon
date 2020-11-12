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
    expect(result.ask?).to eq(false)
	end

  it "allows for single subject, error" do
    results = Sparql::Query::Results.new(@xml)
    expect{results.single_subject}.to raise_error(Errors::ApplicationLogicError, "Multiple entries found for single subject query.")
  end

  it "allows for single subject" do
    results = Sparql::Query::Results.new(read_text_file_2(sub_dir, "xml_5.xml"))
    result = results.single_subject
  #Xwrite_yaml_file(result, sub_dir, "single_subject_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "single_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
    expect(results.ask?).to eq(false)
  end

  it "allows for single subject as" do
    results = Sparql::Query::Results.new(read_text_file_2(sub_dir, "xml_5.xml"))
    result = results.single_subject_as(Fuseki::Base)
    expect(result.class.name).to eq("Thesaurus::ManagedConcept")
    check_file_actual_expected(result.to_h, sub_dir, "single_subject_as_expected_1.yaml")
  end

  it "allows for the results to be presented by subject, default" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject
  #Xwrite_yaml_file(result, sub_dir, "by_subject_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
    expect(results.ask?).to eq(false)
  end

  it "allows for the results to be presented by subject, string names" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject({subject: "s", predicate: "p", object: "o"})
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
    expect(results.ask?).to eq(false)
  end

  it "allows for the results to be presented by subject, symbol names" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_subject({subject: :s, predicate: :p, object: :o})
    expected = read_yaml_file(sub_dir, "by_subject_expected_1.yaml")
    expect(result).to triples_equal(expected)
    expect(results.ask?).to eq(false)
  end

  it "determines if results empty" do
    results = Sparql::Query::Results.new("")
    expect(results.empty?).to eq(true)
    results = Sparql::Query::Results.new(@xml)
    expect(results.empty?).to eq(false)
    expect(results.ask?).to eq(false)
  end

  it "returns results" do
    results = Sparql::Query::Results.new("")
    expect(results.results).to eq([])
    expect(results.ask?).to eq(false)
  end

  it "allows for the results to be presented by row and column" do
    results = Sparql::Query::Results.new(@xml)
    result = results.by_object_set([:s, "p", :o])
    check_file_actual_expected(result, sub_dir, "by_object_expected_1.yaml")
  end

  it "speed test" do
    timer_start
    (1..1000).each {|x| result = Sparql::Query::Results.new(@xml)}
    timer_stop("1000 new calls")
  end

  it "speed test II" do
    xml = read_text_file_2(sub_dir, "xml_2.xml")
    timer_start
    result = Sparql::Query::Results.new(xml)
    timer_stop("XML 2 call")
  end

  it "speed test III" do
    xml = read_text_file_2(sub_dir, "xml_3.xml")
    timer_start
    result = Sparql::Query::Results.new(xml)
    timer_stop("XML 3 call")
  end

  it "ask" do
    xml = read_text_file_2(sub_dir, "xml_4.xml")
    result = Sparql::Query::Results.new(xml)
    expect(result.ask?).to eq(true)
  end

end