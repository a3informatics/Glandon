require 'rails_helper'

describe Sparql::Update::Statement::Uri do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql/update/statement/uri"
  end

  before :each do
    clear_triple_store
    @prefixes = {}
  end

  it "allows for the class to be created, uri" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
		result = Sparql::Update::Statement::Uri.new({uri: uri}, "", @prefixes)
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect(@prefixes).to eq({})
	end

  it "allows for the uri to be obtained" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    result = Sparql::Update::Statement::Uri.new({uri: uri}, "", @prefixes)
    expect("#{result.uri.to_ref}").to eq("<http://www.example.com/www#fragment>")
  end

  it "allows for the class to be created, namespace and fragment" do
    result = Sparql::Update::Statement::Uri.new({namespace: "http://www.example.com/www", fragment: "fragment"}, "", @prefixes)
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, namespace and fragment, matches prefix, required" do
    result = Sparql::Update::Statement::Uri.new({namespace: "http://www.w3.org/1999/02/22-rdf-syntax-ns", fragment: "fragment"}, "", @prefixes)
    expect("#{result.to_turtle}").to eq("rdf:fragment")
    expect("#{result.to_ref}").to eq("<http://www.w3.org/1999/02/22-rdf-syntax-ns#fragment>")
    expect("#{result.to_turtle}").to eq("rdf:fragment")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, namespace and fragment, matches prefix, optional" do
    result = Sparql::Update::Statement::Uri.new({namespace: "http://www.assero.co.uk/BusinessDomain", fragment: "fragment"}, "", @prefixes)
    expect("#{result}").to eq("bd:fragment")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_turtle}").to eq("bd:fragment")
    expect(@prefixes).to eq({bd: :bd})
  end

  it "allows for the class to be created, namespace and fragment" do
    result = Sparql::Update::Statement::Uri.new({namespace: "", fragment: "fragment"}, "http://www.example.com/www", @prefixes)
    expect("#{result}").to eq("<http://www.example.com/www#fragment>")
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect("#{result.to_turtle}").to eq(":fragment")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, namespace prefix and fragment" do
    result = Sparql::Update::Statement::Uri.new({prefix: :bd, fragment: "fragment"}, "", @prefixes)
    expect("#{result}").to eq("bd:fragment")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_turtle}").to eq("bd:fragment")
    expect(@prefixes).to eq({bd: :bd})
  end

  it "allows for the class to be created, namespace prefix empty and fragment" do
    result = Sparql::Update::Statement::Uri.new({prefix: "", fragment: "fragment"}, "http://www.assero.co.uk/BusinessDomain", @prefixes)
    expect("#{result}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_turtle}").to eq(":fragment")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, type error" do
    args = {prefixX: :bd, fragment: "fragment"}
    expect{Sparql::Update::Statement::Uri.new(args, "", @prefixes)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: #{args}")
  end

end