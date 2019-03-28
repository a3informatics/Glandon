require 'rails_helper'

describe Validator::Klass do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
  end

  class TestVK < Fuseki::Base
    configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier"
    object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority"
    validates_with Validator::Klass, property: :by_authority
  end

	it "validates a klass" do
    x = TestVK.new
    x.uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#XXX")
    x.by_authority = IsoRegistrationAuthority.new
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