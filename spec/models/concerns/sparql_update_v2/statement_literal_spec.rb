require 'rails_helper'

describe SparqlUpdateV2::StatementLiteral do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql_update_v2/statement_literal"
  end

  before :each do
    clear_triple_store
  end

  it "allows for the class to be created, string" do
		result = SparqlUpdateV2::StatementLiteral.new({:literal => "hello world", :primitive_type => "string"})
    #expect("#{result}").to eq("\"hello world\"^^xsd:string")
    expect("#{result}").to eq("\"hello world\"^^xsd:string")
	end

  it "allows for the class to be created, ref" do
    result = SparqlUpdateV2::StatementLiteral.new({:literal => "hello world", :primitive_type => "string"})
    #expect("#{result}").to eq("\"hello world\"^^xsd:string")
    expect("#{result.to_ref}").to eq("\"hello world\"")
  end

  it "allows for the class to be created, special characters" do
    args = {:literal => "hello ++++ world", :primitive_type => "string"}
    result = SparqlUpdateV2::StatementLiteral.new(args)
    expect("#{result}").to eq("\"hello %2B%2B%2B%2B world\"^^xsd:string")    
    expect("#{result.to_ref}").to eq("\"hello %2B%2B%2B%2B world\"")    
  end

  it "allows for the class to be created, special characters, prefixed form" do
    args = {:literal => "hello ++++ world", :primitive_type => "string"}
    result = SparqlUpdateV2::StatementLiteral.new(args)
    #expect("#{result.to_ref}").to eq("\"hello %2B%2B%2B%2B world\"^^xsd:string")    
    expect("#{result.to_ref}").to eq("\"hello %2B%2B%2B%2B world\"")    
  end

  it "allows for the class to be created, special characters" do
    args = {:literal => "2018-01-01T00:00:00+01:00", :primitive_type => "dateTime"}
    result = SparqlUpdateV2::StatementLiteral.new(args)
    expect("#{result}").to eq("\"2018-01-01T00:00:00%2B01:00\"^^xsd:dateTime")    
    expect("#{result.to_ref}").to eq("\"2018-01-01T00:00:00%2B01:00\"")    
  end

  it "allows for the class to be created, type error" do
    args = {:literal => "hello world", :primitive_typeX => "string"}
    expect{SparqlUpdateV2::StatementLiteral.new(args)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple literal detected. Args: #{args}")
  end

  it "allows for the class to be created, literal error" do
    args = {:literalX => "hello world", :primitive_type => "string"}
    expect{SparqlUpdateV2::StatementLiteral.new(args)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple literal detected. Args: #{args}")
  end

end