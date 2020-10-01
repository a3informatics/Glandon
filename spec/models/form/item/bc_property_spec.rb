require 'rails_helper'

describe Form::Item::BcProperty do

  include DataHelpers
  include OdmHelpers
  include SparqlHelpers
  include SecureRandomHelpers

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
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "forms/FN000150.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "make common I" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_1.yaml", equate_method: :hash_equal)
    end

    it "make common II, error, There is no common group" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2_BP3"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_2.yaml", equate_method: :hash_equal)
    end

    it "make common III, check terminologies" do 
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      normal.add_child({type:"common_group"})
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      normal.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})
      normal = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#BCP_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_3.yaml", equate_method: :hash_equal)
    end

    it "make common IV, check terminologies" do 
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      normal.add_child({type:"common_group"})
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      normal.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#BCP_b76597f7-972f-40f4-bed7-e134725cf296"))
      result = bc_property.make_common
      check_file_actual_expected(result, sub_dir, "make_common_expected_4.yaml", equate_method: :hash_equal)
    end

  end

end
  