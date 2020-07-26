require 'rails_helper'

describe Form do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl" ]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..65)
    load_data_file_into_triple_store("mdr_identification.ttl")
  end

  it "validates a valid object" do
    result = Form.new
    result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
    result.note = "FFF"
    result.completion = "F"
    result.has_state = IsoRegistrationStateV2.new
    result.has_state.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#RS_A00001")
    result.has_state.by_authority = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    result.has_identifier = IsoScopedIdentifierV2.new
    result.has_identifier.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#SI_A00001")
    result.has_identifier.identifier = "AAA"
    result.has_identifier.semantic_version = "0.0.1"
    result.has_identifier.version = 1
    expect(result.valid?).to eq(true)
  end

  it "allows validity of the object to be checked - error" do
    result = Form.new
    result.valid?
    expect(result.errors.count).to eq(3)
    expect(result.errors.full_messages[0]).to eq("Uri can't be blank")
    expect(result.errors.full_messages[1]).to eq("Has identifier empty object")
    expect(result.errors.full_messages[2]).to eq("Has state empty object")
    expect(result.valid?).to eq(false)
  end

  it "allows a Form to be found" do
    item = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
  end

  it "allows a Form to be found, full" do
    item = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    check_file_actual_expected(item.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
  end

  it "allows a Form to be found, minimum" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    check_file_actual_expected(item.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
  end

  it "get items" do
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected.yaml", equate_method: :hash_equal)
  end

  it "get items II" do
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/VSTADIABETES/V1#F"))
    check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_2.yaml", equate_method: :hash_equal)
  end

  it "get items III" do
    form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
    check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_3.yaml", equate_method: :hash_equal)
  end

  # it "allows a form to be found, BC based" do
  #   result = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   check_file_actual_expected(result.to_json, sub_dir, "example_vs_baseline_new.yaml", equate_method: :hash_equal)
  # end

  # it "handles a form not being found" do
  #   expect{Form.find("F-ACME_T2x", "http://www.assero.co.uk/MDRForms/ACME/V1")}.to raise_error(Exceptions::NotFoundError)
  # end

  # it "finds all entries" do
  #   expected = []
  #   expected[0] = {:id => "F-ACME_DM101"}
  #   expected[1] = {:id => "F-ACME_T2"}
  #   expected[2] = {:id => "F-ACME_VSBASELINE1"}
  #   results = Form.all
  #   expect(results.count).to eq(3)
  #   results.each do |result|
  #     found = expected.find { |x| x[:id] == result.id }
  #     expect(result.id).to eq(found[:id])
  #   end
  # end

  # it "finds all unique entries" do
  #   ns = IsoNamespace.find_by_short_name("ACME")
  #   expected = 
  #     [
  #       {
  #         :identifier=>"T2",
  #         :label=>"Test 2",
  #         :scope_id=>ns.id,
  #         :owner=>"ACME"
  #       },
  #       {
  #         :identifier=>"DM1 01",
  #         :label=>"Demographics",
  #         :scope_id=>ns.id,
  #         :owner=>"ACME"
  #       },
  #       {
  #         :identifier=>"VS BASELINE",
  #         :label=>"Vital Signs Baseline",
  #         :scope_id=>ns.id,
  #         :owner=>"ACME"
  #       }
  #     ]
  #   expect(Form.unique).to eq (expected)
  # end

  # it "finds list of all released entries" do
  #   expected = []
  #   expected[0] = {:id => "F-ACME_VSBASELINE1", :scoped_identifier_version => 1}
  #   results = Form.list
  #   expected.each_with_index do |x, index|
  #     expect(results[index].id).to eq(expected[index][:id])
  #     expect(results[index].scopedIdentifier.version).to eq(expected[index][:scoped_identifier_version])
  #   end
  # end

  # it "finds the history of an item" do
  #   results = []
  #   results[0] = {:id => "F-ACME_DM101", :scoped_identifier_version => 2}
  #   results[1] = {:id => "F-ACME_DM101", :scoped_identifier_version => 1}
  #   item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   item.registrationState.registrationStatus = "Standard"
  #   operation = item.to_operation
  #   new_item = Form.create(operation)
  #   expect(new_item.errors.full_messages.to_sentence).to eq("")
  #   expect(new_item.errors.count).to eq(0)
  #   params = {:identifier => "DM1 01", :scope => IsoRegistrationAuthority.owner.ra_namespace}
  #   items = Form.history(params)
  #   expect(items.count).to eq(2)
  #   items.each_with_index do |item, index|
  #     expect(results[index][:id]).to eq(items[index].id)
  #     expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
  #   end   
  # end
  
  # it "allows a placeholder form to be created from parameters" do
  #   item = Form.create_placeholder({:identifier => "PLACE NEW", :label => "Placeholder New", :freeText => "Placeholder Test Form"})
  #   expect(item.errors.full_messages.to_sentence).to eq("")
  #   expect(item.errors.count).to eq(0)
  # end

  # it "allows a form to be created from operation JSON" do
  #   operation = read_yaml_file_to_hash_2(sub_dir, "example_simple_placeholder_with_operation.yaml")
  #   item = Form.create(operation)
  #   expect(item.errors.full_messages.to_sentence).to eq("")
  #   expect(item.errors.count).to eq(0)
  # end

  # it "allows a form to be created from operation SPARQL, no load" do
  #   operation = read_yaml_file_to_hash_2(sub_dir, "no_load_input_1.yaml")
  #   item = Form.create_no_load(operation)
  #   expect(item.errors.full_messages.to_sentence).to eq("")
  #   expect(item.errors.count).to eq(0)
  # #Xwrite_text_file_2(item.to_sparql_v2.to_s, sub_dir, "create_no_load_expected_1.ttl")
  #   write_text_file_2(item.to_sparql_v2.to_s, sub_dir, "create_no_load_actual_1.ttl")
  #   check_ttl_fix("create_no_load_actual_1.ttl", "create_no_load_expected_1.ttl", {last_changed_date: true})
  #   delete_data_file(sub_dir, "create_no_load_actual_1.ttl")
  # end

  # it "allows a form to be created from operation JSON, base core form" do
  #   # Leave these lines in, used to build initial test file, might be useful
  #   #text = read_text_file_2(sub_dir, "base_core.txt")
  #   #hash = JSON.parse(text)
  #   #write_hash_to_yaml_file_2(hash.deep_symbolize_keys, sub_dir, "base_core.yaml")
  #   parameters = read_yaml_file_to_hash_2(sub_dir, "base_core.yaml")
  #   item = Form.create(parameters[:form])
  # #Xwrite_hash_to_yaml_file_2(item.to_json, sub_dir, "base_core_result.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "base_core_result.yaml")
  #   expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
  #   expect(item.errors.count).to eq(0)
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows a form to be created from operation JSON, base BC form" do
  #   # Leave these lines in, used to build initial test file, might be useful
  #   #text = read_text_file_2(sub_dir, "base_bc.txt")
  #   #hash = JSON.parse(text)
  #   #write_hash_to_yaml_file_2(hash.deep_symbolize_keys, sub_dir, "base_bc.yaml")
  #   parameters = read_yaml_file_to_hash_2(sub_dir, "base_bc.yaml")
  #   item = Form.create(parameters[:form])
  # #Xwrite_hash_to_yaml_file_2(item.to_json, sub_dir, "base_bc_result.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "base_bc_result.yaml")
  #   expected[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
  #   expect(item.errors.count).to eq(0)
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows a form to be created from operation JSON, create error" do
  #   json = read_yaml_file_to_hash_2(sub_dir, "base_bc.yaml")
  #   allow_any_instance_of(Form).to receive(:valid?).and_return(true) 
  #   allow_any_instance_of(Form).to receive(:create_permitted?).and_return(true) 
  #   response = Typhoeus::Response.new(code: 200, body: "")
  #   expect(CRUD).to receive(:update).and_return(response)
  #   expect{Form.create(json[:form])}.to raise_error(Errors::CreateError, "Failed to create Form. .")
  # end

  # it "allows a form to be updated" do
  #   old_item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   old_item.label = "New Label"
  #   Form.update(old_item.to_operation)
  #   item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
  # #Xwrite_hash_to_yaml_file_2(item.to_json, sub_dir, "update.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "update.yaml")
  #   expected[:last_changed_date] = date_check_now(item.lastChangeDate,5).iso8601
  #   expected[:creation_date] = date_check_now(item.creationDate,5).iso8601
  #   expect(item.errors.count).to eq(0)
  #   expect(item.to_json).to eq(expected)
  # end

  # it "allows a form to be updated, error" do
  #   item = Form.create_placeholder({:identifier => "UPDATE ERRORS", :label => "Update Errors", :freeText => "Update Errors"})
  #   expect(item.errors.full_messages.to_sentence).to eq("")
  #   expect(item.errors.count).to eq(0)
  #   old_item = Form.find("F-ACME_UPDATEERRORS", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   new_item = read_yaml_file_to_hash_2(sub_dir, "update_error_1.yaml")
  #   update_item = Form.update(new_item[:form])
  #   expect(update_item.errors.full_messages.to_sentence).to eq("Group, ordinal=1, error: Group, ordinal=2, error: Item, ordinal=1, error: Optional contains an invalid boolean value")
  #   expect(update_item.errors.count).to eq(1)
  # end

  # it "allows a form to be destroyed" do
  #   item = Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   item.destroy
  #   expect{Form.find("F-ACME_PLACENEW", "http://www.assero.co.uk/MDRForms/ACME/V1")}.to raise_error(Exceptions::NotFoundError)
  # end

  # it "can serialize as json, core form" do
  #   item = Form.find("F-ACME_TEST1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "base_core_result.yaml")
  #   expected[:last_changed_date] = date_check_now(item.lastChangeDate,5).iso8601
  #   expect(item.to_json).to hash_equal(expected) 
  # end

  # it "can serialize as json, BC form" do
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  # #Xwrite_hash_to_yaml_file_2(item.to_json, sub_dir, "base_bc_json.yaml")
  #   expected = read_yaml_file_to_hash_2(sub_dir, "base_bc_json.yaml")
  #   expected[:last_changed_date] = item.lastChangeDate # Last changed data is dynamic
  #   expect(item.to_json).to hash_equal(expected) 
  # end

  # it "can create the sparql for core form" do
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   item.lastChangeDate = "2016-12-23T15:14:09+00:00".to_time_with_default # Fix the time to match the test time
  # #Xwrite_text_file_2(item.to_sparql_v2.to_s, sub_dir, "to_sparql_expected_1.txt")
  #   write_text_file_2(item.to_sparql_v2.to_s, sub_dir, "to_sparql_result_1.txt")
  #   actual = read_sparql_file("to_sparql_result_1.txt")
  #   expected = read_sparql_file("to_sparql_expected_1.txt")
  #   expect(actual).to sparql_results_equal(expected)
  #   delete_data_file(sub_dir, "to_sparql_result_1.txt")
  # end

  # it "can create the sparql for BC form" do
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   item.lastChangeDate = "2016-12-23T15:14:09+00:00".to_time_with_default # Fix the time to match the test time
  # #Xwrite_text_file_2(item.to_sparql_v2.to_s, sub_dir, "to_sparql_expected_2.txt")
  #   write_text_file_2(item.to_sparql_v2.to_s, sub_dir, "to_sparql_result_2.txt")
  #   actual = read_sparql_file("to_sparql_result_2.txt")
  #   expected = read_sparql_file("to_sparql_expected_2.txt")
  #   expect(actual).to sparql_results_equal(expected)
  #   delete_data_file(sub_dir, "to_sparql_result_2.txt")
  # end

  # it "to_xml, I" do
  #   item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   xml = item.to_xml
  # #Xwrite_text_file_2(xml, sub_dir, "to_xml_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
  # it "to_xml, II" do
  #   item = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   xml = item.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_2.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_2.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end

  # it "checks if the form is valid?" do
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   result = item.valid?
  #   expect(result).to eq(true)
  #   item.label = "@@£±£±"
  #   result = item.valid?
  #   expect(result).to eq(false)
  #   expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
  #   item.label = "addd"
  #   result = item.valid?
  #   expect(result).to eq(true)
  #   item.completion = "±±±±±"
  #   result = item.valid?
  #   expect(result).to eq(false)
  #   expect(item.errors.full_messages.to_sentence).to eq("Completion contains invalid markdown")
  #   item.completion = ""
  #   result = item.valid?
  #   expect(result).to eq(true)
  #   item.note = "§§§§§§"
  #   result = item.valid?
  #   expect(result).to eq(false)
  #   expect(item.errors.full_messages.to_sentence).to eq("Note contains invalid markdown")
  #   item.note = ""
  #   result = item.valid?
  #   expect(result).to eq(true)
  # end
  
  # it "generates the form annotations" do
  #   item = Form.find("F-ACME_TEST1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_1.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_1.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_2.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_2.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_3.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_3.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_4.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_4.yaml")
  #   expect(annotations).to eq(expected)
  # end
  
end