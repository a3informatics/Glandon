require 'rails_helper'

describe Fuseki::Base do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/base"
  end

  before :all do
    data_files = ["iso_namespace_test.ttl", "iso_registration_authority_test.ttl"]
    load_files(schema_files, data_files)
  end

  after :all do
    delete_all_public_test_files
  end

  class TestFb1 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/Test#Namespace"
    data_property :short_name
    data_property :name
    data_property :authority
  end

  class TestFb2 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority"
    object_property :ra_namespace, cardinality: :many, model_class: "TestFb1"
    data_property :organization_identifier
    data_property :international_code_designator
    data_property :owner

    def register(instance)
    end
    
  end

  class TestFb3 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority2"
    object_property :ra_namespace2, cardinality: :one, model_class: "TestFb1"
    data_property :organization_identifier2
    data_property :international_code_designator2
    data_property :owner2

    def register(instance)
    end
    
  end

  class TestFb4 < TestFb2
  end

  it "allows for the class to be created, uri" do
    item = TestFb1.new
    item.short_name = "AAA"
    expect(item.short_name).to eq("AAA")
  end

  it "find, simple results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    item = TestFb1.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.id).to eq(Base64.strict_encode64(uri.to_s))
    expect(item.short_name).to eq("AAA")
    expect(item.name).to eq("AAA Long")
    expect(item.authority).to eq("www.aaa.com")
  end

  it "find, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb2.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "find, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb2.find(uri)
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
    item = TestFb4.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
  end

  it "allows for the children class to be read I, array" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item = TestFb2.find(uri)
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
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS22222222")
    item = TestFb3.find(uri)
    expect(item.ra_namespace2_objects?).to eq(false)
    expect(item.ra_namespace2_objects.nil?).to eq(false)
    expect(item.ra_namespace2_objects?).to eq(true)
    expect(item.ra_namespace2_objects.short_name).to eq("CCC")
    expect(item.ra_namespace2_objects.name).to eq("CCC Pharma")
    expect(item.ra_namespace2_objects.authority).to eq("www.ccc.com")
    expect(item.ra_namespace2.short_name).to eq("CCC")
    expect(item.ra_namespace2.name).to eq("CCC Pharma")
    expect(item.ra_namespace2.authority).to eq("www.ccc.com")
  end

  it "find with children" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS22222222")
    item = TestFb3.find_children(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.organization_identifier2).to eq("22222222")
    expect(item.international_code_designator2).to eq("DUNS")
    expect(item.owner2).to eq(false)
    expect(item.ra_namespace2.short_name).to eq("CCC")
    expect(item.ra_namespace2.name).to eq("CCC Pharma")
    expect(item.ra_namespace2.authority).to eq("www.ccc.com")
  end
  
  it "find, simple and URI results, multiple instancess" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    item_1 = TestFb2.find(uri)
    item_2 = TestFb2.find(uri)
    [item_1, item_2].each do |item|
      expect(item.uri.to_s).to eq(uri.to_s)
      expect(item.owner).to eq(true)
      expect(item.organization_identifier).to eq("123456789")
      expect(item.international_code_designator).to eq("DUNS")
      expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
    end
  end

  it "allows for create" do
    item = TestFb2.create(uri: Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX"), owner: false, organization_identifier: "1234567891234", 
      international_code_designator: "DUNS_NEW")
    item_1 = TestFb2.find(item.uri)
    expect(item.uri).to eq(item_1.uri)
    expect(item.owner).to eq(item_1.owner)
    expect(item.organization_identifier).to eq(item_1.organization_identifier)
    expect(item.international_code_designator).to eq(item_1.international_code_designator)
  end

  it "allows for update, no params" do
    item = TestFb2.create(uri: Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX"), owner: false, organization_identifier: "1234567891234", 
      international_code_designator: "DUNS_NEW")
    item_1 = TestFb2.find(item.uri)
    item_1.international_code_designator = "DUNS_OLD"
    item_1.update
    item_2 = TestFb2.find(item.uri)
    expect(item.uri).to eq(item_2.uri)
    expect(item.owner).to eq(item_2.owner)
    expect(item.organization_identifier).to eq(item_2.organization_identifier)
    expect(item.international_code_designator).to_not eq(item_2.international_code_designator)
    expect(item_2.international_code_designator).to eq("DUNS_OLD")
  end

  it "allows for update, with params" do
    item = TestFb2.create(uri: Uri.new(uri: "http://www.assero.co.uk/RA#XXXXXXXX"), owner: false, organization_identifier: "1234567891234", 
      international_code_designator: "DUNS_NEW")
    item_1 = TestFb2.find(item.uri)
    item_1.international_code_designator = "DUNS_OLD"
    item_1.update(owner: true)
    item_2 = TestFb2.find(item.uri)
    expect(item.uri).to eq(item_2.uri)
    expect(item.organization_identifier).to eq(item_2.organization_identifier)
    expect(item.international_code_designator).to_not eq(item_2.international_code_designator)
    expect(item_2.international_code_designator).to eq("DUNS_OLD")
    expect(item_2.owner).to eq(true)
  end

  it "allows for where" do
    items = TestFb2.where({organization_identifier: "123456789"})
    expect(items.count).to eq(1)
    item = items.first
    expect(item.uri.to_s).to eq("http://www.assero.co.uk/RA#DUNS123456789")
    expect(item.organization_identifier).to eq("123456789")
    expect(item.international_code_designator).to eq("DUNS")
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/NS#BBB")
  end

  it "sets properties" do
    item = TestFb1.new(name: "A Name", short_name: "XXXXX")
    expect(item.name).to eq("A Name")
    expect(item.short_name).to eq("XXXXX")
    status = item.test_inspect
    expect(status[:transaction]).to eq(nil)
    expect(status[:destroyed]).to eq(false)
    expect(status[:new_record]).to eq(true)
  end

  it "sets properties including transaction" do
    uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
    transaction = TestFb2.find(uri) # Can be any class instance
    item = TestFb1.new(name: "A Name", short_name: "XXXXX", transaction: transaction)
    expect(item.name).to eq("A Name")
    expect(item.short_name).to eq("XXXXX")
    status = item.test_inspect
    expect(status[:transaction].uri).to eq(transaction.uri)
    expect(status[:destroyed]).to eq(false)
    expect(status[:new_record]).to eq(true)
  end

  it "ensures model class specified" do
    expect{class TestFb7 < Fuseki::Base
      configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority"
      object_property :ra_namespace, cardinality: :many
    end}.to raise_error(Errors::ApplicationLogicError, "No model class specified for object property.")
  end

end