require 'rails_helper'

describe Form::Group::Common do
  
  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/group/common"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = Form::Group::Common.new
    item.note = "OK"
    item.completion = "Draft 123"
    item.ordinal = 2
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    item = Form::Group::Common.new
    item.note = "OK"
    item.completion = "Draft 123±"
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Completion contains invalid markdown")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, note" do
    item = Form::Group::Common.new
    item.note = "OK±"
    item.completion = "Draft 123"
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Note contains invalid markdown")
    expect(item.errors.count).to eq(1)
    expect(result).to eq(false)
  end

  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   item = Form::Group::Common.new
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
  