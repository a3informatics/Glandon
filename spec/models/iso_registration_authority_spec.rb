require 'rails_helper'

describe IsoRegistrationAuthority do
	
  include DataHelpers

  before :all do
    IsoHelpers.clear_cache
  end

  describe "Basic Tests" do

    before :each do
      schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = IsoRegistrationAuthority.new
      result.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
      result.organization_identifier = "123456777"
      result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, identifier" do
      result = IsoRegistrationAuthority.new
      result.ra_namespace = IsoNamespace.find_by_short_name("BBB")
      expect(result.valid?).to eq(false) # organization_identifier set to "<Not_Set>" by default.
    end

    it "does not validate an invalid object, scheme" do
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
      expected = {uri: "http://www.assero.co.uk/MDRItems#XXX", id: result.uuid, organization_identifier: "123456777",
        rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
        international_code_designator: "DUNS", owner: false, ra_namespace: IsoNamespace.find_by_short_name("BBB").to_h }
      expect(result.to_h).to eq(expected)
    end

    it "finds authority" do
      expected = {organization_identifier: "123456789", international_code_designator: "DUNS", owner: true, uri: "http://www.assero.co.uk/RA#DUNS123456789",
        id: Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789").to_id,
        rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
        ra_namespace: "http://www.assero.co.uk/NS#BBB",}
      result = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      expect(result.to_h).to eq(expected)   
      expect(result.persisted?).to eq(true)   
    end

  	it "finds all authorities" do
      result_1 = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      result_2 = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS111111111"))
      results = [
        { 
          organization_identifier: "123456789", international_code_designator: "DUNS", owner: true, uri: "http://www.assero.co.uk/RA#DUNS123456789",
          rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
          ra_namespace: "http://www.assero.co.uk/NS#BBB", id: result_1.uuid
        },
        {
          organization_identifier: "111111111", international_code_designator: "DUNS", owner: false, uri: "http://www.assero.co.uk/RA#DUNS111111111", 
          rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority", 
          ra_namespace: "http://www.assero.co.uk/NS#AAA", id: result_2.uuid
        }
      ]
      expect(IsoRegistrationAuthority.all.map{|x| x.to_h}).to eq(results)   
    end

    it "finds authority by short name" do
      expected = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      result = IsoRegistrationAuthority.find_by_short_name("BBB")
      expect(result.to_h).to eq(expected.to_h)   
      expect(result.persisted?).to eq(true)   
    end

  	it "determines if authority exists" do
      expect(IsoRegistrationAuthority.exists?("AAA")).to eq(true)    
    end

    it "determines if authority does not exist" do
      expect{IsoRegistrationAuthority.exists?("AAA1")}.to raise_error(Exceptions::NotFoundError, "Failed to find short name AAA1 in IsoRegistrationAuthority object.")
    end

    it "create an authority" do
      ns = IsoNamespace.find_by_short_name("BBB")
      result = IsoRegistrationAuthority.create(organization_identifier: "222233334", international_code_designator: "DUNS", owner: false, namespace_id: ns.id)
      expect(result.errors.count).to eq(0)
  	end

    it "prevents an invalid authority from being created" do
      ns = IsoNamespace.find_by_short_name("BBB")
      result = IsoRegistrationAuthority.create(organization_identifier: "123456AAA", international_code_designator: "DUNS", owner: false, namespace_id: ns.id)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("Organization identifier is invalid")
    end

    it "prevents an existing authority from being created" do
      ns = IsoNamespace.find_by_short_name("BBB")
      result = IsoRegistrationAuthority.create(organization_identifier: "123456789", 
        international_code_designator: "DUNS", owner: false, namespace_id: ns.id)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("an existing record (organization_identifier: 123456789) exisits in the database")
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
        ra_namespace: IsoNamespace.find_by_short_name("BBB").to_h,
        id: result.uuid 
      }
      expect(result.to_h).to eq(expected)
    end

  end

  describe "Scope Tests" do

    before :each do
      schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "repository scope id" do
      result = IsoRegistrationAuthority.repository_scope
      expect(result.id).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ==")
      (1..100).each {|x| IsoRegistrationAuthority.repository_scope}
    end

    it "cdisc scope id" do
      result = IsoRegistrationAuthority.cdisc_scope
      expect(result.id).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQ0RJU0M=")
      (1..100).each {|x| IsoRegistrationAuthority.cdisc_scope}
    end

  end

end