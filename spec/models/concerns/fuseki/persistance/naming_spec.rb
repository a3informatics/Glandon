require 'rails_helper'

describe Fuseki::Persistence::Naming do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/persistence/naming"
  end

  before :each do
    clear_triple_store
  end

  after :all do
  end

  it "initialize with schema" do
    item = Fuseki::Persistence::Naming.new("xxxAaa")
    expect(item.as_symbol).to eq(:xxx_aaa)
    expect(item.as_schema).to eq("xxxAaa")
    expect(item.as_instance).to eq(:@xxx_aaa)    
  end

  it "initialize with rails" do
    item = Fuseki::Persistence::Naming.new("xxx_aaa")
    expect(item.as_symbol).to eq(:xxx_aaa)
    expect(item.as_schema).to eq("xxxAaa")
    expect(item.as_instance).to eq(:@xxx_aaa)    
  end

  it "initialize with instance" do
    item = Fuseki::Persistence::Naming.new(:@xxx_aaa)
    expect(item.as_symbol).to eq(:xxx_aaa)
    expect(item.as_schema).to eq("xxxAaa")
    expect(item.as_instance).to eq(:@xxx_aaa)    
  end

end