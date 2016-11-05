require 'rails_helper'

describe IsoRegistrationAuthority do
	
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
  end

	it "can be filled from JSON" do
    result = IsoRegistrationAuthority.new
    result.id = "NS-XXX"
    result.number = "12345678"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.new
    result.owner = false
    expect(IsoRegistrationAuthority.from_json({id: "NS-XXX", number: "12345678", scheme: "DUNS", owner: false, namespace: IsoNamespace.new.to_json }).to_json).to eq(result.to_json)
  end

	it "can be returned as JSON" do
    result = IsoRegistrationAuthority.new
    result.id = "NS-XXX"
    result.number = "12345678"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.new
    result.owner = false
    expect(result.to_json).to eq({id: "NS-XXX", number: "12345678", scheme: "DUNS", owner: false, namespace: IsoNamespace.new.to_json })
  end

  it "finds authority" do
    org = IsoNamespace.find("NS-AAA")
    result = {:id=>"RA-111111111", :number=>"111111111", :scheme=>"DUNS", :owner=>false, :namespace=> org.to_json}
    expect(IsoRegistrationAuthority.find("RA-111111111").to_json).to eq(result)   
  end

	it "finds all authorities" do
    results = []
    result = IsoRegistrationAuthority.new
    result.id = "RA-123456789"
    result.number = "123456789"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-BBB")
    result.owner = true
    results << result
    result = IsoRegistrationAuthority.new
    result.id = "RA-111111111"
    result.number = "111111111"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-AAA")
    result.owner = false
    results << result
    expect(IsoRegistrationAuthority.all.to_json).to eq(results.to_json)   
  end

  it "finds authority by short name" do
    result = IsoRegistrationAuthority.new
    result.id = "RA-111111111"
    result.number = "111111111"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-AAA")
    result.owner = false
    expect(IsoRegistrationAuthority.find_by_short_name("AAA").to_json).to eq(result.to_json)   
  end

	it "create an authority" do
    org = IsoNamespace.new
    org.id = "NS-CCC_NS"
    org.namespace = "http://www.assero.co.uk/MDRItems"
    org.name = "CCC Long"
    org.shortName = "CCC"
    expect(IsoNamespace.create({shortName: "CCC", name: "CCC Long"}).to_json).to eq(org.to_json) 
    result = IsoRegistrationAuthority.new
    result.id = "RA-DUNS_22223333"
    result.number = "22223333"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-DDD")
    result.owner = false
    expect(IsoRegistrationAuthority.create({number: "22223333", namespaceId: org.id}).to_json).to eq(result.to_json)  
	end

  it "destroy a authority" do
    object = IsoRegistrationAuthority.find("RA-DUNS_22223333")
    org = IsoNamespace.find("NS-CCC_NS")
    result = {:id=>"RA-DUNS_22223333", :number=>"22223333", :scheme=>"DUNS", :owner=>false, :namespace=> org.to_json}
    expect(object.to_json).to eq(result)   
    object.destroy
  end

  it "clears triple store" do
    clear_triple_store
  end

end