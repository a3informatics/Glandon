require 'rails_helper'

describe Sparql::Update::Statement::Literal do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/update/statement/literal"
  end

  before :each do
    clear_triple_store
  end

  it "allows for the class to be created, string" do
		result = Sparql::Update::Statement::Literal.new({:literal => "hello world", :primitive_type => "string"})
    expect("#{result}").to eq("\"hello world\"^^xsd:string")
    expect("#{result.to_turtle}").to eq("\"hello world\"^^xsd:string")
	end

  it "allows for the class to be created, ref" do
    result = Sparql::Update::Statement::Literal.new({:literal => "hello world", :primitive_type => "string"})
    #expect("#{result}").to eq("\"hello world\"^^xsd:string")
    expect("#{result.to_ref}").to eq("\"hello world\"")
  end

  it "allows for the class to be created, special characters I" do
    args = {:literal => "hello ++++ world", :primitive_type => "string"}
    result = Sparql::Update::Statement::Literal.new(args)
    expect("#{result}").to eq("\"hello ++++ world\"^^xsd:string")    
    expect("#{result.to_ref}").to eq("\"hello ++++ world\"")    
    expect("#{result.to_turtle}").to eq("\"hello ++++ world\"^^xsd:string")    
  end

  it "allows for the class to be created, special characters II" do
    args = {:literal => "hello \r\n\t\\\"\' world", :primitive_type => "string"}
    result = Sparql::Update::Statement::Literal.new(args)
    expect("#{result}").to eq("\"hello \\r\\n\\t\\\\\\\"' world\"^^xsd:string")    
    expect("#{result.to_ref}").to eq("\"hello \\r\\n\\t\\\\\\\"' world\"")    
    expect("#{result.to_turtle}").to eq("\"hello \\r\\n\\t\\\\\\\"' world\"^^xsd:string")    
  end

  it "allows for the class to be created, special characters, prefixed form" do
    args = {:literal => "hello ++++ world", :primitive_type => "string"}
    result = Sparql::Update::Statement::Literal.new(args)
    #expect("#{result.to_ref}").to eq("\"hello %2B%2B%2B%2B world\"^^xsd:string")    
    expect("#{result.to_ref}").to eq("\"hello ++++ world\"")    
  end

  it "allows for the class to be created, special characters" do
    x = "2018-01-01T00:00:00+01:00".to_time_with_default
    args = {:literal => x, :primitive_type => "dateTime"}
    result = Sparql::Update::Statement::Literal.new(args)
    expect("#{result}").to eq("\"2018-01-01T00:00:00+01:00\"^^xsd:dateTime")    
    expect("#{result.to_ref}").to eq("\"2018-01-01T00:00:00+01:00\"")    
  end

  it "allows for the class to be created, type error" do
    args = {:literal => "hello world", :primitive_typeX => "string"}
    expect{Sparql::Update::Statement::Literal.new(args)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple literal detected. Args: #{args}")
  end

  it "allows for the class to be created, literal error" do
    args = {:literalX => "hello world", :primitive_type => "string"}
    expect{Sparql::Update::Statement::Literal.new(args)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple literal detected. Args: #{args}")
  end

end