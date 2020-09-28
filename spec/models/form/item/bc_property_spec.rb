require 'rails_helper'

describe Form::Item::BcProperty do

  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/item/bc_property"
  end

  describe "Validation tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Item::BcProperty.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.ordinal = 1
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, ordinal" do
      item = Form::Item::BcProperty.new
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      item.ordinal = 0
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
      expect(item.errors.count).to eq(1)
      expect(result).to eq(false)
    end

  end

  describe "Make common tests" do

    before :all do
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "make common I" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_1.yaml", equate_method: :hash_equal)
    end

    it "make common II, error" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2_BP3"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end
  