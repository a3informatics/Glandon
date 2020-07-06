require 'rails_helper'

describe ComplexDatatype::PropertyX do
	
	include DataHelpers

  def sub_dir
    return "models/complex_datatype/property"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "valid property" do
		item = ComplexDatatype::PropertyX.new(label: "boolean", simple_datatype: "http://www.aurl.com")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid property, errors I" do
    item = ComplexDatatype::PropertyX.new(label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Simple datatype can't be blank")
  end

  it "valid property, errors II" do
    item = ComplexDatatype::PropertyX.new(simple_datatype: "xxx")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

  it "create property" do
    item = ComplexDatatype::PropertyX.create(label: "PQ", simple_datatype: "string")
    expect(item.errors.count).to eq(0)
    expect(item.uri.to_s).to eq("http://www.s-cubed.dk/CDTP#PQ")
  end

end