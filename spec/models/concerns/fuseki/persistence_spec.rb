require 'rails_helper'
require 'Uri' # Needed to perform the YAML read since it contains classes.

describe Fuseki::Persistence do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/persistence"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_managed_data_4.ttl"]
    load_files(schema_files, data_files)
  end

  after :each do
  end

  class TestFPe1 < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/ISO11179Types#AdministeredItem"

    object_property :has_state, cardinality: :one, model_class: "IsoRegistrationStateV2"
    object_property :has_identifier, cardinality: :one, model_class: "IsoScopedIdentifierV2"
    data_property :change_description

  end

  class TestFPe2 < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/ISO11179Types#AdministeredItem"

    object_property :has_identifier, cardinality: :many, model_class: "IsoScopedIdentifierV2"
    data_property :change_description

  end

  it "find, simple case" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    result = TestFPe1.find(uri)
    expect(result.change_description).to eq("Creation")
    expect(result.has_identifier.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
    expect(result.has_state.to_s).to eq("http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1")
  end

  it "find with cache" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#BBB")
    expect(Fuseki::Base.cache_has_key?(uri)).to eq(false)
    result = IsoNamespace.find(uri)
    expect(result.name).to eq("BBB Pharma")
    expect(Fuseki::Base.cache_has_key?(uri)).to eq(true)
    result = IsoNamespace.find(uri)
    expect(result.name).to eq("BBB Pharma")
  end

  it "find children" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    result = TestFPe1.find_children(uri)
    check_file_actual_expected(result.to_h, sub_dir, "find_children_expected_1.yaml", equate_method: :hash_equal)
  end

  it "finds objects and links, single" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    result = TestFPe1.find(uri)
    expect(result.change_description).to eq("Creation")
    expect(result.has_identifier.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
    expect(result.has_identifier_links?).to eq(true)
    expect(result.has_identifier_objects?).to eq(false)
    result.has_identifier_objects
    expect(result.has_identifier_links?).to eq(true)
    expect(result.has_identifier_objects?).to eq(true)
    expect(result.has_identifier.identifier).to eq("TEST")
  end

  it "finds objects and links, array" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    result = TestFPe2.find(uri)
    expect(result.change_description).to eq("Creation")
    expect(result.has_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
    expect(result.has_identifier_links?).to eq(true)
    expect(result.has_identifier_objects?).to eq(false)
    result.has_identifier_objects
    expect(result.has_identifier_links?).to eq(true)
    expect(result.has_identifier_objects?).to eq(true)
    expect(result.has_identifier.first.identifier).to eq("TEST")
  end

  it "clones an object" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = TestFPe1.find(uri)
    result = item.clone
    expect(result.change_description).to eq("Creation")
    expect(result.has_identifier.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
    expect(result.has_state.to_s).to eq("http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1")
  end

  it "returns the true type" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    expect(item.true_type.to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
    expect(item.my_type.to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
    expect(Fuseki::Base.the_type(uri).to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAAxxx")
    expect{Fuseki::Base.the_type(uri)}.to raise_error(Errors::ApplicationLogicError, "Unable to find the RDF type for http://www.assero.co.uk/NS#AAAxxx.")
    expect_any_instance_of(Sparql::Query).to receive(:query).and_return([])
    expect{item.true_type}.to raise_error(Errors::ApplicationLogicError, "Unable to find true type for http://www.assero.co.uk/NS#AAA.")
  end


  it "same type" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    expect(Fuseki::Base.same_type([uri_1, uri_1], IsoNamespace.rdf_type)).to eq(true)
    expect(Fuseki::Base.same_type([uri_1, uri_2], IsoNamespace.rdf_type)).to eq(false)
    expect_any_instance_of(Sparql::Query).to receive(:query).and_return([])
    expect{Fuseki::Base.same_type([uri_1, uri_1], IsoNamespace.rdf_type)}.to raise_error(Errors::ApplicationLogicError, "Unable to find the RDF type for the set of URIs.")
  end

end