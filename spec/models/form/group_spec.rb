require 'rails_helper'

describe Form::Group do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/group"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Group.new
    result.note = "OK"
    result.completion = "Draft 123"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    result = Form::Group.new
    result.note = "OK"
    result.completion = "Draft 123€"
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, note" do
    result = Form::Group.new
    result.note = "OK€"
    result.completion = "Draft 123"
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, optional" do
    result = Form::Group.new
    result.ordinal = 1
    result.optional = ""
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, ordinal" do
    result = Form::Group.new
    result.ordinal = 0
    result.optional = true
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   item = Form::Group.new
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
  
end
  