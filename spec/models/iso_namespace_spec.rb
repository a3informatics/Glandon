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
    result.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#NS-XXX")
    result.name = "XXX Long"
    result.short_name = "XXX"
    result.authority = "www.a3.com"
    expect(IsoNamespace.from_h({uri: "http://www.assero.co.uk/MDRItems#NS-XXX", name: "XXX Long", short_name: "XXX", authority: "www.a3.com"}).to_h).to eq(result.to_h)
  end

	it "can be returned as JSON" do
    result = IsoNamespace.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#NS-XXX")
    result.name = "XXX Long"
    result.short_name = "XXX"
    result.authority = "www.a3.com"
    expect(result.to_h).to eq({uri: "http://www.assero.co.uk/MDRItems#NS-XXX", name: "XXX Long", short_name: "XXX", authority: "www.a3.com"})
  end

  it "determines namespace exists" do
		expect(IsoNamespace.exists?("AAA")).to eq(true)   
	end

	it "determines namespace does not exists" do
    expect(IsoNamespace.exists?("AAA1")).to eq(false)   
  end

  it "finds namespace by short name" do
    result = IsoNamespace.new
    result.uri =  Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    result.name = "AAA Long"
    result.short_name = "AAA"
    result.authority = "www.aaa.com"
    expect(IsoNamespace.find_by_short_name("AAA").to_h).to eq(result.to_h)   
  end

  it "finds namespace" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    expected = {uri: "http://www.assero.co.uk/NS#AAA", name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"}
    expect(result.to_h).to eq(expected)   
  end

  it "needs caching tests"

	it "all namespaces" do
    expected = [
      {uri: "http://www.assero.co.uk/NS#AAA", name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"},
      {uri: "http://www.assero.co.uk/NS#BBB", name: "BBB Pharma", short_name: "BBB", authority: "www.bbb.com"},
    ]
    items = IsoNamespace.all
    result = items.map{|x| x.to_h}
    expect(result).to eq(expected)   
  end

	it "create a namespace" do
    expected = {uri: "http://www.assero.co.uk/NS#CCC", name: "CCC Long", short_name: "CCC", authority: "www.ccc.com"}
    result = IsoNamespace.create({name: "CCC Long", short_name: "CCC", authority: "www.ccc.com"})
    expect(result.to_h).to eq(expected)  
	end

  it "passes a valid check" do
    result = IsoNamespace.new(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD Long", short_name: "DDD", authority: "www.ddd.com")
    expect(result.valid?).to be(true)
  end

  it "does not create a namespace with an invalid short name" do
    result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD", short_name: "DDD%$£@", authority: "www.ddd.com")
    expect(result.valid?).to be(false)
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("Short name is invalid") 
  end

  it "does not create a namespace with an invalid name" do
    result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD%$£@", short_name: "DDD", authority: "www.ddd.com")
    expect(result.valid?).to be(false)
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("Name is invalid") 
  end

  it "does not create a namespace that already exists" do
    result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "CCC111", short_name: "AAA", authority: "www.ccc111.com")
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("An existing record exisits in the database")
  end
    
  it "destroy a namespace" do
    object = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    object.delete
    expect{IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))}.to raise_error(Exceptions::NotFoundError, "Failed to find http://www.assero.co.uk/NS#AAA " + 
      "in Class object.")
  end

  it "determines if the namespace is valid except for presence" do
    result = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
    expect(result.valid?).to eq(false)   
    expect(result.errors.full_messages.to_sentence).to eq("An existing record exisits in the database")
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