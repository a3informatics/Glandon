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

  it "error if RDF type not configured" do
    expect{TestR1.configure({})}.to raise_error(Errors::ApplicationLogicError, "No RDF type specified when configuring class.")
  end

  it "RDF type configured" do
    TestR1.configure({rdf_type: "http://www.example.com/A#XXX"})
    expect(TestR1.respond_to?(:rdf_type)).to eq(true)
    item = TestR1.new
    expect(item.respond_to?(:rdf_type)).to eq(true)
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

  it "Data property configured" do
    TestR5.configure({rdf_type: "http://www.example.com/C#YYY"})
    fred1_expected = {:cardinality=>:one, :default=>"", :model_class=>"", :name=>:fred1, :type=>:data, predicate: Uri.new(uri: "http://www.example.com/C#fred1")}
    TestR5.data_property(:fred1)
    expect(TestR5.instance_variable_get(:@properties)).to eq({:@fred1 => fred1_expected})
  end

end