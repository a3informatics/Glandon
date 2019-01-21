require 'rails_helper'

describe SparqlUpdateV2::StatementUri do
	
	include DataHelpers
  include PublicFileHelpers
  include TimeHelpers

  def sub_dir
    return "models/concerns/sparql_update_v2/statement_uri"
  end

  before :each do
    clear_triple_store
    @prefixes = {}
  end

  it "allows for the class to be created, uri" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
		result = SparqlUpdateV2::StatementUri.new({uri: uri}, "", @prefixes)
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect(@prefixes).to eq({})
	end

  it "allows for the uri to be obtained" do
    uri = UriV2.new(uri: "http://www.example.com/www#fragment")
    result = SparqlUpdateV2::StatementUri.new({uri: uri}, "", @prefixes)
    expect("#{result.uri.to_ref}").to eq("<http://www.example.com/www#fragment>")
  end

  it "allows for the class to be created, namespace and fragment" do
    result = SparqlUpdateV2::StatementUri.new({namespace: "http://www.example.com/www", id: "fragment"}, "", @prefixes)
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, namespace and fragment" do
    result = SparqlUpdateV2::StatementUri.new({namespace: "", id: "fragment"}, "http://www.example.com/www", @prefixes)
    expect("#{result}").to eq("<http://www.example.com/www#fragment>")
    expect("#{result.to_ref}").to eq("<http://www.example.com/www#fragment>")
    expect("#{result.to_turtle}").to eq(":fragment")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, namespace prefix and fragment" do
    result = SparqlUpdateV2::StatementUri.new({prefix: "bd", id: "fragment"}, "", @prefixes)
    expect("#{result}").to eq("bd:fragment")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_turtle}").to eq("bd:fragment")
    expect(@prefixes).to eq({"bd" => "bd"})
  end

  it "allows for the class to be created, namespace prefix empty and fragment" do
    result = SparqlUpdateV2::StatementUri.new({prefix: "", id: "fragment"}, "http://www.assero.co.uk/BusinessDomain", @prefixes)
    expect("#{result}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_ref}").to eq("<http://www.assero.co.uk/BusinessDomain#fragment>")
    expect("#{result.to_turtle}").to eq(":fragment")
    expect(@prefixes).to eq({})
  end

  it "allows for the class to be created, type error" do
    args = {prefixX: "bd", id: "fragment"}
    expect{SparqlUpdateV2::StatementUri.new(args, "", @prefixes)}.to raise_error(Errors::ApplicationLogicError, "Invalid triple part detected. Args: #{args}")
  end

end