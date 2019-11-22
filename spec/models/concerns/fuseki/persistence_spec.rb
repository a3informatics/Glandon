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

  class TestFPe3 < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/ISO11179Types#AdministeredItem"

    object_property :has_identifier, cardinality: :many, model_class: "TestFPe3"

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

  it "generates selective update sparql" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    item.name = "Updated Name Property"
    sparql = Sparql::Update.new
    actual = item.to_selective_sparql(sparql)
    expect(sparql.to_triples).to eq("<http://www.assero.co.uk/NS#AAA> isoI:name \"Updated Name Property\"^^xsd:string . \n")
    expect(actual).to match_array([Uri.new(uri: "http://www.assero.co.uk/ISO11179Identification#name")])
  end

  it "performs selective update" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    item.name = "Updated Name Property"
    item.selective_update
    result = IsoNamespace.find(uri)
    check_file_actual_expected(result.to_h, sub_dir, "selective_update_expected_1.yaml", equate_method: :hash_equal)
    item.name = "Updated Name Property, a further update"
    item.short_name = "Modified Short Name"
    item.selective_update
    result = IsoNamespace.find(uri)
    check_file_actual_expected(result.to_h, sub_dir, "selective_update_expected_2.yaml", equate_method: :hash_equal)
  end

  it "performs update - WILL CURRENTLY FAIL - Fails in main test, passes in isolation." do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    item.name = "Updated Name Property"
    result = item.update
    expect(result.errors.count).to eq(0)
    result = IsoNamespace.find(uri)
    check_file_actual_expected(result.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
  # puts "ERROR START"
  #   item.name = "Updated Name Property, a further update±±±±±"
  #   result = item.update
  # puts "ERROR END"
  #   expect(result.errors.count).to eq(1)
  #   item.name = "Updated Name Property, a further update"
  #   item.short_name = "ShortName"
  #   result = item.update
  #   expect(result.errors.count).to eq(0)
  end

  it "performs update - WILL CURRENTLY FAIL - Fails in main test, passes in isolation." do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
  puts "ERROR START"
    item.name = "Updated Name Property, a further update±±±±±"
    result = item.update
  puts "ERROR END"
    expect(result.errors.count).to eq(1)
    item.name = "Updated Name Property, a further update"
    item.short_name = "ShortName"
    result = item.update
    expect(result.errors.count).to eq(0)
  puts "ERROR START"
    item.name = "Updated Name Property, a further update±±±±±"
    result = item.update
  puts "ERROR END"
    expect(result.errors.count).to eq(1)
  end

  it "performs save - WILL CURRENTLY FAIL - Fails in main test, passes in isolation." do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    item.name = "Updated Name Property"
    result = item.save
    expect(result.errors.count).to eq(0)
    result = IsoNamespace.find(uri)
    check_file_actual_expected(result.to_h, sub_dir, "save_expected_1.yaml", equate_method: :hash_equal)
    item.name = "Updated Name Property, a further update±±±±±"
    result = item.save
    expect(result.errors.count).to eq(1)
    item.name = "Updated Name Property, a further update"
    item.short_name = "ShortName"
    result = item.save
    expect(result.errors.count).to eq(0)
    item = IsoNamespace.new
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#SaveTest")
    item.uri = uri
    item.name = "Save Test"
    item.short_name = "SaveTest"
    item.authority = "www.a3.com"
    item.save
    result = IsoNamespace.find(uri)
    check_file_actual_expected(result.to_h, sub_dir, "save_expected_2.yaml", equate_method: :hash_equal)
    item = IsoNamespace.new
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#SaveTest2")
    item.uri = uri
    item.name = "Save Test"
    item.short_name = "SaveTest±±±±±±±"
    item.authority = "www.a3.com"
    result = item.save
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("Short name contains invalid characters")
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.new(uri: uri, name: "A name", short_name: "SaveTest", authority: "www.a3.com") # Try to create same short_name, should fail.
    result = item.save
    expect(result.errors.count).to eq(1)
    expect(result.errors.full_messages.to_sentence).to eq("An existing record exisits in the database")
  end

  it "id and uuid" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.find(uri)
    expect(item.id).to eq(uri.to_id)
    expect(item.uuid).to eq(uri.to_id)
  end

  it "persisted" do
    item = IsoNamespace.new
    expect(item.inspect_persistence).to eq({new: true, destroyed: false})
    expect(item.persisted?).to eq(false)
    expect(item.new_record?).to eq(true)
    expect(item.destroyed?).to eq(false)
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = IsoNamespace.new(uri: uri, name: "A name", short_name: "SaveTest", authority: "www.a3.com") # Try to create same short_name, should fail.
    item = item.save
    expect(item.inspect_persistence).to eq({new: false, destroyed: false})
    expect(item.persisted?).to eq(true)
    expect(item.new_record?).to eq(false)
    expect(item.destroyed?).to eq(false)
    item.delete
    expect(item.inspect_persistence).to eq({new: false, destroyed: true})
    expect(item.persisted?).to eq(false)
    expect(item.new_record?).to eq(false)
    expect(item.destroyed?).to eq(true)
  end

  it "deletes object with reference links" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/FP3#1")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/FP3#2")
    item_1 = TestFPe3.create(uri: uri_1)
    item_2 = TestFPe3.create(uri: uri_2)
    item_1_c = TestFPe3.find(uri_1)
    item_2_c = TestFPe3.find(uri_2)    
    expect(item_1_c.has_identifier.count).to eq(0)
    expect(item_2_c.has_identifier.count).to eq(0)
    item_1.add_link(:has_identifier, item_2.uri)
    item_1_c = TestFPe3.find(uri_1)
    expect(item_1_c.has_identifier.count).to eq(1)
    item_2.delete_with_links    
    expect{TestFPe3.find(uri_2)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/FP3#2 in TestFPe3.")
    item_1_c = TestFPe3.find(uri_1)
    expect(item_1_c.has_identifier.count).to eq(0)
  end
    
end