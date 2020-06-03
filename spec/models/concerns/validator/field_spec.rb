require 'rails_helper'

describe Validator::Field do
	
  include DataHelpers
  include FusekiBaseHelpers
  include ValidationHelpers

  before :each do
    load_files(schema_files, ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"])
  end

	it "validates a field" do
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "SSS")
    expect(FieldValidation).to receive(:valid_identifier?).with(:identifier, "SSS", an_instance_of(FusekiBaseHelpers::TestScopedIdentifier))
    x.valid?
  end

end