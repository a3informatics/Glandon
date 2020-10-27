require 'rails_helper'

describe Form::Item::Placeholder do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/item/placeholder"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Item::Placeholder.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.free_text = "Draft 123"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    item = Form::Item::Placeholder.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.free_text = "Draft 123±"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Free text contains invalid markdown")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, ordinal" do
    item = Form::Item::Placeholder.new
    item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    item.free_text = "Draft 123"
    item.ordinal = 0
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "returns the item array" do
    item = Form::Item::Placeholder.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), free_text: "Draft 123", ordinal: 1)
    result = item.get_item
    check_file_actual_expected(result, sub_dir, "get_item_expected_1.yaml", equate_method: :hash_equal)
  end

  it "returns the CRF rendition" do
    item = Form::Item::Placeholder.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), free_text: "Draft 123", ordinal: 1)
    result = item.to_crf
    check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
  end

# it "allows an object to be exported as XML" do
#     odm = add_root
#     study = add_study(odm.root)
#     mdv = add_mdv(study)
#     form = add_form(mdv)
#     form.add_item_group_ref("G-TEST", "1", "No", "")
#     item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
#     item = Form::Item::Placeholder.new
#     item.id = "THE-ID"
#     item.label = "A label for the name attribute"
#     item.free_text = "This is some free text"
#     item.ordinal = 45
#     item.to_xml(mdv, form, item_group)
#     xml = odm.to_xml
#   #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
#     expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
#     odm_fix_datetimes(xml, expected)
#     odm_fix_system_version(xml, expected)
#     expect(xml).to eq(expected)
#   end

end
  