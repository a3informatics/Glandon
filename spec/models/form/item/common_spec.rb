require 'rails_helper'

describe Form::Item::Common do
  
  include DataHelpers

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

  describe "Restore" do
    
    before :each do
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Restore (delete) Common item" do
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(2)
      result = common_item.delete(parent)
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      expect{Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI1 in Form::Item::Common.")
      check_file_actual_expected(result, sub_dir, "restore_1.yaml", equate_method: :hash_equal)
    end

    it "Restore (delete) Common item" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      bc_property.make_common
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      result = common_item.delete(parent)
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(0)
      expect{Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1 in Form::Item::Common.")
      check_file_actual_expected(result, sub_dir, "restore_2.yaml", equate_method: :hash_equal)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      result = bc_property.make_common
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1_CI1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      check_file_actual_expected(result, sub_dir, "restore_3.yaml", equate_method: :hash_equal)
    end

  end

end
  