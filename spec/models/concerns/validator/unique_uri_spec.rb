require 'rails_helper'

describe Validator::UniqueUri do
	
  include DataHelpers
  include FusekiBaseHelpers
  include ValidationHelpers

  before :each do
    load_files(schema_files, ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"])
  end

  it "validates a URI" do
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "A")
    expect(x.errors.count).to eq(0)
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A1"), "A1")
    expect(x.errors.count).to eq(0)
  end

  it "validates a uri, error" do
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "A")
    expect(x.errors.count).to eq(0)
    x = si(Uri.new(uri: "http://www.assero.co.uk/A#A"), "A1")
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("http://www.assero.co.uk/A#A already exists in the database")
  end

end