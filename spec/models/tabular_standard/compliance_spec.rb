require 'rails_helper'

describe Tabular::Datatype do

  include DataHelpers

  def sub_dir
    return "models/tabular_standard/datatype"
  end

  class Test
    
    def label=(value)
      @label = value
    end

    def label
      @label
    end

  end

  before :all do
    clear_triple_store
  end

  it "initializes" do
    collection = Tabular::Datatype.new
    expect(collection.set.set).to eq({})
  end

  it "adds an item" do
    collection = Tabular::Datatype.new
    collection.add({children: [{datatype: {label: "123"}}, {datatype: {label: "999"}}, {datatype: {label: "888"}}]})
    expect(collection.set.set.map{|k,x| x.label}).to match_array(["123", "999", "888"])
  end

  it "adds an item, empty data" do
    collection = Tabular::Datatype.new
    collection.add({children: []})
    expect(collection.set.set.map{|k,x| x.label}).to match_array([])
  end

  it "matches an item" do
    collection = Tabular::Datatype.new
    collection.add({children: [{datatype: {label: "123"}}, {datatype: {label: "999"}}, {datatype: {label: "888"}}, {datatype: {label: "888"}}]})
    result = collection.match("123")
    expect(result.label).to eq("123")
    result = collection.match("XXX")
    expect(result).to be_nil
    result = collection.match("888")
    expect(result.label).to eq("888")
    expect(collection.set.set.map{|k,x| x.label}).to match_array(["123", "999", "888"])
  end

end
  