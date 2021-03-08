require 'rails_helper'

describe Form::Item::Common do

  include DataHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/form/item/common"
  end

  describe "Validations" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Item::Common.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, ordinal" do
      item = Form::Item::Common.new
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      item.ordinal = 0
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
      expect(item.errors.count).to eq(1)
      expect(result).to eq(false)
    end

  end

  describe "Basic tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      load_data_file_into_triple_store("complex_datatypes.ttl")
    end

    it "returns the item array" do
      item = Form::Item::Common.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1)
      result = item.get_item
      check_file_actual_expected(result, sub_dir, "get_item_expected_1.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, non coded" do
      bc_property = BiomedicalConcept::PropertyX.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), question_text: "Something", prompt_text: "Else", format: "13", alias: "Well", is_complex_datatype_property: Uri.new(uri: "http://www.s-cubed.dk/CDT#BL_value"))
      ref = OperationalReferenceV3.create({uri: Uri.new(uri: "http://www.s-cubed.dk/R1"), ordinal: 1, reference: bc_property}, bc_property)
      item = Form::Item::Common.create(uri: Uri.new(uri: "http://www.s-cubed.dk/CI1"), ordinal: 1, has_property: ref.uri)
      item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CI1"))
      item.has_property_objects
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, coded" do
      bc_property = BiomedicalConcept::PropertyX.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q2"), question_text: "Something", prompt_text: "Else", format: "13", alias: "Well", is_complex_datatype_property: Uri.new(uri: "http://www.s-cubed.dk/CDT#CD_code"))
      ref = OperationalReferenceV3.create({uri: Uri.new(uri: "http://www.s-cubed.dk/Ref1"), ordinal: 1, reference: bc_property}, bc_property)
      uri1 = Uri.new(uri: "http://www.cdisc.org/C66769/V2#C66769_C41338")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C66769/V2#C66769_C41339")
      item = Form::Item::Common.create(uri: Uri.new(uri: "http://www.s-cubed.dk/CI2"), ordinal: 1, has_property: ref.uri)
      ref_cl1 = OperationalReferenceV3::TucReference.create({uri: Uri.new(uri: "http://www.s-cubed.dk/Ref2"), ordinal: 1, reference: uri1, local_label: "Mild Adverse Event"}, item)
      ref_cl2 = OperationalReferenceV3::TucReference.create({uri: Uri.new(uri: "http://www.s-cubed.dk/Ref3"), ordinal: 2, reference: uri2, local_label: "Moderate Adverse Event"}, item)
      item.has_coded_value_push(ref_cl1)
      item.has_coded_value_push(ref_cl2)
      item.save
      item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CI2"))
      item.has_property_objects
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_2.yaml", equate_method: :hash_equal)
    end

    it "returns the children in ordinal order" do
      item = Form::Item::Common.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q2"), ordinal: 1)
      expect(item.children_ordered).to eq([])
      ref_2 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R12"), ordinal: 2, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI12"), local_label: "Ordinal 2")
      ref_2.save
      item.has_coded_value_push(ref_2.uri)
      item.save
      result = item.children_ordered
      check_file_actual_expected(result.map{|x| x.to_h}, sub_dir, "children_ordered_expected_1.yaml", equate_method: :hash_equal)
      ref_1 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R11"), ordinal: 1, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI11"), local_label: "Ordinal 1")
      ref_1.save
      ref_4 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R14"), ordinal: 4, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI14"), local_label: "Ordinal 4")
      ref_4.save
      ref_3 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R13"), ordinal: 3, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI13"), local_label: "Ordinal 3")
      ref_3.save
      item.has_coded_value_push(ref_1)
      item.has_coded_value_push(ref_4)
      item.has_coded_value_push(ref_3)
      item.save
      result = item.children_ordered
      check_file_actual_expected(result.map{|x| x.to_h}, sub_dir, "children_ordered_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Restore" do

    before :each do
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..38)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Restores (delete) Common item" do
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(2)
      result = common_item.delete(parent, parent)
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      expect{Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1 in Form::Item::Common.")
      check_file_actual_expected(result, sub_dir, "restore_1.yaml", equate_method: :hash_equal)
    end

    it "Restores (delete) Common item II" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      cg = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      result = bc_property.make_common(cg)
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKECOMMONTEST/V1#CI_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      result = common_item.delete(parent, parent)
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(0)
      expect{Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1 in Form::Item::Common.")
      check_file_actual_expected(result, sub_dir, "restore_2.yaml", equate_method: :hash_equal)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      cg = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      result = bc_property.make_common(cg)
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKECOMMONTEST/V1#CI_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      check_file_actual_expected(result, sub_dir, "restore_3.yaml", equate_method: :hash_equal)
    end

  end

end
