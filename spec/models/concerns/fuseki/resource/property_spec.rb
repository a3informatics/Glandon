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

  class TestFRP

    def uri
      @uri
    end

  end

  it "allows for simple update" do
    ref_0 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_0, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :property, default: "1", base_type: XSDDatatype.new("string")})
    expect(item.name).to eq(:fred)
    expect(item.instance_name).to eq(:@fred)
    expect(item.klass).to eq(TestFRP)
    expect(item.cardinality).to eq(:one)
    expect(item.predicate).to eq("XXX")
    expect(item.object?).to eq(false)
    expect(item.array?).to eq(false)
    expect(item.default_value).to eq("1")
    item.set_value("XXX")
    expect(item.get).to eq("XXX")
    item.clear
    expect(item.get).to eq("")
    
    ref_1 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_1, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: nil})
    expect(item.name).to eq(:fred)
    expect(item.instance_name).to eq(:@fred)
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
    uri = Uri.new(uri: "http://wwww.a.com/pathsec#2")
    item.set_raw(uri)
    expect(item.get).to eq(uri)
    expect(item.uri?).to eq(true)
    
    ref_2 = TestFRP.new
    ref_2.instance_variable_set(:@fred, [])
    item = Fuseki::Resource::Property.new(ref_2, :fred, {model_class: TestFRP, cardinality: :multiple, predicate: "XXX", type: :object, default: [], base_type: nil})
    uri_1 = Uri.new(uri: "http://wwww.a.com/path#1")
    uri_2 = Uri.new(uri: "http://wwww.a.com/path#2")
    uri_3 = Uri.new(uri: "http://wwww.a.com/path#3")
    item.set_value(uri_1)
    expect(item.get).to eq([uri_1])
    item.set_value(uri_2)
    expect(item.get).to eq([uri_1, uri_2])
    expect(item.uri?).to eq(true)
    item.set_raw([])
    expect(item.get).to eq([])
    item.set_raw([uri_1, uri_2])
    expect(item.get).to eq([uri_1, uri_2])
    ref_2a = TestFRP.new
    ref_2a.instance_variable_set(:@uri, uri_2)
    ref_2a.instance_variable_set(:@sid, "XXXXX")
    item.replace_with_object(ref_2a)
    expect(item.get).to eq([uri_1, ref_2a])
    ref_2b = TestFRP.new
    ref_2b.instance_variable_set(:@uri, uri_3)
    ref_2b.instance_variable_set(:@sid, "YYY")
    item.replace_with_object(ref_2b)
    expect(item.get).to eq([uri_1, ref_2a, ref_2b])

    ref_3 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_3, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: nil, base_type: nil})
    item.set_uri(uri)
    expect(item.get).to eq(uri)

    item.set_uri(uri.to_s)
    expect(item.get).to eq(uri)

    ref_4 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_4, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: "", base_type: XSDDatatype.new("dateTime")})
    time = "1980-03-04"
    item.set_simple(time)
    expect(item.get.iso8601).to eq("1980-03-04T00:00:00+00:00")

    ref_5 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_5, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: "", base_type: XSDDatatype.new("string")})
    item.set_simple("XXX")
    expect(item.get).to eq("XXX")

    ref_6 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_6, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: true, base_type: XSDDatatype.new("boolean")})
    item.set_simple(true)
    expect(item.get).to eq(true)

    ref_7 = TestFRP.new
    item = Fuseki::Resource::Property.new(ref_7, :fred, {model_class: TestFRP, cardinality: :one, predicate: "XXX", type: :object, default: 0, base_type: XSDDatatype.new("integer")})
    item.set_simple(1)
    expect(item.get).to eq(1)
    
  end

  it "schema predicate name" do
    expect(Fuseki::Resource::Property.schema_predicate_name("this_is_a")).to eq("thisIsA")
  end

  it "saved and to be saved" do
    ref = IsoNamespace.new

    sparql = Sparql::Update.new
    item = ref.properties.property(:name)
    item.set_simple("value")
    expect(item.get).to eq("value")
    expect(item.to_be_saved?).to eq(true)
    item.to_triples(sparql, Uri.new(uri: "http://www.example.com/c#parent"))
    expect(sparql.to_triples).to eq("<http://www.example.com/c#parent> isoI:name \"value\"^^xsd:string . \n")
    item.saved
    expect(item.to_be_saved?).to eq(false)
    
    sparql = Sparql::Update.new
    ref.name = "updated name"
    expect(ref.properties.property(:name).to_be_saved?).to eq(true)
    ref.properties.property(:name).to_triples(sparql, Uri.new(uri: "http://www.example.com/c#parent"))
    expect(sparql.to_triples).to eq("<http://www.example.com/c#parent> isoI:name \"updated name\"^^xsd:string . \n")
  end

end