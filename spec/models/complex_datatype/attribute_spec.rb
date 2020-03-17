require 'rails_helper'

describe ComplexDatatype::Attribute do
	
	include DataHelpers

  def sub_dir
    return "models/complex_datatype/attribute"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "create attribute" do
		item = ComplexDatatype::Attribute.new(label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "create attribute, errors I" do
    item = ComplexDatatype::Attribute.new()
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

end