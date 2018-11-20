require 'rails_helper'

describe TabularStandard::Collection do

  include DataHelpers

  def sub_dir
    return "models/tabular_standard/collection"
  end

  class Test
    
    def label=(value)
      @label = value
    end

    def label
      @label
    end

    def to_sparql_v2(parent_uri, sparql)
      uri = UriV3.new(namespace: parent_uri.namespace, fragment: parent_uri.fragment + "_#{@label}")
      sparql.triple({uri: uri}, {:prefix => UriManagement::C_RDFS, :id => "label"}, {:literal => "#{@label}", :primitive_type => "string"})
    end

  end

  before :all do
    clear_triple_store
  end

  it "initializes" do
    collection = TabularStandard::Collection.new(klass: Test)
    expect(collection.set).to eq({})
  end

  it "initializes, error" do
    expect{TabularStandard::Collection.new(klassX: Test)}.to raise_error(Errors::ApplicationLogicError, "Missing arguments detected.")
  end

  it "adds an item" do
    collection = TabularStandard::Collection.new(klass: Test)
    result_1 = collection.add("XXX")
    expect(result_1).to be_a(Test)
    expect(result_1.label). to eq("XXX")
    result_2 = collection.add("XXX")
    expect(result_2).to eq(result_1)
    expect(result_2.label). to eq("XXX")
    result_3 = collection.add("YYY")
    expect(result_3).to be_a(Test)
    expect(result_3).to_not eq(result_1)
    expect(result_3.label).to eq("YYY")
    expect(collection.set.map{|k,x| x.label}).to match_array(["XXX", "YYY"])
  end

  it "matches an item" do
    collection = TabularStandard::Collection.new(klass: Test)
    item_1 = collection.add("XXX")
    item_2 = collection.add("YYY")
    item_3 = collection.add("ZZZ")
    item_4 = collection.add("ZZZ")
    result = collection.match("ZZZ")
    expect(result).to eq(item_3)
    result = collection.match("XXX")
    expect(result).to eq(item_1)
    result = collection.match("AAA")
    expect(result).to be_nil
    expect(collection.set.map{|k,x| x.label}).to match_array(["XXX", "YYY", "ZZZ"])
  end

  it "generates the sparql for the collection" do
    expected = %Q{PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
INSERT DATA 
{ 
<http://www.a3informatics.com/a/b#base_XXX> rdfs:label "XXX"^^xsd:string . 
<http://www.a3informatics.com/a/b#base_YYY> rdfs:label "YYY"^^xsd:string . 
<http://www.a3informatics.com/a/b#base_ZZZ> rdfs:label "ZZZ"^^xsd:string . 
}}
    uri = UriV3.new(uri: "http://www.a3informatics.com/a/b#base")
    sparql = SparqlUpdateV2.new
    collection = TabularStandard::Collection.new(klass: Test)
    item_1 = collection.add("XXX")
    item_2 = collection.add("YYY")
    item_3 = collection.add("ZZZ")
    collection.to_sparql(uri, sparql)
    expect(sparql.to_s).to eq(expected)
  end

end
  