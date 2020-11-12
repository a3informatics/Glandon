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
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("Identifier contains invalid characters")
    x.by_authority = IsoRegistrationAuthority.new
    x.identifier = "A"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(3)
    expect(x.errors.full_messages.to_sentence).to eq("By authority - uri - can't be blank, By authority - organization identifier - is invalid, and By authority - ra namespace - empty object")
    x.by_authority.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(2)
    expect(x.errors.full_messages.to_sentence).to eq("By authority - organization identifier - is invalid and By authority - ra namespace - empty object")
    x.by_authority.organization_identifier = "123456777"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("By authority - ra namespace - empty object")
    x.by_authority.ra_namespace = IsoNamespace.new
    x.by_authority.ra_namespace.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#NS-XXX")
    expect(x.valid?).to eq(true)
  end

  it "validates a klass, I" do
    x = FusekiBaseHelpers::ValidateOneAdministeredItem.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.has_state = nil
    x.has_identifier = nil
    x.change_description = "A"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(1)
    expect(x.errors.full_messages.to_sentence).to eq("Has identifier empty object")
  end

  it "validates a klass, II" do
    x = FusekiBaseHelpers::ValidateOneAdministeredItem.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.change_description = "A"
    x.has_identifier = nil
    x.has_state = IsoRegistrationStateV2.new
    x.has_state.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.has_state.registration_status = "WRONG"
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(3)
    expect(x.errors.full_messages.to_sentence).to eq("Has identifier empty object, Has state - registration status - is invalid, and Has state - by authority - empty object")
  end

  it "validates a klass, III" do
    x = FusekiBaseHelpers::ValidateOneAdministeredItem.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.change_description = "A"
    x.has_state = IsoRegistrationStateV2.new
    x.has_state.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.has_identifier = IsoScopedIdentifierV2.new
    x.has_identifier.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#YYY")
    expect(x.valid?).to eq(false)
    expect(x.errors.count).to eq(3)
    expect(x.errors.full_messages.to_sentence).to eq("Has identifier - identifier - contains invalid characters, Has identifier - semantic version - is empty, and Has state - by authority - empty object")
  end

  it "validates a klass, IV" do
    x = FusekiBaseHelpers::ValidateOneAdministeredItem.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.has_state = IsoRegistrationStateV2.new
    x.has_state.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.has_state.by_authority = IsoRegistrationAuthority.new
    x.has_state.by_authority.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#ZZZ")
    x.has_identifier = IsoScopedIdentifierV2.new
    x.has_identifier.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#YYY")
    x.has_identifier.identifier = "XXXXXX"
    x.has_identifier.semantic_version = "1.2.3"
    expect(x.valid?).to eq(true)
  end


end