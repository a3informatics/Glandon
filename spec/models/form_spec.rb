require 'rails_helper'

describe Form do

  include DataHelpers
  include SparqlHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/form"
  end

  describe "Validation Tests" do
    
    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
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

  end

  describe "Find Tests" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
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

    it "get items IV" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "CRF Tests" do
    
    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl", 
                    "forms/FN000150.ttl", "forms/CRF TEST 1.ttl","forms/FN000120.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
    end

    it "to crf I" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_1.yaml", equate_method: :hash_equal)
    end

    it "to crf II" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_2.yaml", equate_method: :hash_equal)
    end

    it "to crf III" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_3.yaml", equate_method: :hash_equal)
    end

    it "to crf IV, bc repeating group, disable property" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      coded_value_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG1_BP3_TUC1"))
      coded_value_reference.enabled = false
      coded_value_reference.save
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_4.yaml", equate_method: :hash_equal)
    end

    it "to crf V, common group, disable property" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      coded_value_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI2_TUC1"))
      coded_value_reference.enabled = false
      coded_value_reference.save
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_5.yaml", equate_method: :hash_equal)
    end

    it "to crf VI, move node" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_6_a.yaml", equate_method: :hash_equal)
      parent = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG3"))
      result = parent.move_down(item)
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_6_b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Get referenced items Tests" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "get referenced items" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected.yaml", equate_method: :hash_equal)
    end

    it "get referenced items II" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/VSTADIABETES/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_2.yaml", equate_method: :hash_equal)
    end

    it "get referenced items III" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_3.yaml", equate_method: :hash_equal)
    end

    it "get referenced items IV" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add child" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "add child I" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.find_minimum(uri)
      result = form.add_child({type:"normal_group"})
      form = Form.find_full(uri)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected.yaml", equate_method: :hash_equal)
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      result = form.add_child({type:"normal_group"})
      form = Form.find_full(uri)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    # it "add child II, error" do
    #   form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    #   expect{form.add_child({type:"x_group"})}.to raise_error(Errors::ApplicationLogicError, "Attempting to add an invalid child type")
    # end

  end

  describe "Path Tests" do

    it "returns read path" do
      check_file_actual_expected(Form.read_paths, sub_dir, "read_paths_expected.yaml", equate_method: :hash_equal)
    end

    it "returns delete path" do
      check_file_actual_expected(Form.delete_paths, sub_dir, "delete_paths_expected.yaml", equate_method: :hash_equal)
    end

  end

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