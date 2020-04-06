require 'rails_helper'

describe Form::Item::TextLabel do
  
  include DataHelpers

  def sub_dir
    return "models/form/item/text_label"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item::TextLabel.new
    result.label_text = "Draft 123"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Form::Item::TextLabel.new
    result.label_text = "Draft 123§"
    expect(result.valid?).to eq(false)
  end
  
  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   form.add_item_group_ref("G-TEST", "1", "No", "")
  #   item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
  #   item = Form::Item::TextLabel.new
  #   item.id = "THE-ID"
  #   item.label = "Item"
  #   item.label_text = "The Label"
  #   item.ordinal = 34
		# item.to_xml(mdv, form, item_group)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end

end
  