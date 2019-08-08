require 'rails_helper'
require 'iso_namespace'

describe Fuseki::Resource::Properties do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/resource/properties"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  class TestR10 < Fuseki::Base
    
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority",
              base_uri: "http://www.assero.co.uk/RA" 

    data_property :organization_identifier, default: "<Not Set>" 
    data_property :international_code_designator, default: "XXX"
    data_property :owner, default: false
    object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace"
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority", path_exclude: true

  end 

  it "setup properties" do
    metadata = TestR10.resources
    item = TestR10.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    expect(properties.parent.class).to eq(TestR10)
    check_file_actual_expected(properties.metadata, sub_dir, "properties_new_expected_1.yaml")
  end
  
  it "ignore property" do
    metadata = TestR10.resources
    item = TestR10.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    expect(properties.ignore?(:fred)).to eq(true)
    expect(properties.ignore?(:owner)).to eq(false)
    expect(properties.ignore?(:ra_namespace)).to eq(false)
  end  

  it "property" do
    metadata = TestR10.resources
    item = TestR10.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    result = properties.property(:owner)
    check_file_actual_expected(result.metadata, sub_dir, "property_expected_1.yaml")
  end  

  it "assign" do
    metadata = TestR10.resources
    item = TestR10.new
    item.properties.assign(organization_identifier: "NEW", owner: true)
    expect(item.owner).to eq(true)
    expect(item.organization_identifier).to eq("NEW")
  end  

  it "sets property from triple" do
    metadata = TestR10.resources
    item = TestR10.new
    properties = Fuseki::Resource::Properties.new(item, metadata)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), object: ""})
    expect(result).to eq(nil)
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#internationalCodeDesignator"), object: "EEEEE"})
    expect(result.name).to eq(:international_code_designator)
    expect(result.get).to eq("EEEEE")
    result = properties.property_from_triple({subject: "", predicate: Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#raNamespace"), object: Uri.new(uri: "http://www.assero.co.uk/A#A")})
    expect(result.name).to eq(:ra_namespace)
    expect(result.get.to_s).to eq("http://www.assero.co.uk/A#A")
  end

end