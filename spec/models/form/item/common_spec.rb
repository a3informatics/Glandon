require 'rails_helper'

describe Form::Item::Common do
  
  include DataHelpers

  def sub_dir
    return "models/form/item/common"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item::Common.new
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.has_common_item).to eq([])
    expect(result.valid?).to eq(true)
  end

  # it "does not validate an invalid object, ordinal" do
  #   item = Form::Item::Common.new
  #   result = item.valid?
  #   expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
  #   expect(item.errors.count).to eq(1)
  #   expect(result).to eq(false)
  # end

end
  