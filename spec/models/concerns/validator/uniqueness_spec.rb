require 'rails_helper'

describe Validator::Uniqueness do
	
  include DataHelpers
  include FusekiBaseHelpers
  include ValidationHelpers

  before :each do
    load_files(schema_files, ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"])
  end

  it "validates a field" do
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "SSS1")
    expect(FusekiBaseHelpers::TestScopedIdentifier).to receive(:where).with({:identifier=>"SSS1"}).and_return([])
    x.valid?
    expect(x.errors.count).to eq(0)
  end

  it "validates a field, error" do
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "SSS2")
    expect(FusekiBaseHelpers::TestScopedIdentifier).to receive(:where).with({:identifier=>"SSS2"}).and_return(["something"])
    x.valid?
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("an existing record (identifier: SSS2) exisits in the database")
  end

end