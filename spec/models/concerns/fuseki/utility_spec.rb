require 'rails_helper'

describe Fuseki::Utility do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/utility"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  class BaseTestFU
 
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods

    include Fuseki::Persistence
    include Fuseki::Utility
    include Fuseki::Diff
    extend Fuseki::Schema
    extend Fuseki::Resource

    attr_accessor :uri

    set_schema

    def initialize(props)
      @new_record = true
      @destroyed = false
      @properties = Fuseki::Resource::Properties.new(self, props)
    end

    def self.rdf_type
      self::C_URI
    end

    def rdf_type
      self.class::C_URI
    end

    def properties
      @properties
    end

  end 

  class TestToH

    def to_h
      return {test_1: "XXX", test_2: 1}
    end

    def self.from_h(values)
      object = self.new
      object.instance_variable_set(:@test_1, values[:test_1])
      object.instance_variable_set(:@test_2, values[:test_2])
      object
    end

  end

  class TestFU1 < BaseTestFU

    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority")

    attr_accessor :owner
    attr_accessor :organization_identifier

    def initialize
      props = 
      {
        "owner".to_sym => {type: :data, cardinality: :one, predicate: "http://www.assero.co.uk/ISO11179Registration#owner", base_type: XSDDatatype.new("boolean")},
        "organization_identifier".to_sym => {type: :data, cardinality: :one, predicate: "http://www.assero.co.uk/ISO11179Registration#organizationIdentifier", base_type: XSDDatatype.new("string")},
      }
      @owner = false
      @organization_identifier = ""
      @rdf_type = C_URI
      super(props)
    end

  end

  class TestFU2 < BaseTestFU
    
    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")

    attr_accessor :effective_date
    attr_accessor :ra_namespace

    def initialize
      props = 
      {
        "ra_namespace".to_sym => {type: :object, cardinality: :one, predicate: "http://www.assero.co.uk/ISO11179Registration#raNamespace", base_type: XSDDatatype.new("")}, 
        "effective_date".to_sym => {type: :data, cardinality: :one, predicate: "http://www.assero.co.uk/ISO11179Registration#effectiveDate", base_type: XSDDatatype.new("dateTime")}
      }
      self.class.instance_variable_set(:@properties, props)
      @effective_date = "".to_time_with_default
      @ra_namespace = []
      @rdf_type = C_URI
      super(props)
    end

  end 

  class TestFU3 < TestFU2
    
    attr_accessor :effective_date
    attr_accessor :ra_namespace

    def initialize
      super
      @effective_date = "".to_time_with_default
      @ra_namespace = nil
      @rdf_type = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")
    end

  end 

  it "to hash, simple" do
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    expected = {
      owner: "12345", 
      organization_identifier: "Hello World", 
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
      uri: uri_s.to_s,
      id: uri_s.to_id
    }
    item = TestFU1.new
    item.uri = uri_s
    item.owner = "12345"
    item.organization_identifier = "Hello World"
    expect(item.to_h).to eq(expected)
  end

  it "to hash, URI Array" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    expected = {
      effective_date: "2016-01-01T00:00:00+00:00", 
      ra_namespace: [uri.to_s, uri.to_s],
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
      uri: uri_s.to_s,
      id: uri_s.to_id
    }
    item = TestFU2.new
    item.uri = uri_s
    item.ra_namespace << uri
    item.ra_namespace << uri
    expect(item.to_h).to eq(expected)
  end

  it "to hash, URI" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    expected = {
      effective_date: "2016-01-01T00:00:00+00:00", 
      ra_namespace: uri.to_s,
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
      uri: uri_s.to_s, 
      id: uri_s.to_id
    }
    item = TestFU3.new
    item.uri = uri_s
    item.ra_namespace = uri
    expect(item.to_h).to eq(expected)
  end
 
  it "to hash, to_h method" do
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    expected = {
      effective_date: "2016-01-01T00:00:00+00:00", 
      ra_namespace: TestToH.new.to_h,
      rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
      uri: uri_s.to_s,
      id: uri_s.to_id
    }
    item = TestFU3.new
    item.uri = uri_s
    item.ra_namespace = TestToH.new
    expect(item.to_h).to eq(expected)
  end
 
  it "from hash, simple" do
    input = {owner: true, organization_identifier: "123"}
    result = TestFU1.from_h(input)
    expect(result.owner).to eq(input[:owner])
    expect(result.organization_identifier).to eq(input[:organization_identifier])
  end

  it "from hash, URI" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    input = {effective_date: "2016-01-01T00:00:00+00:00", ra_namespace: uri}
    result = TestFU3.from_h(input)
    expect(result.effective_date).to eq(input[:effective_date])
    expect(result.ra_namespace).to eq(uri)
  end

  it "from hash, URI as string" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    input = {effective_date: "2016-01-01T00:00:00+00:00", ra_namespace: uri.to_s, uri: uri_s}
    result = TestFU3.from_h(input)
    expect(result.effective_date).to eq(input[:effective_date])
    expect(result.ra_namespace).to eq(uri)
    expect(result.uri).to eq(uri_s)
  end

  it "to array by key" do
    result = TestFU1.from_h(owner: true, organization_identifier: "123")
    expect(result.to_a_by_key(:owner)).to eq([true])
    expect(result.to_a_by_key(:owner, :organization_identifier)).to eq([true, "123"])
  end

end