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
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO11179Types.ttl")
  end

  after :each do
  end

  class BaseTestFp
 
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods

    extend Fuseki::Schema
    extend Fuseki::Properties
    include Fuseki::Persistence
    include DataHelpers

    def initialize
      @@schema ||= self.class.get_schema(:initialize)
      @@props = read_yaml_file("models/concerns/fuseki/persistence", "properties.yaml") 
      self.class.instance_variable_set(:@properties, @@props)
    end

    def self.rdf_type
      self::C_URI
    end

  end 

  class TestFp1 < BaseTestFp

    C_URI = Uri.new(uri: "http://www.assero.co.uk/ISO11179Types#AdministeredItem")

    attr_accessor :has_state
    attr_accessor :has_identifier
    attr_accessor :origin

    def initialize
      @origin = ""
      @has_state = nil
      @has_identifier = nil
      @rdf_type = C_URI
      super
    end

  end

  it "error if RDF type not configured" do
    expect(TestFp1).to receive(:properties_read_class).and_return(read_yaml_file("models/concerns/fuseki/persistence", "properties.yaml") )
    triples = read_yaml_file(sub_dir, "from_results_recurse_input_1.yaml")
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    result = TestFp1.from_results_recurse(uri, triples)
    puts result.to_json
  end

end