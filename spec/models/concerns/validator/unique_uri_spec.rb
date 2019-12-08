require 'rails_helper'

describe Validator::UniqueUri do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
  end

  class TestVUU < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
  end

	it "validates a URI" do
    x = TestVUU.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/A#A")
    x.save
    x = TestVUU.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/A#A1")
    x.save
    expect(x.errors.count).to eq(0)
  end

  it "validates a uri, error" do
    x = TestVUU.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/A#A")
    result = x.save
    y = TestVUU.new
    y.uri = Uri.new(uri: "http://www.assero.co.uk/A#A")
    y.save
    expect(y.errors.count).to eq(1)
    expect(y.errors.full_messages.to_sentence).to eq("http://www.assero.co.uk/A#A already exists in the database")
  end

end