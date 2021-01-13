require 'rails_helper'

describe Role::Permission do
	
	include DataHelpers
  include SecureRandomHelpers
  include RolePermissionFactory
  include IsoConceptSystemNodeFactory

  def sub_dir
    return "models/role/permission"
  end

  before :each do
    data_files = []
    load_files(schema_files, data_files)
  end

  it "valid I" do
    klass = IsoConceptV2.rdf_type
    access = create_iso_concept_system_node(label: "XXX")
    object = Role::Permission.new(for_class: klass, with_access: access.uri, uri: Uri.new(uri: "http://www.example.com/A"))
    result = object.valid?
    expect(result).to eq(true)
  end

  it "valid II" do
    access = create_iso_concept_system_node(label: "XXX")
    object = Role::Permission.new(with_access: access.uri, uri: Uri.new(uri: "http://www.example.com/A"))
    result = object.valid?
    expect(result).to eq(false)
    expect(object.errors.full_messages.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("For class empty object")
  end

  it "valid III" do
    klass = IsoConceptV2.rdf_type
    object = Role::Permission.new(for_class: klass, uri: Uri.new(uri: "http://www.example.com/A"))
    result = object.valid?
    expect(result).to eq(false)
    expect(object.errors.full_messages.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("With access empty object")
  end

  it "valid IV" do
    klass = IsoConceptV2.rdf_type
    access = create_iso_concept_system_node(label: "XXX")
    object = Role::Permission.new(for_class: klass, with_access: access)
    result = object.valid?
    expect(result).to eq(false)
    expect(object.errors.full_messages.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Uri can't be blank")
  end

end