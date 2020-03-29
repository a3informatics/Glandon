require 'rails_helper'

describe Form::Item do
  
  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/item"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item.new
    result.note = "OK"
    result.completion = "Draft 123"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, completion" do
    result = Form::Item.new
    result.note = "OK"
    result.completion = "Draft 123§"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "does not validate an invalid object, note" do
    result = Form::Item.new
    result.note = "OK§"
    result.completion = "Draft 123"
    result.ordinal = 1
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "does not validate an object, ordinal" do
    result = Form::Item.new
    result.note = "OK"
    result.completion = "Draft 123"
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(true)
    expect(result.ordinal).to eq(1)
  end

  it "does not validate an invalid object, optional" do
    result = Form::Item.new
    result.note = "OK"
    result.completion = "Draft 123"
    result.ordinal = 1
    result.optional = ""
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.valid?).to eq(false)
  end

  it "allows an object to be import and exported" do
    input = read_yaml_file(sub_dir, "from_json_input.yaml")
    actual = Form::Item.from_h(input)
    check_file_actual_expected(actual.to_h, sub_dir, "to_json_expected_1.yaml")
  end	

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    item = Form::Item.new
    item.label = "test label"
    item.completion = "Completion"
    item.note = "Note"
    item.ordinal = 1
    item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/path#parent"))
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.ttl")
    check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.ttl")
  end

  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   form.add_item_group_ref("G-TEST", "1", "No", "")
  #   item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
  #   item = Form::Item.new
  #   item.id = "THE-ID"
  #   item.ordinal = 14
		# item.to_xml(mdv, form, item_group)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
end
  