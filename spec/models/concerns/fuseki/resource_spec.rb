require 'rails_helper'

describe Fuseki::Resource do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/resource"
  end

  before :each do
    clear_triple_store
  end

  after :each do
  end
    
  class TestR1 
    extend Fuseki::Resource

    def xxx
      return 14
    end

  end

  class TestR2 
    extend Fuseki::Resource
  end

  class TestR3
    extend Fuseki::Resource
  end

  class TestR4
    extend Fuseki::Resource
  end

  class TestR5
    extend Fuseki::Resource
  end

  class TestR6
    extend Fuseki::Resource
  end

  it "error if RDF type not configured" do
    expect{TestR1.configure({})}.to raise_error(Errors::ApplicationLogicError, "No RDF type specified when configuring class.")
  end

  it "RDF type configured" do
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX"})
    expect(TestR1.respond_to?(:rdf_type)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:rdf_type)).to eq(true)
    expect(TestR1.instance_variable_get(:@properties)).to eq({}) # Make sure we clear properties.
  end

  it "URI generation configured, unique" do
    parent = Uri.new(uri: "http://www.example.com/A#XXX")
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_unique: true})
    expect(TestR1.respond_to?(:create_uri)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:create_uri)).to eq(true)
    result = item.create_uri(parent)
    expect(result.to_s.length > parent.to_s.length).to eq(true)
    expect(result.to_s).to start_with(parent.to_s)
  end

  it "URI generation configured, prefix" do
    parent = Uri.new(uri: "http://www.example.com/A#XXX")
    expected = "#{parent.to_s}_AAA"
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_suffix: "AAA"})
    expect(TestR1.respond_to?(:create_uri)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:create_uri)).to eq(true)
    result = item.create_uri(parent)
    expect(result.to_s).to eq(expected)
    expect(result.equal?(parent)).to eq(false)
  end

  it "URI generation configured, property" do
    parent = Uri.new(uri: "http://www.example.com/A#XXX")
    expected = "#{parent.to_s}_14"
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_property: :xxx})
    expect(TestR1.respond_to?(:create_uri)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:create_uri)).to eq(true)
    result = item.create_uri(parent)
    expect(result.to_s).to eq(expected)
  end

  it "URI generation configured, property & prefix" do
    parent = Uri.new(uri: "http://www.example.com/A#XXX")
    expected = "#{parent.to_s}_BBB14"
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_suffix: "BBB", uri_property: :xxx})
    expect(TestR1.respond_to?(:create_uri)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:create_uri)).to eq(true)
    result = item.create_uri(parent)
    expect(result.to_s).to eq(expected)
  end

  it "URI generation configured, property & prefix" do
    parent = Uri.new(uri: "http://www.example.com/A#XXX")
    expected = "#{parent.to_s}_BBB"
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_suffix: "BBB"})
    result = TestR1.create_uri(parent)
    expect(result.to_s).to eq(expected)
  end

  it "error if cardinality not configured" do
    expect{TestR2.object_property({})}.to raise_error(Errors::ApplicationLogicError, "No cardinality specified for object property.")
  end

  it "error if class not configured" do
    expect{TestR3.object_property(:fred, {cardinality: :one})}.to raise_error(Errors::ApplicationLogicError, "No model class specified for object property.")
  end

  it "Object property configured" do
    TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
    fred_expected = {:cardinality=>:one, :default=>nil, :model_class=>"XXX", :name=>:fred, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#fred")}
    sid_expected = {:cardinality=>:many, :default=>[], :model_class=>"XXX", :name=>:sid, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#sid")}
    TestR4.object_property(:fred, {cardinality: :one, model_class: "XXX"})
    expect(TestR4.instance_variable_get(:@properties)).to eq({:@fred => fred_expected})
    TestR4.object_property(:sid, {cardinality: :many, model_class: "XXX"})
    expect(TestR4.instance_variable_get(:@properties)).to eq({:@fred => fred_expected, :@sid => sid_expected}) 
  end

  it "Data property configured, no default" do
    TestR5.configure({rdf_type: "http://www.example.com/C#YYY"})
    fred1_expected = {:cardinality=>:one, :default=>"", :model_class=>"", :name=>:fred1, :type=>:data, predicate: Uri.new(uri: "http://www.example.com/C#fred1")}
    TestR5.data_property(:fred1)
    expect(TestR5.instance_variable_get(:@properties)).to eq({:@fred1 => fred1_expected})    
  end

  it "Data property configured, default" do
    TestR6.configure({rdf_type: "http://www.example.com/C#YYY"})
    fred2_expected = {:cardinality=>:one, :default=>"default value", :model_class=>"", :name=>:fred2, :type=>:data, predicate: Uri.new(uri: "http://www.example.com/C#fred2")}
    TestR6.data_property(:fred2, {default: "default value"})
    expect(TestR6.instance_variable_get(:@properties)).to eq({:@fred2 => fred2_expected})    
  end

end