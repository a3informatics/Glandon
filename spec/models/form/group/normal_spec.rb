require 'rails_helper'

describe Form::Group::Normal do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/group/normal"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Group::Normal.new
    item.note = "OK"
    item.completion = "Draft 123"
    item.ordinal = 1
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.has_sub_group).to eq([])
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, repeating" do
    item = Form::Group::Normal.new
    item.note = "OK"
    item.completion = "Draft 123"
    item.repeating = ""
    item.ordinal = 1
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Repeating contains an invalid boolean value")
    expect(result).to eq(false)
  end

  # it "allows an object to be exported as XML, no children" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   item = Form::Group::Normal.new
  #   item.id = "G-TEST"
  #   item.label = "test label"
  #   item.ordinal = 119
		# item.to_xml(mdv, form)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
  # it "allows an object to be exported as XML, children" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   item_c = Form::Group::Normal.new
  #   item_c.id = "G-TEST-CHILD"
  #   item_c.label = "test label child"
  #   item_c.ordinal = 1
		# item = Form::Group::Normal.new
  #   item.id = "G-TEST"
  #   item.label = "test label"
  #   item.ordinal = 119
		# item.groups << item_c
		# item.to_xml(mdv, form)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_2.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
end
  