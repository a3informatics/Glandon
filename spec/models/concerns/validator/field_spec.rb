require 'rails_helper'

describe Validator::Field do
	
  include DataHelpers

  before :each do
    clear_triple_store
  end

  class Test < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    data_property :identifier
    validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
  end

	it "validates a field" do
    x = Test.new
    x.identifier = "SSS"
    expect(FieldValidation).to receive(:valid_identifier?).with(:identifier, "SSS", an_instance_of(Test))
    x.valid?
  end

end