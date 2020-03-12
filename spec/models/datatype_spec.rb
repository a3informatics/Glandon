require 'rails_helper'

describe Datatype do
	
	include DataHelpers

  def sub_dir
    return "models/datatype"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "create datatype" do
		item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#boolean", short_label: "B", odm: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "create datatype, errors I" do
    item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#boolean", odm: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Short label can't be blank")
  end

  it "create datatype, errors II" do
    item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#boolean", short_label: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Odm can't be blank")
  end

  it "to literal" do
    item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#boolean", short_label: "B", odm: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    expect(item.to_literal(true)).to eq("true")
  end

  it "to literal, error" do
    item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#booleanX", short_label: "B", odm: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    expect{item.to_literal(true)}.to raise_error(Errors::ApplicationLogicError, "Unable to access configuration for type http://www.w3.org/2001/XMLSchema#booleanX.")
  end

  it "to typed" do
    item = Datatype.new(xsd: "http://www.w3.org/2001/XMLSchema#boolean", short_label: "B", odm: "boolean")
    item.uri = item.create_uri(item.class.base_uri)
    expect(item.to_typed("false")).to eq(false)
  end

end