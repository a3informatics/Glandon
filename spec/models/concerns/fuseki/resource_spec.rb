require 'rails_helper'

describe Fuseki::Base do
  
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
    expect(Test.instance_variable_get(:@properties)[:@rdf_type][:default].to_s).to eq("http://www.example.com/A#XXX")
  end

  it "error if cardinality not configured" do
    expect{Test.object_property({})}.to raise_error(Errors::ApplicationLogicError, "No cardinality specified for object property.")
  end

  it "Object property configured" do
    Test.object_property(:fred, {cardinality: :one})
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred => {default: ""}})
    Test.object_property(:sid, {cardinality: :many})
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred => {default: ""}, :@sid => {default: []}})
  end

  it "Data property configured" do
    Test.data_property(:fred1)
    expect(Test.instance_variable_get(:@properties)).to eq({:@fred1 => {default: ""}})
  end

end