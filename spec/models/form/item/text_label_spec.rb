require 'rails_helper'

describe Form::Item::TextLabel do

  include DataHelpers
  include OdmHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/form/item/text_label"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item::TextLabel.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    result.label_text = "Draft 123"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Form::Item::TextLabel.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    result.label_text = "Draft 123§"
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "returns the item array" do
    item = Form::Item::TextLabel.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), label_text: "A label", ordinal: 1)
    result = item.get_item
    check_file_actual_expected(result, sub_dir, "get_item_expected_1.yaml", equate_method: :hash_equal)
  end

  it "returns the CRF rendition" do
    item = Form::Item::TextLabel.new(uri: Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001"), label_text: "A label", ordinal: 1)
    result = item.to_crf(nil)
    check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
  end

  it "to XML I" do
    allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    odm = add_root
    study = add_study(odm.root)
    mdv = add_mdv(study)
    form = add_form(mdv)
    form.add_item_group_ref("G-TEST", "1", "No", "")
    item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
    item = Form::Item::TextLabel.create(label: "item", ordinal: 22, label_text: "The Label")
    item.to_xml(mdv, form, item_group)
    xml = odm.to_xml
  #Xwrite_text_file_2(xml, sub_dir, "to_xml_1.xml")
    expected = read_text_file_2(sub_dir, "to_xml_1.xml")
    odm_fix_datetimes(xml, expected)
    odm_fix_system_version(xml, expected)
    expect(xml).to eq(expected)
  end

end
