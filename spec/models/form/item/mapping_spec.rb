require 'rails_helper'

describe Form::Item::Mapping do
  
  include DataHelpers

  def sub_dir
    return "models/form/item/mapping"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Item::Mapping.new
    item.mapping = "EGMONKEY when XXTESTCD=HELLO"
    item.ordinal = 1
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    item = Form::Item::Mapping.new
    item.mapping = "EGMONKEY when ±±TESTCD=HELLO"
    item.ordinal = 1
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Mapping contains invalid characters")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

end
  