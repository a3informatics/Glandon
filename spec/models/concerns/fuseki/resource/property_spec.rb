require 'rails_helper'

describe Fuseki::Resource::Property do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/resource/property"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  # class BaseTestFpp
 
  #   include ActiveModel::Naming
  #   include ActiveModel::Conversion
  #   include ActiveModel::Validations
  #   include ActiveModel::AttributeMethods

  #   include Fuseki::Resource

  #   def initialize
  #     self.class.class_variable_set(:@@schema, Fuseki::Schema::SchemaMap.new({}))
  #     props = 
  #     {
  #       "registration_authority".to_sym => {type: :object, model_class: "TestFpp1"}, 
  #       "owner".to_sym => {type: :data},
  #       "organization_identifier".to_sym => {type: :data},
  #       "effective_date".to_sym => {type: :data}
  #     }
  #     self.class.instance_variable_set(:@properties, props)
  #   end

  #   def from_uri_test(name, uri)
  #     from_uri(name, uri)
  #   end

  #   def from_simple_test(name, value)
  #     from_simple(name, value)
  #   end

  #   def from_triple_test(triple)
  #     from_triple(triple)
  #   end

  #   def from_value_test(name, value)
  #     from_value(name, value)
  #   end

  #   def from_hash_test(name, value)
  #     from_hash(name, value)
  #   end

  #   def self.rdf_type
  #     self::C_URI
  #   end

  # end 

  # class TestFpp1 < BaseTestFpp

  #   C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority")

  #   attr_accessor :owner
  #   attr_accessor :organization_identifier

  #   def initialize
  #     @owner = false
  #     @organization_identifier = ""
  #     @rdf_type = C_URI
  #     super
  #   end

  #   def self.from_h(value)
  #     object = self.new
  #     object.owner = value[:owner]
  #     object.organization_identifier = value[:organization_identifier]
  #     object
  #   end

  #   def to_h
  #     return {owner: @owner, organization_identifier: @organization_identifier}
  #   end

  # end

  # class TestFpp2 < BaseTestFpp
    
  #   C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")

  #   attr_accessor :effective_date
  #   attr_accessor :registration_authority

  #   def initialize
  #     @effective_date = "".to_time_with_default
  #     @registration_authority = []
  #     @rdf_type = C_URI
  #     super
  #   end

  # end 

  # class TestFpp3 < BaseTestFpp
    
  #   attr_accessor :effective_date
  #   attr_accessor :registration_authority

  #   def initialize
  #     @effective_date = "".to_time_with_default
  #     @registration_authority = nil
  #     @rdf_type = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")
  #     super
  #   end

  # end 

  # class TestFpp4 < BaseTestFpp
    
  #   attr_accessor :effective_date
  #   attr_accessor :registration_authority

  #   def initialize
  #     @effective_date = "".to_time_with_default
  #     @registration_authority = nil
  #     @rdf_type = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")
  #     super
  #   end

  # end 

  class TestFRP
  end

  it "allows for simple update" do
    item = Fuseki::Resource::Property.new(:fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: ""})
    expect(item.name).to eq(:fred)
    expect(item.klass).to eq(TestFRP)
    expect(item.cardinality).to eq(:one)
    expect(item.predicate).to eq("XXX")
    expect(item.object?).to eq(true)
    expect(item.array?).to eq(false)
    expect(item.default_value).to eq(true)

    uri = Uri.new(uri: "http://wwww.a.com/pathsec#1")
    item.set_value(uri)
    expect(item.get).to eq(uri)
    expect(item.uri?).to eq(true)

    item.set_value([uri, uri])
    expect(item.get).to eq([uri, uri])
    expect(item.uri?).to eq(true)

    item.set_uri(uri)
    expect(item.get).to eq(uri)

    item.set_uri(uri.to_s)
    expect(item.get).to eq(uri)

    item = Fuseki::Resource::Property.new(:fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: "dateTime"})
    time = Time.now
    item.set_simple(time)
    expect(item.get).to eq(time)

    item = Fuseki::Resource::Property.new(:fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: "string"})
    item.set_simple("XXX")
    expect(item.get).to eq("XXX")

    item = Fuseki::Resource::Property.new(:fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: "boolean"})
    item.set_simple(true)
    expect(item.get).to eq(true)

    item = Fuseki::Resource::Property.new(:fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: "integer"})
    item.set_simple(1)
    expect(item.get).to eq(1)
    
  end

  it "schema predicate name" do
    expect(Fuseki::Resource::Property.schema_predicate_name("this_is_a")).to eq("thisIsA")
  end

end