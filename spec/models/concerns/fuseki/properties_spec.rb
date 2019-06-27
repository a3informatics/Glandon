require 'rails_helper'
require 'iso_namespace'

describe Fuseki::Properties do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/properties"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  class BaseTestFP
 
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods

    extend Fuseki::Schema
    extend Fuseki::Resource
    include Fuseki::Properties

    attr_accessor :uri

    def self.rdf_type
      self::C_URI
    end

    def rdf_type
      self.class::C_URI
    end

  end 

  def metadata_to_h(properties)
    result = {}
    properties.metadata.each do |k,v| 
      y = v.dup
      y[:predicate] = y[:predicate].to_s
      result[k] = y
    end
    result
  end

  class TestFP1 < BaseTestFP
    
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
              base_uri: "http://www.assero.co.uk/RA" 

    data_property :organization_identifier, default: "<Not Set>" 
    data_property :international_code_designator, default: "XXX"
    data_property :owner, default: false
    object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace"
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority", path_exclude: true

    def self.class_properties
      properties_metadata_class
    end

    def instance_properties
      properties_metadata
    end

  end 

  it "get properties, class and instance" do
    temp = TestFP1.new
    result = TestFP1.class_properties
    check_file_actual_expected(metadata_to_h(result), sub_dir, "properties_metadata_expected_1.yaml", write_file: true)
    item = TestFP1.new
    result = item.instance_properties
    check_file_actual_expected(metadata_to_h(result), sub_dir, "properties_metadata_expected_1.yaml")
  end

  it "relationships" do
    temp = TestFP1.new
    result = TestFP1.class_properties
    check_file_actual_expected(result.relationships, sub_dir, "relationships_expected_1.yaml", write_file: true)
    item = TestFP1.new
    result = item.instance_properties
    check_file_actual_expected(result.relationships, sub_dir, "relationships_expected_1.yaml")
  end

  it "managed paths" do
    temp = TestFP1.new
    result = TestFP1.class_properties
    check_file_actual_expected(result.managed_paths, sub_dir, "managed_paths_expected_1.yaml", write_file: true)
    item = TestFP1.new
    result = item.instance_properties
    check_file_actual_expected(result.managed_paths, sub_dir, "managed_paths_expected_1.yaml")
  end

end