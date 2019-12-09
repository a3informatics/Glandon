require 'rails_helper'

describe Validator::Uniqueness do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
  end

  class TestVU < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    data_property :identifier
    validates_with Validator::Uniqueness, attribute: :identifier
  end

	it "validates a field" do
    x = TestVU.new
    x.uri = "something"
    x.identifier = "SSS1"
    expect(TestVU).to receive(:where).with({:identifier=>"SSS1"}).and_return([])
    x.valid?
    expect(x.errors.count).to eq(0)
  end

  it "validates a field, error" do
    x = TestVU.new
    x.uri = "something"
    x.identifier = "SSS2"
    expect(TestVU).to receive(:where).with({:identifier=>"SSS2"}).and_return(["something"])
    x.valid?
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("an existing record (identifier: SSS2) exisits in the database")
  end

end