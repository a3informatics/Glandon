require 'rails_helper'

describe Fuseki::Base do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/base"
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

  class TestFb1 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace"
    data_property :short_name
    data_property :name
  end

  class TestFb2 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace"
    data_property :short_name
    data_property :name
    data_property :authority
  end

  class TestFb3 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    object_property :ra_namespace, cardinality: :many, model_class: "IsoNamespace"
  end

  class TestFb4 < TestFb3
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    data_property :organization_identifier
    data_property :international_code_designator
  end

  class TestFb5 < TestFb4
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    data_property :owner
  end

  class TestFb6 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    object_property :ra_namespace, cardinality: :one, model_class: "IsoNamespace"
    data_property :organization_identifier
    data_property :international_code_designator
    data_property :owner
  end

  it "allows for the class to be created, uri" do
    item = TestFb1.new
    item.short_name = "AAA"
    expect(item.short_name).to eq("AAA")
  end

  it "find, simple results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = TestFb2.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.id).to eq(Base64.strict_encode64(uri.to_s))
    expect(item.short_name).to eq("AAA")
    expect(item.name).to eq("AAA Long")
    expect(item.authority).to eq("www.aaa.com")
  end

  it "find, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb3.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "find, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb3.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "find, simple and URI results, inheritence I" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb4.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
  end

  it "find, simple and URI results, inheritence II" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb5.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "allows for the children class to be read I, array" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb5.find(uri)
    expect(item.ra_namespace_objects?).to eq(false)
    expect(item.ra_namespace_objects.count).to eq(1)
    expect(item.ra_namespace_objects?).to eq(true)
    expect(item.ra_namespace_objects.first.short_name).to eq("BBB")
    expect(item.ra_namespace_objects.first.name).to eq("BBB Pharma")
    expect(item.ra_namespace_objects.first.authority).to eq("www.bbb.com")
    expect(item.ra_namespace.first.short_name).to eq("BBB")
    expect(item.ra_namespace.first.name).to eq("BBB Pharma")
    expect(item.ra_namespace.first.authority).to eq("www.bbb.com")
  end

  it "allows for the children class to be read II, non array" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb6.find(uri)
    expect(item.ra_namespace_objects?).to eq(false)
    expect(item.ra_namespace_objects.count).to eq(1)
    expect(item.ra_namespace_objects?).to eq(true)
    expect(item.ra_namespace_objects.first.short_name).to eq("BBB")
    expect(item.ra_namespace_objects.first.name).to eq("BBB Pharma")
    expect(item.ra_namespace_objects.first.authority).to eq("www.bbb.com")
    expect(item.ra_namespace.short_name).to eq("BBB")
    expect(item.ra_namespace.name).to eq("BBB Pharma")
    expect(item.ra_namespace.authority).to eq("www.bbb.com")
  end

  it "find with children" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb6.find_children(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.short_name).to eq("BBB")
    expect(item.ra_namespace.name).to eq("BBB Pharma")
    expect(item.ra_namespace.authority).to eq("www.bbb.com")
  end
  
  it "find, simple and URI results, multiple instancess" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item_1 = TestFb5.find(uri)
    item_2 = TestFb5.find(uri)
    [item_1, item_2].each do |item|
      expect(item.uri.to_s).to eq(uri.to_s)
      expect(item.owner).to eq(true)
      expect(item.organization_identifier).to eq("123456789")
      expect(item.international_code_designator).to eq("DUNS")
      expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    end
  end

  it "allows for create" do
    item = TestFb5.create(uri: Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX"), owner: false, organization_identifier: "1234567891234", 
      international_code_designator: "DUNS_NEW")
    item_1 = TestFb5.find(item.uri)
    expect(item.uri).to eq(item_1.uri)
    expect(item.owner).to eq(item_1.owner)
    expect(item.organization_identifier).to eq(item_1.organization_identifier)
    expect(item.international_code_designator).to eq(item_1.international_code_designator)
  end

  it "allows for update" do
    item = TestFb5.create(uri: Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX"), owner: false, organization_identifier: "1234567891234", 
      international_code_designator: "DUNS_NEW")
    item_1 = TestFb5.find(item.uri)
    item_1.international_code_designator = "DUNS_OLD"
    item_1.update
    item_2 = TestFb5.find(item.uri)
    expect(item.uri).to eq(item_2.uri)
    expect(item.owner).to eq(item_2.owner)
    expect(item.organization_identifier).to eq(item_2.organization_identifier)
    expect(item.international_code_designator).to_not eq(item_2.international_code_designator)
    expect(item_2.international_code_designator).to eq("DUNS_OLD")
  end

  it "allows for where" do
    items = TestFb5.where({organization_identifier: "123456789"})
    expect(items.count).to eq(1)
    item = items.first
    expect(item.uri.to_s).to eq("http://www.assero.co.uk/RA#DUNS123456789")
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "ensures model class specified" do
    expect{class TestFb7 < Fuseki::Base
      configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
      object_property :ra_namespace, cardinality: :many
    end}.to raise_error(Errors::ApplicationLogicError, "No model class specified for object property.")
  end


end