require 'rails_helper'

describe Tabular::Collection do

  include DataHelpers

  def sub_dir
    return "models/tabular/collection"
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
    collection = Tabular::Collection.new(klass: Test)
    expect(collection.set).to eq({})
  end

  it "adds an item" do
    collection = Tabular::Collection.new(klass: Test)
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
    collection = Tabular::Collection.new(klass: Test)
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

end
  