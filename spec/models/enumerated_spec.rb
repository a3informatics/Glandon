require 'rails_helper'

describe Enumerated do
	
	include DataHelpers

  def sub_dir
    return "models/enumerated"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "valid" do
		item = Enumerated.new(label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid, errors I" do
    item = Enumerated.new()
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

  it "create" do
    item = Enumerated.create(label: "Physical Quantity", parent_uri: Enumerated.base_uri)
    expect(item.errors.count).to eq(0)
    expect(item.uri.to_s).to eq("http://www.assero.co.uk/ENUM#c9184d2afc6cb34c25e79edc60ba1d5f3521842e")
    expect(item.label).to eq("Physical Quantity")
  end

end