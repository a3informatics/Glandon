require 'rails_helper'

describe Fuseki::Persistence::Property do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/persistence/property"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
  end

  after :all do
    delete_all_public_test_files
  end

  class BaseTest
 
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods

    include Fuseki::Persistence::Property
    #extend Fuseki::Schema
    #extend Fuseki::Properties

    def initialize
      @@schema = Fuseki::Schema::SchemaMap.new({})
      props = 
      {
        "@registration_authority".to_sym => {type: :object}, 
        "@owner".to_sym => {type: :data},
        "@organization_identifier".to_sym => {type: :data},
        "@effective_date".to_sym => {type: :data}
      }
      self.class.instance_variable_set(:@properties, props)
    end

    def from_uri_test(name, uri)
      from_uri(name, uri)
    end

    def from_simple_test(name, value)
      from_simple(name, value)
    end

    def from_triple_test(triple)
      from_triple(triple)
    end

    def self.rdf_type
      self::C_URI
    end

  end 

  class TestFpp1 < BaseTest

    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority")

    attr_accessor :owner
    attr_accessor :organization_identifier

    def initialize
      @owner = false
      @organization_identifier = ""
      @rdf_type = C_URI
      super
    end

  end

  class TestFpp2 < BaseTest
    
    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")

    attr_accessor :effective_date
    attr_accessor :registration_authority

    def initialize
      @effective_date = "".to_time_with_default
      @registration_authority = []
      @rdf_type = C_URI
      super
    end

  end 

  class TestFpp3 < BaseTest
    
    attr_accessor :effective_date
    attr_accessor :registration_authority

    def initialize
      @effective_date = "".to_time_with_default
      @registration_authority = nil
      @rdf_type = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")
      super
    end

  end 

  it "allows for simple update" do
    item = TestFpp1.new
    expect(item.owner).to eq(false)
    expect(item.organization_identifier).to eq("")
    allow_any_instance_of(Fuseki::Schema::SchemaMap).to receive(:range).and_return("boolean")
    item.from_simple_test(:@owner, true)
    expect(item.owner).to eq(true)
    allow_any_instance_of(Fuseki::Schema::SchemaMap).to receive(:range).and_return("string")
    item.from_simple_test(:@organization_identifier, "1234567890")
    expect(item.organization_identifier).to eq("1234567890")
    item = TestFpp2.new
    allow_any_instance_of(Fuseki::Schema::SchemaMap).to receive(:range).and_return("dateTime")
    expect(item.effective_date.iso8601.to_s).to eq("2016-01-01T00:00:00+00:00")
    expect(item.registration_authority).to eq([])
    item.from_simple_test(:@effective_date, "2019-01-02T01:02:03+00:00")
    expect(item.effective_date.iso8601.to_s).to eq("2019-01-02T01:02:03+00:00")
  end

  it "allows for URI update" do
    item = TestFpp2.new
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    expect(item.registration_authority.count).to eq(0)
    item.from_uri_test(:@registration_authority, uri)
    expect(item.registration_authority.count).to eq(1)
    expect(item.registration_authority.first).to eq(uri.to_s)
    item.from_uri_test(:@registration_authority, uri)
    expect(item.registration_authority.count).to eq(2)
    expect(item.registration_authority.last).to eq(uri.to_s)
  end

  it "allows for Triple updat, array" do
    item = TestFpp2.new
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    triple = 
    {
      subject: nil, 
      predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#registrationAuthority"), 
      object: uri
    }
    expect(item.registration_authority.count).to eq(0)
    item.from_triple_test(triple)
    expect(item.registration_authority.count).to eq(1)
    expect(item.registration_authority.first).to eq(uri.to_s)
    item.from_triple_test(triple)
    expect(item.registration_authority.count).to eq(2)
    expect(item.registration_authority.last).to eq(uri.to_s)
  end

  it "allows for Triple update, single" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    triple = 
    {
      subject: nil, 
      predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#registrationAuthority"), 
      object: uri
    }
    item = TestFpp3.new
    expect(item.registration_authority).to be_nil
    item.from_triple_test(triple)
    expect(item.registration_authority.to_s).to eq(uri.to_s)
  end

end