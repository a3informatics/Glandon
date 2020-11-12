require 'rails_helper'

describe IsoNamespace do
	
  include DataHelpers

  describe "Basic tests" do
    
    before :all do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl"]
      load_files(schema_files, data_files)
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
      expected = {uri: "http://www.assero.co.uk/MDRItems#NS-XXX", id: Uri.new(uri: "http://www.assero.co.uk/MDRItems#NS-XXX").to_id,
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace", 
        name: "XXX Long", short_name: "XXX", authority: "www.a3.com"}
      expect(result.to_h).to eq(expected)
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
      expected = {uri: "http://www.assero.co.uk/NS#AAA", id: Uri.new(uri: "http://www.assero.co.uk/NS#AAA").to_id,
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace", 
        name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"}
      expect(result.to_h).to eq(expected)   
    end

    it "needs caching tests"

  	it "all namespaces" do
      expected = [
        {
          uri: "http://www.assero.co.uk/NS#AAA", id: Uri.new(uri: "http://www.assero.co.uk/NS#AAA").to_id,
          rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace", 
          name: "AAA Long", short_name: "AAA", authority: "www.aaa.com"
        },
        {
          uri: "http://www.assero.co.uk/NS#BBB", id: Uri.new(uri: "http://www.assero.co.uk/NS#BBB").to_id,
          rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace", 
          name: "BBB Pharma", short_name: "BBB", authority: "www.bbb.com"
        }
      ]
      items = IsoNamespace.all
      result = items.map{|x| x.to_h}
      expect(result).to match_array(expected)   
    end

  	it "create a namespace" do
      expected = {uri: "http://www.assero.co.uk/NS#CCC", id: Uri.new(uri: "http://www.assero.co.uk/NS#CCC").to_id,
        rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace", 
        name: "CCC Long", short_name: "CCC", authority: "www.ccc.com"}
      result = IsoNamespace.create({name: "CCC Long", short_name: "CCC", authority: "www.ccc.com"})
      expect(result.to_h).to eq(expected)  
  	end

    it "determines if namesapce used" do
      items = IsoNamespace.all
      sparql = %Q{INSERT DATA
        { 
          <http://example/book1> <http://example/is> #{items.first.uri.to_ref} .
          <http://example/book1> <http://example/is> #{items.last.uri.to_ref} .
        }
      }
      Sparql::Update.new.sparql_update(sparql, "", []) # Link to the two scopes so they are used.
      expect(items.first.not_used?).to eq(false)
      expect(items.last.not_used?).to eq(false)
      result = IsoNamespace.create({name: "CCC Long", short_name: "CCC", authority: "www.ccc.com"})
      expect(result.not_used?).to eq(true)
    end

    it "passes a valid check" do
      result = IsoNamespace.new(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD Long", short_name: "DDD", authority: "www.ddd.com")
      expect(result.valid?).to be(true)
    end

    it "does not create a namespace with an invalid short name - WILL CURRENTLY FAIL - Strange error, echoing error message, passing in isolation." do
puts colourize("+++++ \n#{IsoNamespace.validators}\n +++++", "blue")
      result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD", short_name: "DDD%$£@", authority: "www.ddd.com")
puts colourize("+++++ \n#{IsoNamespace.validators}\n +++++", "blue")
puts colourize("***** ISO Namespace errors: #{result.errors.full_messages.to_sentence} *****", "red")
      #expect(result.valid?).to be(false)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("Short name contains invalid characters") 
    end

    it "does not create a namespace with an invalid name - WILL CURRENTLY FAIL - Strange error, echoing error messagev" do
      result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD%$£@", short_name: "DDD", authority: "www.ddd.com")
puts colourize("***** ISO Namespace errors: #{result.errors.full_messages.to_sentence} *****", "red")
      #expect(result.valid?).to be(false)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("Name contains invalid characters") 
    end

    it "does not create a namespace that already exists - WILL CURRENTLY FAIL - Strange error, echoing error message, passing in isolation." do
      result = IsoNamespace.create(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "CCC111", short_name: "AAA", authority: "www.ccc111.com")
puts colourize("***** ISO Namespace errors: #{result.errors.full_messages.to_sentence} *****", "red")
      expect(result.errors.count).to eq(2)
      expect(result.errors.full_messages.to_sentence).to eq("http://www.assero.co.uk/NS#AAA already exists in the database and an existing record (short_name: AAA) exisits in the database")
    end
      
    it "destroy a namespace" do
      object = IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))
      object.delete
      expect{IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#AAA"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/NS#AAA " + 
        "in IsoNamespace.")
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

end