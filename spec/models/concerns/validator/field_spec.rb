require 'rails_helper'

describe Validator::Field do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
  end

  class TestVF < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    data_property :identifier
    validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
  end

	it "validates a field" do
    x = TestVF.new
    x.identifier = "SSS"
    expect(FieldValidation).to receive(:valid_identifier?).with(:identifier, "SSS", an_instance_of(TestVF))
    x.valid?
  end

end