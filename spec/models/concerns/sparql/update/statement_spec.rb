require 'rails_helper'

describe Sparql::Update::Statement do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/update/statement"
  end

  before :each do
    clear_triple_store
    @prefixes = {}
  end

  it "allows for the class to be created, uri" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
		result = Sparql::Update::Statement.new({subject: {uri: uri}, predicate: {uri: uri}, object: {uri: uri}}, "", {})
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment> <http://www.example.com/www#fragment> <http://www.example.com/www#fragment> . \n")
	end

  it "returns the subject" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    result = Sparql::Update::Statement.new({subject: {uri: uri}, predicate: {uri: uri}, object: {uri: uri}}, "", {})
    expect("#{result.subject}").to eq("#{uri}")
  end

  it "allows for the class to be created, namespace and fragment" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    result = Sparql::Update::Statement.new({subject: {uri: uri}, predicate: {uri: uri}, object: {:literal => "hello world", :primitive_type => "string"}}, "", {})
    expect("#{result}").to eq("<http://www.example.com/www#fragment> <http://www.example.com/www#fragment> \"hello world\"^^xsd:string . \n")
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment> <http://www.example.com/www#fragment> \"hello world\" . \n")
    expect("#{result.to_turtle("")}").to eq(".\n<http://www.example.com/www#fragment>\n\t<http://www.example.com/www#fragment> \"hello world\"^^xsd:string ;\n")
    expect("#{result.to_turtle("http://www.example.com/www#fragment")}").to eq("\t<http://www.example.com/www#fragment> \"hello world\"^^xsd:string ;\n")
  end

  it "allows for the class to be created, namespace and fragment" do
    prefix = {}
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    triple = {subject: {prefix: :iso25964, fragment: "xxx"}, predicate: {prefix: :iso25964, fragment: "type"}, object: {:literal => "hello world", :primitive_type => "string"}}
    result = Sparql::Update::Statement.new(triple, "", prefix)
    expect("#{result}").to eq("iso25964:xxx iso25964:type \"hello world\"^^xsd:string . \n")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/ISO25964#xxx> <http://www.assero.co.uk/ISO25964#type> \"hello world\" . \n")
    expect("#{result.to_turtle("")}").to eq(".\niso25964:xxx\n\tiso25964:type \"hello world\"^^xsd:string ;\n")
  end

  it "raises error for illegal formats" do
    prefix = {}
    literal_1 = {:literal => "1", :primitive_type => "string"}
    literal_2 = {:literal => "2", :primitive_type => "string"}
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    triple = {subject: {prefix: :iso25964, fragment: "xxx"}, predicate: literal_1, object: literal_2}
    expect{Sparql::Update::Statement.new(triple, "", prefix)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: #{literal_1}")
    triple = {subject: literal_1, predicate: {prefix: :iso25964, fragment: "xxx"}, object: literal_2}
    expect{Sparql::Update::Statement.new(triple, "", prefix)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: #{literal_1}")
  end

end