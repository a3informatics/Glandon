require 'rails_helper'

describe Form::Group do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/group"
  end

  describe "Validations" do 

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, completion" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123€"
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, note" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK€"
      result.completion = "Draft 123"
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, optional" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.ordinal = 1
      result.optional = ""
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, ordinal" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.ordinal = 0
      result.optional = true
      expect(result.valid?).to eq(false)
    end

  end

  describe "Destroy" do
    
    before :each do
      data_files = ["forms/FN000150.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Deletes Normal group I" do
      group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      parent = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      expect(parent.has_group.count).to eq(1)
      result = group.delete(parent)
      parent = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      expect(parent.has_group.count).to eq(0)
      expect{Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/FN000150/V1#F_NG1 in Form::Group::Normal.")
    end

    it "Deletes Normal group II" do
      group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      parent = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(parent.to_h[:has_group], sub_dir, "delete_expected_1.yaml", equate_method: :hash_equal)
      result = group.delete(parent)
      parent = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(parent.to_h[:has_group], sub_dir, "delete_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Destroy BC Group" do
    
    before :each do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "deletes BC group and common item" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal_1 = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X1"), note: "OK", ordinal: 1, completion: "None")
      expect(normal_1.errors.count).to eq(0)
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/DIABP/V1#BCI"))
      result = normal_1.add_child({type:"common_group"})
      result = normal_1.add_child({type:"bc_group", id_set:[bci_1.id]})
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.example.com/A#BCP_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      bc_property.make_common
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      check_file_actual_expected(normal_1.to_h, sub_dir, "delete_bc_group_expected_1_a.yaml", equate_method: :hash_equal)
      group = Form::Group::Bc.find(Uri.new(uri: "http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      result = group.delete(normal_1)
      check_file_actual_expected(result, sub_dir, "delete_bc_group_expected_1_b.yaml", equate_method: :hash_equal)
    end

    it "deletes BC group, doesn't delete common item" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal_1 = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X2"), note: "OK", ordinal: 1, completion: "None")
      expect(normal_1.errors.count).to eq(0)
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/DIABP/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/SYSBP/V1#BCI"))
      result = normal_1.add_child({type:"common_group"})
      result = normal_1.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id]})
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.example.com/A#BCP_b76597f7-972f-40f4-bed7-e134725cf296"))
      bc_property.make_common
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      check_file_actual_expected(normal_1.to_h, sub_dir, "delete_bc_group_expected_2_a.yaml", equate_method: :hash_equal)
      group = Form::Group::Bc.find(Uri.new(uri: "http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      result = group.delete(normal_1)
      check_file_actual_expected(result, sub_dir, "delete_bc_group_expected_2_b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down" do
    
    before :each do
      data_files = ["forms/FN000120.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "move up I, normal group " do
      parent = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG2"))
      result = parent.move_up(item)
      expect(result).to eq(true)
      expect(parent.errors.count).to eq(0)
      result = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(result.to_h, sub_dir, "move_up_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move up II, normal group error" do
      parent = Form::find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG1"))
      result = parent.move_up(item)
      expect(result).to eq(false)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move up past the first node")
      result = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(result.to_h, sub_dir, "move_up_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move down I" do
      parent = Form::find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG11"))
      result = parent.move_down(item)
      expect(result).to eq(true)
      expect(parent.errors.count).to eq(0)
      result = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(result.to_h, sub_dir, "move_down_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move down II, error" do
      parent = Form::find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
      result = parent.move_down(item)
      expect(result).to eq(false)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move down past the last node")
      result = Form::find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(result.to_h, sub_dir, "move_down_error_expected_1.yaml", equate_method: :hash_equal)
    end

  end
  
end
  