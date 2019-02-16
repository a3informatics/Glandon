require 'rails_helper'

describe Fuseki::Base do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/base"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
  end

  after :all do
    delete_all_public_test_files
  end

  class Test1 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Basic#Organization"
    data_property :short_name
    data_property :name
  end

  class Test2 < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Registration#RegistrationAuthority"
    object_property :ra_namespace
    object_property :has_authority_identifier
    data_property :owner

    def initialize
      @ra_namespace = []
      @has_authority_identifier = []
      super
    end

  end

  it "allows for the class to be created, uri" do
    item = Test1.new
    item.short_name = "AAA"
    expect(item.short_name).to eq("AAA")
  end

  it "allows for the class to be read, simple results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#O-AAA")
    item = Test1.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.id).to eq(Base64.strict_encode64(uri.to_s))
    expect(item.short_name).to eq("AAA")
    expect(item.name).to eq("AAA Long")
  end

  it "allows for the class to be read, simple and URI results" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RA-123456789")
    item = Test2.find(uri)
    expect(item.uri.to_s).to eq(uri.to_s)
    expect(item.owner).to eq(true)
    expect(item.ra_namespace.first.to_s).to eq("http://www.assero.co.uk/MDRItems#NS-BBB")
    expect(item.has_authority_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#RAI-123456789")
  end

end