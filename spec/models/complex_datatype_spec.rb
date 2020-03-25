require 'rails_helper'

describe ComplexDatatype do
	
	include DataHelpers

  def sub_dir
    return "models/complex_datatype"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "valid complex datatype" do
		item = ComplexDatatype.new(label: "boolean", short_name: "PQ")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid complex datatype, errors I" do
    item = ComplexDatatype.new(label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Short name can't be blank")
  end

  it "valid complex datatype, errors II" do
    item = ComplexDatatype.new(short_name: "xxx")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

  it "create complex datatype" do
    item = ComplexDatatype.create(label: "Physical Quantity", short_name: "PQ")
    expect(item.errors.count).to eq(0)
    expect(item.uri.to_s).to eq("http://www.assero.co.uk/CDT#PQ")
    expect(item.label).to eq("Physical Quantity")
  end

end