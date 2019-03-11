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
    Test.instance_variable_set(:@properties, {})
  end
    

  class Test 
    extend Fuseki::Resource
  end

  it "error if RDF type not configured" do
    expect{Test.configure({})}.to raise_error(Errors::ApplicationLogicError, "No RDF type specified when configuring class.")
  end

  it "RDF type configured" do
    Test.configure({rdf_type: "http://www.example.com/A#XXX"})
    expect(Test.respond_to?(:rdf_type)).to eq(true)
    item = Test.new
    expect(item.respond_to?(:rdf_type)).to eq(true)
  end

  it "error if cardinality not configured" do
    expect{Test.object_property({})}.to raise_error(Errors::ApplicationLogicError, "No cardinality specified for object property.")
  end

  it "error if class not configured" do
    expect{Test.object_property(:fred, {cardinality: :one})}.to raise_error(Errors::ApplicationLogicError, "No model class specified for object property.")
  end

  it "Object property configured" do
    fred_expected = {:cardinality=>:one, :default=>nil, :model_class=>"XXX", :name=>:fred, :type=>:object}
    sid_expected = {:cardinality=>:many, :default=>[], :model_class=>"XXX", :name=>:sid, :type=>:object}
    Test.object_property(:fred, {cardinality: :one, model_class: "XXX"})
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred => fred_expected})
    Test.object_property(:sid, {cardinality: :many, model_class: "XXX"})
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred => fred_expected, :@sid => sid_expected}) 
  end

  it "Data property configured" do
    fred1_expected = {:cardinality=>:one, :default=>"", :model_class=>"", :name=>:fred1, :type=>:data}
    Test.data_property(:fred1)
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred1 => fred1_expected})
  end

end