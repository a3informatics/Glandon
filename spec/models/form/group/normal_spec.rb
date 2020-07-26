require 'rails_helper'

describe Form::Group::Normal do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/group/normal"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/VSTADIABETES.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..65)
    load_data_file_into_triple_store("mdr_identification.ttl")
  end

  it "get items" do
    group = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/VSTADIABETES/V1#F_NG1"))
    check_file_actual_expected(group.get_item, sub_dir, "get_items_expected.yaml", equate_method: :hash_equal)
  end

  it "validates a valid object" do
    item = Form::Group::Normal.new
    item.uri = Uri.new(uri: "http://www.example.com/A#X")
    item.note = "OK"
    item.completion = "Draft 123"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    item = Form::Group::Normal.new
    item.uri = Uri.new(uri: "http://www.example.com/A#X")
    item.note = "OK"
    item.completion = "Draft 123£"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Completion contains invalid markdown")
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, note" do
    item = Form::Group::Normal.new
    item.uri = Uri.new(uri: "http://www.example.com/A#X")
    item.note = "OK±"
    item.completion = "Draft 123"
    item.ordinal = 1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Note contains invalid markdown")
    expect(result).to eq(false)
  end

  it "does not validate an invalid object, repeating" do
    item = Form::Group::Normal.new
    item.uri = Uri.new(uri: "http://www.example.com/A#X")
    item.note = "OK"
    item.completion = "Draft 123"
    item.repeating = ""
    item.ordinal = 1
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
  