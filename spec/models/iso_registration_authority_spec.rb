require 'rails_helper'

describe IsoRegistrationAuthority do
	
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
  end

  it "validates a valid object" do
    result = IsoRegistrationAuthority.new
    result.number = "123456789"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-BBB")
    result.owner = false
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    result = IsoRegistrationAuthority.new
    result.number = "12345678"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-BBB")
    result.owner = false
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object" do
    result = IsoRegistrationAuthority.new
    result.number = "123456789"
    result.scheme = "DUS"
    result.namespace = IsoNamespace.find("NS-BBB")
    result.owner = false
    expect(result.valid?).to eq(false)
  end

  it "can be filled from JSON" do
    result = IsoRegistrationAuthority.new
    result.id = "NS-XXX"
    result.number = "123456789"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.new
    result.owner = false
    expect(IsoRegistrationAuthority.from_json({id: "NS-XXX", number: "123456789", scheme: "DUNS", owner: false, namespace: IsoNamespace.new.to_json }).to_json).to eq(result.to_json)
  end

	it "can be returned as JSON" do
    result = IsoRegistrationAuthority.new
    result.id = "NS-XXX"
    result.number = "123456789"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.new
    result.owner = false
    expect(result.to_json).to eq({id: "NS-XXX", number: "123456789", scheme: "DUNS", owner: false, namespace: IsoNamespace.new.to_json })
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

	it "determines if authority exists" do
    result = IsoRegistrationAuthority.new
    result.number = "111111111"
    expect(result.exists?).to eq(true)   
  end

  it "determines if authority does not exist" do
    result = IsoRegistrationAuthority.new
    result.number = "111111122"
    expect(result.exists?).to eq(false)   
  end

  it "create an authority" do
    org = IsoNamespace.new
    org.id = "NS-CCC_NS"
    org.namespace = "http://www.assero.co.uk/MDRItems"
    org.name = "CCC Long"
    org.shortName = "CCC"
    expect(IsoNamespace.create({shortName: "CCC", name: "CCC Long"}).to_json).to eq(org.to_json) 
    result = IsoRegistrationAuthority.new
    result.id = "RA-DUNS_222233334"
    result.number = "222233334"
    result.scheme = "DUNS"
    result.namespace = IsoNamespace.find("NS-DDD")
    result.owner = false
    ra = IsoRegistrationAuthority.create({number: "222233334", namespaceId: org.id})
    expect(ra.errors.count).to eq(0)
	end

  it "prevents an invalid authority from being created" do
    org = IsoNamespace.new
    org.id = "NS-CCC_NS"
    org.namespace = "http://www.assero.co.uk/MDRItems"
    org.name = "CCC Long"
    org.shortName = "CCC"
    ra = IsoRegistrationAuthority.create({number: "2222333344", namespaceId: org.id})
    expect(ra.errors.count).to eq(1)
    expect(ra.errors.full_messages.to_sentence).to eq("Number does not contains 9 digits")
  end

  it "prevents an existing authority from being created" do
    org = IsoNamespace.new
    org.id = "NS-CCC_NS"
    org.namespace = "http://www.assero.co.uk/MDRItems"
    org.name = "CCC Long"
    org.shortName = "CCC"
    ra = IsoRegistrationAuthority.create({number: "222233334", namespaceId: org.id})
    expect(ra.errors.count).to eq(1)
    expect(ra.errors.full_messages.to_sentence).to eq("The registration authority already exists.")
  end

  it "handles a bad response error - destroy" do
    object = IsoRegistrationAuthority.find("RA-DUNS_222233334")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.destroy}.to raise_error(Exceptions::DestroyError)
  end

  it "handles a bad response error - create" do
    org = IsoNamespace.new
    org.id = "NS-CCC_NS"
    org.namespace = "http://www.assero.co.uk/MDRItems"
    org.name = "CCC Long"
    org.shortName = "CCC"
    allow_any_instance_of(IsoRegistrationAuthority).to receive(:exists?).and_return(false)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(IsoNamespace).to receive(:find).and_return(org)
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{IsoRegistrationAuthority.create({number: "222233334", namespaceId: org.id})}.to raise_error(Exceptions::CreateError)
  end

  it "destroy a authority" do
    object = IsoRegistrationAuthority.find("RA-DUNS_222233334")
    object.destroy
  end

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace_duplicate.ttl")
  end

  it "finds all authorities - duplicate error" do
    expect{IsoRegistrationAuthority.all}.to raise_error(Exceptions::MultipleOwnerError)
  end
end