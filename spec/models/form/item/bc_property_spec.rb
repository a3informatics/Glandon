require 'rails_helper'

describe Form::Item::BcProperty do

  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/item/bc_property"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports_std.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    result = Form::Item::BcProperty.new
    result.ordinal = 1    
    result.uri = result.create_uri(Uri.new(uri: "http://www.example.com/a#v1"))
    expect(result.has_property).to eq([])
    expect(result.has_coded_value).to eq([])
    expect(result.valid?).to eq(true)
  end

  
  # it "allows an object to be exported as XML" do
  # 	odm = add_root
  #   study = add_study(odm.root)
  #   mdv = add_mdv(study)
  #   form = add_form(mdv)
  #   form.add_item_group_ref("G-TEST", "1", "No", "")
  #   item_group = mdv.add_item_group_def("G-TEST", "test group", "No", "", "", "", "", "", "")
  #   item = Form::Item::BcProperty.new
  #   item.id = "THE-ID"
  #   item.label = "A label for the name attribute"
  #   item.property_ref = OperationalReferenceV2.new
  #   item.property_ref.subject_ref = UriV2.new({:id => "BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", 
  #   	:namespace => "http://www.assero.co.uk/MDRBCs/V1"})
  #   item.rdf_type = "http://www.example.com/path#rdf_test_type"
  #   item.label = "label"
  #   item.note = "Hello!"
  #   item.ordinal = 1
  #   item.is_common = false
  #   tc_ref = OperationalReferenceV2.new
  #   tc_ref.ordinal = 1
  #   tc_ref.subject_ref = UriV2.new({:id => "C66770_C49668", :namespace => "http://www.cdisc.org/C66770/V34"})
  #   item.children << tc_ref
 	# 	item.to_xml(mdv, form, item_group)
		# xml = odm.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_expected_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_expected_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end

end
  