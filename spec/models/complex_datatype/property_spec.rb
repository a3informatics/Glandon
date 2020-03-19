require 'rails_helper'
require 'complex_datatype/property'

describe ComplexDatatype::Property do
	
	include DataHelpers

  def sub_dir
    return "models/complex_datatype/property"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "valid property" do
		item = ComplexDatatype::Property.new(label: "boolean", simple_datatype: "http://www.aurl.com")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid property, errors I" do
    item = ComplexDatatype::Property.new(label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Simple datatype can't be blank")
  end

  it "valid property, errors II" do
    item = ComplexDatatype::Property.new(simple_datatype: "xxx")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

  it "create property" do
    item = ComplexDatatype::Property.create(label: "PQ", simple_datatype: "string")
    expect(item.errors.count).to eq(0)
    expect(item.uri.to_s).to eq("http://www.assero.co.uk/CDTP#PQ")
  end

end