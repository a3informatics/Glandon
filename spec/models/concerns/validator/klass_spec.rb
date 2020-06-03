require 'rails_helper'

describe Validator::Klass do
	
  include DataHelpers
  include FusekiBaseHelpers
  include ValidationHelpers

  before :each do
    load_files(schema_files, ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"])
  end

	it "validates a klass" do
    x = FusekiBaseHelpers::TestScopedIdentifier.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.by_authority = IsoRegistrationAuthority.new
    x.identifier = "A"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(3)
    expect(x.errors.full_messages.to_sentence).to eq("By authority: Uri can't be blank, By authority: Organization identifier is invalid, and By authority: Ra namespace: Empty object")
    x.by_authority.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(2)
    x.by_authority.organization_identifier = "123456777"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(1)
    x.by_authority.ra_namespace = IsoNamespace.find_by_short_name("BBB")
    expect(x.valid?).to eq(true)
  end

end