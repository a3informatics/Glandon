require 'rails_helper'

describe Form::Item::Mapping do
  
  include DataHelpers

  def sub_dir
    return "models/form/item/mapping"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when XXTESTCD=HELLO"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when ±±TESTCD=HELLO"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Mapping contains invalid characters")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, ordinal" do
    item = Form::Item::Mapping.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.mapping = "EGMONKEY when TESTCD=HELLO"
    item.ordinal = 0
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "returns the item array" do
    item = Form::Item::Mapping.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), mapping: "MY MAP", ordinal: 1)
    result = item.get_item
    check_file_actual_expected(result, sub_dir, "get_item_expected_1.yaml", equate_method: :hash_equal)
  end

  it "returns the CRF rendition" do
    item = Form::Item::Mapping.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), mapping: "AAAAA", ordinal: 1)
    result = item.to_crf(nil)
    check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
  end

  it "returns the aCRF rendition" do
    item = Form::Item::Mapping.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), mapping: "AAAAA", ordinal: 1)
    annotations = {}
    result = item.to_crf(annotations)
    check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
  end

end
  