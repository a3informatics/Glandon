require 'rails_helper'

describe Fuseki::Base do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/base"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179IdentificationSimplified.ttl")
    load_schema_file_into_triple_store("ISO11179RegistrationSimplified.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
  end

  after :all do
    delete_all_public_test_files
  end

  class Test1 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace"
    data_property :short_name
    data_property :name
  end

  class Test2 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#Namespace"
    data_property :short_name
    data_property :name
    data_property :authority
  end

  class Test3 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    object_property :ra_namespace, cardinality: :many
  end

  class Test4 < Test3
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    data_property :organization_identifier
    data_property :international_code_designator
  end

  class Test5 < Test4
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    data_property :owner
  end

  it "allows for the class to be created, uri" do
    item = Test1.new
    item.short_name = "AAA"
    expect(item.short_name).to eq("AAA")
  end

  it "allows for the class to be read, simple results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = Test2.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.id).to eq(Base64.strict_encode64(uri.to_s))
    expect(item.short_name).to eq("AAA")
    expect(item.name).to eq("AAA Long")
    expect(item.authority).to eq("www.aaa.com")
  end

  it "allows for the class to be read, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = Test3.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "allows for the class to be read, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = Test3.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "allows for the class to be read, simple and URI results, inheritence I" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = Test4.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
  end

  it "allows for the class to be read, simple and URI results, inheritence II" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = Test5.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "allows for the class to be read, simple and URI results, multiple instancess" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item_1 = Test5.find(uri)
    item_2 = Test5.find(uri)
    [item_1, item_2].each do |item|
      expect(item.uri.to_s).to eq(uri.to_s)
      expect(item.owner).to eq(true)
      expect(item.organization_identifier).to eq("123456789")
      expect(item.international_code_designator).to eq("DUNS")
      expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    end
  end

  it "allows for the class to be read, simple and URI results, multiple instancess" do
    item = Test5.new
byebug
    item.uri = Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX")
    item.owner = false
    item.ra_namespace << Uri.new(uri: "http://www.assero.co.uk/MDRItems#NS-BBB")
    item.has_authority_identifier = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RAI-123456789")
    item.create
  end

end