require 'rails_helper'

describe IsoNamespace do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179IdentificationSimplified.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
  end

	it "can be filled from JSON" do
    result = IsoNamespace.new
    result.uri = "http://www.assero.co.uk/MDRItems#NS-XXX"
    result.name = "XXX Long"
    result.short_name = "XXX"
    result.authority = "www.a3.com"
    expect(IsoNamespace.from_json({uri: "http://www.assero.co.uk/MDRItems#NS-XXX", name: "XXX Long", short_name: "XXX", authority: "www.a3.com"}).to_json).to eq(result.to_json)
  end

	it "can be returned as JSON" do
    result = IsoNamespace.new
    result.uri = "http://www.assero.co.uk/MDRItems#NS-XXX"
    result.name = "XXX Long"
    result.short_name = "XXX"
    result.authority = "www.a3.com"
    expect(result.to_json).to eq({uri: "http://www.assero.co.uk/MDRItems#NS-XXX", name: "XXX Long", short_name: "XXX", authority: "www.a3.com"})
  end

  it "determines namespace exists" do
		expect(IsoNamespace.exists?("AAA")).to eq(true)   
	end

	it "determines namespace does not exists" do
    expect(IsoNamespace.exists?("AAA1")).to eq(false)   
  end

  it "finds namespace by short name" do
    result = IsoNamespace.new
    result.uri = "http://www.assero.co.uk/NS#AAA"
    result.name = "AAA Long"
    result.short_name = "AAA"
    result.authority = "www.aaa.com"
    expect(IsoNamespace.find_by_short_name("AAA").to_json).to eq(result.to_json)   
  end

	it "determines namespace exists without query" do
    namespace = IsoNamespace.new
    namespace.short_name = "AAA"
    expect(namespace.exists?).to eq(true) 
  end

  it "finds namespace by short name without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.short_name = "AAA"
    expect(IsoNamespace.findByShortName("AAA").to_json).to eq(result.to_json)  
  end

	it "finds namespace" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    expected = {uri: "http://www.assero.co.uk/NS#AAA", name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"}
    expect(result.to_hash).to eq(expected)   
  end

	it "finds namespace without query" do
    result = IsoNamespace.new
    result.id = "NS-AAA"
    result.namespace = "http://www.assero.co.uk/MDRItems"
    result.name = "AAA Long"
    result.short_name = "AAA"
    expect(IsoNamespace.find("NS-AAA").to_json).to eq(result.to_json)  
  end

	it "all namespaces" do
    expected = [
      {uri: "http://www.assero.co.uk/NS#AAA", name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"},
      {uri: "http://www.assero.co.uk/NS#BBB", name: "BBB Long", short_name: "BBB", authority: "www.bbb.com"},
    ]
    result = IsoNamespace.all
    expect(result).to eq(expected)   
  end

	it "create a namespace" do
    expected = {uri: "http://www.assero.co.uk/NS#AAA", name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"},
    result = IsoNamespace.new
    result.name = "CCC Long"
    result.short_name = "CCC"
    result.authority = "www.ccc.com"
    ns = result.create
    expect(ns.to_json).to eq(expected)  
	end

  it "does not create a namespace with an invalid shortname" do
    result = IsoNamespace.new
    result.name = "CCC Long"
    result.short_name = "CCC%$£@"
    result.authority = "www.ccc.com"
    result.create
    expect(result.errors.messages[:short_name]).to include("contains invalid characters") 
  end

  it "does not create a namespace with an invalid name" do
    result = IsoNamespace.new
    result.name = "CCC%$£@ Long"
    result.short_name = "CCC"
    result.authority = "www.ccc.com"
    result.create
    expect(result.errors.messages[:name]).to include("contains invalid characters or is empty") 
  end

  it "does not create a namespace that already exists" do
    result = IsoNamespace.new
    result.name = "AAA XXX"
    result.short_name = "AAA"
    result.authority = "www.aaa.com"
    result.create
    expect(result.errors.messages[:name]).to include("contains invalid characters or is empty") 
  end
    
  it "destroy a namespace" do
    object = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    object.delete
    expect{IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))}.to raise_error(Exceptions::NotFoundError, "Failed to find http://www.assero.co.uk/NS#AAA in Class object.")
  end

  it "determines if the namespace is valid" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    expect(result.valid?).to eq(true)   
  end

  it "determines the namespace is invalid with a invalid short name" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    result.short_name = "AAAaaa123^"
    expect(result.valid?).to eq(false)   
  end

  it "determines the namespace is invalid with a invalid name" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    result.name = "AAA Long£"
    expect(result.valid?).to eq(false)   
  end

end