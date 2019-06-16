require 'rails_helper'

describe Fuseki::Utility do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/diff"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
    load_files(schema_files, data_files)
  end

  class BaseTestD
 
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods

    include Fuseki::Persistence
    include Fuseki::Persistence::Property
    include Fuseki::Utility
    include Fuseki::Diff
    extend Fuseki::Schema

    attr_accessor :uri

    def initialize(props)
      @new_record = true
      @destroyed = false
      self.class.get_schema(:initialize)
      self.class.class_variable_set(:@@schema, Fuseki::Base.class_variable_get(:@@schema))
      self.class.instance_variable_set(:@properties, props)
    end

    def self.rdf_type
      self::C_URI
    end

    def rdf_type
      self.class::C_URI
    end

  end 

  class TestToH

    def to_h
      return {test_1: "XXX", test_2: 1}
    end

    def self.from_h(values)
      object = self.new
      object.instance_variable_set(:@test_1, values[:test_1])
      object.instance_variable_set(:@test_2, values[:test_2])
      object
    end

  end

  class TestD1 < BaseTestD

    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority")

    attr_accessor :owner
    attr_accessor :organization_identifier

    def initialize
      props = 
      {
        "@owner".to_sym => {type: :data, predicate: "http://www.assero.co.uk/ISO11179Registration#owner"},
        "@organization_identifier".to_sym => {type: :data, predicate: "http://www.assero.co.uk/ISO11179Registration#organizationIdentifier"},
      }
      @owner = false
      @organization_identifier = ""
      @rdf_type = C_URI
      super(props)
    end

  end

  class TestD2 < BaseTestD
    
    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#RegistrationState")

    attr_accessor :effective_date
    attr_accessor :ra_namespace

    def initialize
      props = 
      {
        "@ra_namespace".to_sym => {type: :object, predicate: "http://www.assero.co.uk/ISO11179Registration#raNamespace"}, 
        "@effective_date".to_sym => {type: :data, predicate: "http://www.assero.co.uk/ISO11179Registration#effectiveDate"}
      }
      self.class.instance_variable_set(:@properties, props)
      @effective_date = "".to_time_with_default
      @ra_namespace = []
      @rdf_type = C_URI
      super(props)
    end

  end 

  class TestD3 < BaseTestD
    
    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Identification#Namespace")

    attr_accessor :short_name
    attr_accessor :name

    def initialize
      props = 
      {
        "@short_name".to_sym => {type: :object, predicate: "http://www.assero.co.uk/ISO11179Identification#shortName"}, 
        "@name".to_sym => {type: :data, predicate: "http://www.assero.co.uk/ISO11179Identification#name"}
      }
      self.class.instance_variable_set(:@properties, props)
      @name = ""
      @short_name = ""
      @rdf_type = C_URI
      super(props)
    end

    def self.key_property
      return :short_name
    end

  end 

  it "diff, simple I, same" do
    uri_a = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectA")
    a = TestD1.new
    a.uri =  uri_a
    a.owner = "12345"
    a.organization_identifier = "Hello World"
    uri_b = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectB")
    b = TestD1.new
    b.uri =  uri_b
    b.owner = "12345"
    b.organization_identifier = "Hello World"
    expect(a.diff?(b)).to eq(false)
    actual = a.difference(b)
  #Xwrite_yaml_file(actual, sub_dir, "difference_1.yaml")
    expected = read_yaml_file(sub_dir, "difference_1.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, simple II, different" do
    uri_a = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectA")
    a = TestD1.new
    a.uri =  uri_a
    a.owner = "12345"
    a.organization_identifier = "Hello World"
    uri_b = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectB")
    b = TestD1.new
    b.uri =  uri_b
    b.owner = "12346"
    b.organization_identifier = "Hello World"
    expect(a.diff?(b)).to eq(true)
    actual = a.difference(b)
  #Xwrite_yaml_file(actual, sub_dir, "difference_2.yaml")
    expected = read_yaml_file(sub_dir, "difference_2.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, simple III, persisted same" do
    uri_a = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectA")
    a = TestD1.new
    a.uri =  uri_a
    a.owner = "12345"
    a.organization_identifier = "Hello World"
    a.set_persisted
    expect(a.diff?(a)).to eq(false)
    actual = a.difference(a)
  #Xwrite_yaml_file(actual, sub_dir, "difference_3.yaml")
    expected = read_yaml_file(sub_dir, "difference_3.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, simple IV, persisted different" do
    uri_a = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectA")
    a = TestD1.new
    a.uri =  uri_a
    a.owner = "12345"
    a.organization_identifier = "Hello World"
    a.set_persisted
    uri_b = Uri.new(uri: "http://www.assero.co.uk/Fragment#SubjectB")
    b = TestD1.new
    b.uri =  uri_b
    b.owner = "12346"
    b.organization_identifier = "Hello World"
    b.set_persisted
    expect(a.diff?(b)).to eq(true)
    actual = a.difference(b)
  #Xwrite_yaml_file(actual, sub_dir, "difference_4.yaml")
    expected = read_yaml_file(sub_dir, "difference_4.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, children I, same" do
    uri = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    item = TestD2.new
    item.uri = uri_s
    item.ra_namespace << uri
    item.ra_namespace << uri
    expect(item.diff?(item)).to eq(false)
    actual = item.difference(item)
  #Xwrite_yaml_file(actual, sub_dir, "difference_5.yaml")
    expected = read_yaml_file(sub_dir, "difference_5.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, children II, different" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test1")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test2")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    item_1 = TestD2.new
    item_1.uri = uri_s
    item_1.ra_namespace << uri_1
    item_1.ra_namespace << uri_2
    item_2 = TestD2.new
    item_2.uri = uri_s
    item_2.ra_namespace << uri_1
    item_2.ra_namespace << uri_1
    expect(item_1.diff?(item_2)).to eq(true)
    actual = item_1.difference(item_2)
  #Xwrite_yaml_file(actual, sub_dir, "difference_6.yaml")
    expected = read_yaml_file(sub_dir, "difference_6.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, children III, different" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test1")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test2")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    item_1 = TestD2.new
    item_1.uri = uri_s
    item_1.ra_namespace << uri_1
    item_1.ra_namespace << uri_2
    item_2 = TestD2.new
    item_2.uri = uri_s
    item_2.ra_namespace << uri_1
    item_2.ra_namespace << uri_1
    expect(item_1.diff?(item_2)).to eq(true)
    actual = item_1.difference(item_2)
  #Xwrite_yaml_file(actual, sub_dir, "difference_7.yaml")
    expected = read_yaml_file(sub_dir, "difference_7.yaml")
    expect(actual).to eq(expected)
end

  it "diff, children IV, different" do
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    child_1 = TestD3.new
    child_1.name = "The A"
    child_1.short_name = "A"
    child_2 = TestD3.new
    child_2.name = "The B"
    child_2.short_name = "B"
    item_1 = TestD2.new
    item_1.uri = uri_s
    item_1.ra_namespace << child_1
    item_1.ra_namespace << child_2
    item_2 = TestD2.new
    item_2.uri = uri_s
    item_2.ra_namespace << child_1
    item_2.ra_namespace << child_2
    expect(item_1.diff?(item_2)).to eq(false)
    actual = item_1.difference(item_2)
  #Xwrite_yaml_file(actual, sub_dir, "difference_8.yaml")
    expected = read_yaml_file(sub_dir, "difference_8.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, children V, different" do
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    child_1 = TestD3.new
    child_1.name = "The A"
    child_1.short_name = "A"
    child_2 = TestD3.new
    child_2.name = "The B"
    child_2.short_name = "B"
    child_3 = TestD3.new
    child_3.name = "The Bx"
    child_3.short_name = "B"
    item_1 = TestD2.new
    item_1.uri = uri_s
    item_1.ra_namespace << child_1
    item_1.ra_namespace << child_2
    item_2 = TestD2.new
    item_2.uri = uri_s
    item_2.ra_namespace << child_1
    item_2.ra_namespace << child_3
    expect(item_1.diff?(item_2)).to eq(true)
    actual = item_1.difference(item_2)
  #Xwrite_yaml_file(actual, sub_dir, "difference_9.yaml")
    expected = read_yaml_file(sub_dir, "difference_9.yaml")
    expect(actual).to eq(expected)
  end

  it "diff, children I, ignore and same" do
    uri_1 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test1")
    uri_2 = Uri.new(uri: "http://www.assero.co.uk/Fragment#Test2")
    uri_s = Uri.new(uri: "http://www.assero.co.uk/Fragment#Subject")
    item_1 = TestD2.new
    item_1.uri = uri_s
    item_1.ra_namespace << uri_1
    item_1.ra_namespace << uri_2
    item_2 = TestD2.new
    item_2.uri = uri_s
    item_2.ra_namespace << uri_1
    item_2.ra_namespace << uri_1
    expect(item_1.diff?(item_2, {ignore: [:ra_namespace]})).to eq(false)
    actual = item_1.difference(item_2, {ignore: [:ra_namespace]})
    check_file_actual_expected(actual, sub_dir, "difference_10.yaml")
    expect(item_1.diff?(item_2)).to eq(true)
    actual = item_1.difference(item_2)
    check_file_actual_expected(actual, sub_dir, "difference_11.yaml")
  end


end