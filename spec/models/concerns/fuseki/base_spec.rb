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

  it "allows for create" do
    item = Test5.new
    item.uri = Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX")
    item.owner = false
    item.organization_identifier = "1234567891234"
    item.international_code_designator = "DUNS_NEW"
    item.create
    item_1 = Test5.find(item.uri)
    expect(item.uri).to eq(item_1.uri)
    expect(item.owner).to eq(item_1.owner)
    expect(item.organization_identifier).to eq(item_1.organization_identifier)
    expect(item.international_code_designator).to eq(item_1.international_code_designator)
  end

  it "allows for update" do
    item = Test5.new
    item.uri = Uri.new(uri: "http://www.assero.co.uk/RA#1111")
    item.owner = false
    item.organization_identifier = "1234567891234"
    item.international_code_designator = "DUNS_NEW"
    item.create
    item_1 = Test5.find(item.uri)
    item_1.international_code_designator = "DUNS_OLD"
    item_1.update
    item_2 = Test5.find(item.uri)
    expect(item.uri).to eq(item_2.uri)
    expect(item.owner).to eq(item_2.owner)
    expect(item.organization_identifier).to eq(item_2.organization_identifier)
    expect(item.international_code_designator).to_not eq(item_2.international_code_designator)
    expect(item_2.international_code_designator).to eq("DUNS_OLD")
  end

=begin
  it "allows for where" do
    item = Test5.where({organization_identifier: "123456789"})
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end
=end

end