require 'rails_helper'

describe Form::Group::Normal do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/group/normal"
  end

  describe "Validation tests" do

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

  end

  describe "Add child" do
    
    before :each do
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/MAKE_COMMON_TEST.ttl", "forms/CRF TEST 1.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl") 
    end

    it "add child I, add normal groups" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"normal_group"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected.yaml", equate_method: :hash_equal)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"normal_group"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    it "add child II, error" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"x_group"})
      expect(normal.errors.count).to eq(1)
      expect(normal.errors.full_messages[0]).to eq("Attempting to add an invalid child type")
      expect(result).to eq([])
    end

    it "add child III, bc groups" do
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
byebug
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal, write_file: true)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_2.id, bci_3.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "add child IV, bc groups" do
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_7.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "add child V, items" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"question"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_5.yaml", equate_method: :hash_equal)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"placeholder"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_6.yaml", equate_method: :hash_equal)
    end

    it "add child VI, common group" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG4"))
      result = normal.add_child({type:"common_group"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_8.yaml", equate_method: :hash_equal)
    end

    it "add child VII, common group, error" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1"))
      result = normal.add_child({type:"common_group"})
      expect(normal.errors.count).to eq(1)
      expect(normal.errors.full_messages[0]).to eq("Normal group already contains a Common Group")
    end

    it "Add child VIII, common_group, reset ordinals" do 
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG2"))
      result = normal.add_child({type:"common_group"})
      normal = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG2"))
      check_file_actual_expected(normal.to_h, sub_dir, "add_child_expected_10.yaml", equate_method: :hash_equal)
    end

    it "add child IX, bc group, check bc property common" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      normal.add_child({type:"common_group"})
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_BCG6_BP3"))
      bc_property.make_common
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_11.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

  describe "Delete" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "forms/CRF TEST 1.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl") 
    end

    it "delete I" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"question"})
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"placeholder"})
      normal = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(normal.to_h, sub_dir, "delete_expected_1.yaml", equate_method: :hash_equal)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q4"))
      result = question.delete(normal)
      normal = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(normal.to_h, sub_dir, "delete_expected_2.yaml", equate_method: :hash_equal)
    end

  end
  
end
  