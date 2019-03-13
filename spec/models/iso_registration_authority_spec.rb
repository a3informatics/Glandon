require 'rails_helper'

describe IsoRegistrationAuthority do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
  end

  it "validates a valid object" do
    result = IsoRegistrationAuthority.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    result.organization_identifier = "123456777"
    result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    result = IsoRegistrationAuthority.new
    result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    expect(result.valid?).to eq(false) # organization_identifier set to "<Not_Set>" by default.
  end

  it "does not validate an invalid object" do
    result = IsoRegistrationAuthority.new
    result.organization_identifier = "123456777"
    result.international_code_designator = "DUS"
    result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    result.owner = false
    expect(result.valid?).to eq(false)
  end

  it "can be filled from JSON" do
    input = {uri: "http://www.assero.co.uk/MDRItems#XXX", organization_identifier: "123456777", 
      international_code_designator: "DUNS", owner: false, ra_namespace: IsoNamespace.find_by_short_name("BBB").to_h}
    result = IsoRegistrationAuthority.from_h(input)
    expect(result.uri.to_s).to eq("http://www.assero.co.uk/MDRItems#XXX")
    expect(result.international_code_designator).to eq("DUNS")
  end

	it "can be returned as JSON" do
    result = IsoRegistrationAuthority.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    result.organization_identifier = "123456777"
    result.international_code_designator = "DUNS"
    result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    result.owner = false
    expect(result.to_h).to eq({uri: "http://www.assero.co.uk/MDRItems#XXX", organization_identifier: "123456777",
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
      international_code_designator: "DUNS", owner: false, ra_namespace: IsoNamespace.find_by_short_name("BBB").to_h })
  end

  it "finds authority" do
    result = {organization_identifier: "123456789", international_code_designator: "DUNS", owner: true, uri: "http://www.assero.co.uk/RA#DUNS123456789",
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
      ra_namespace: "http://www.assero.co.uk/NS#BBB",}
    expect(IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")).to_h).to eq(result)   
  end

	it "finds all authorities" do
    results = [
      { 
        organization_identifier: "123456789", international_code_designator: "DUNS", owner: true, uri: "http://www.assero.co.uk/RA#DUNS123456789",
        rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
        ra_namespace: "http://www.assero.co.uk/NS#BBB"
      },
      {
        organization_identifier: "111111111", international_code_designator: "DUNS", owner: false, uri: "http://www.assero.co.uk/RA#DUNS111111111", 
        rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
        ra_namespace: "http://www.assero.co.uk/NS#AAA"
      }
    ]
    expect(IsoRegistrationAuthority.all.map{|x| x.to_h}).to eq(results)   
  end

  it "finds authority by short name" do
    result = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    expect(IsoRegistrationAuthority.find_by_short_name("BBB").to_h).to eq(result.to_h)   
  end

	it "determines if authority exists" do
    expect(IsoRegistrationAuthority.exists?("AAA")).to eq(true)    
  end

  it "determines if authority does not exist" do
    expect{IsoRegistrationAuthority.exists?("AAA1")}.to raise_error(Exceptions::NotFoundError, "Failed to find short name AAA1 in IsoRegistrationAuthority object.")
  end

  it "create an authority" do
    result = IsoRegistrationAuthority.create(organization_identifier: "222233334", international_code_designator: "DUNS", owner: false)
    expect(result.errors.count).to eq(0)
	end

  it "prevents an invalid authority from being created" do
    result = IsoRegistrationAuthority.create(organization_identifier: "123456AAA", international_code_designator: "DUNS", owner: false)
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("Organization identifier is invalid")
  end

  it "prevents an existing authority from being created" do
    result = IsoRegistrationAuthority.create(organization_identifier: "123456789", 
      international_code_designator: "DUNS", owner: false)
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("An existing record exisits in the database")
  end

  it "destroy a authority" do
    object = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    object.delete
  end

  it "returns the owner" do
    result = IsoRegistrationAuthority.owner
    expected = 
    {
      uri: "http://www.assero.co.uk/RA#DUNS123456789", 
      organization_identifier: "123456789",
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
      international_code_designator: "DUNS", 
      owner: true, 
      ra_namespace: IsoNamespace.find_by_short_name("BBB").to_h 
    }
    expect(result.to_h).to eq(expected)
  end

end