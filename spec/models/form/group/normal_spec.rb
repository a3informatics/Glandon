require 'rails_helper'

describe Form::Group::Normal do
  
  include DataHelpers
  include SparqlHelpers
  include SecureRandomHelpers

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
    
    def check_normal_group(uri, filename, write_file=false)
      normal = Form::Group::Normal.find_full(uri)
      check_file_actual_expected(normal.to_h, sub_dir, filename, equate_method: :hash_equal, write_file: write_file)
    end

    before :each do
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/MAKE_COMMON_TEST.ttl", "forms/CRF TEST 1.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl") 
    end

    it "add child I, add normal groups" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"normal_group"})
      check_normal_group(uri, "add_child_expected_1.yaml")
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"normal_group"})
      check_normal_group(uri, "add_child_expected_2.yaml")
    end

    it "add child II, error" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"x_group"})
      expect(normal.errors.count).to eq(1)
      expect(normal.errors.full_messages[0]).to eq("Attempting to add an invalid child type")
      expect(result).to eq([])
    end

    it "add child III, bc groups" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_normal_group(uri, "add_child_expected_3.yaml")
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_2.id, bci_3.id]})
      check_normal_group(uri, "add_child_expected_4.yaml")
    end

    it "add child IV, bc groups" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_normal_group(uri, "add_child_expected_7.yaml")
    end

    it "add child V, items" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"question"})
      check_normal_group(uri, "add_child_expected_5.yaml")
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"placeholder"})
      check_normal_group(uri, "add_child_expected_6.yaml")
    end

    it "add child VI, bc group, check bc property common" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(uri)
      normal.add_child({type:"common_group"})
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(uri)
      normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      normal = Form::Group::Normal.find(uri)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#BCP_b76597f7-972f-40f4-bed7-e134725cf296"))
      bc_property.make_common
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(uri)
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_normal_group(uri, "add_child_expected_11.yaml")
    end

  end

  describe "Common Group Handling" do
    
    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl") 
    end

    it "add normal groups" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X1"), note: "OK", ordinal: 1, completion: "None")
      expect(normal.errors.count).to eq(0)
      result = normal.add_child({type:"normal_group"})
      normal = Form::Group::Normal.find_full(normal.uri)
      check_file_actual_expected(normal.to_h, sub_dir, "add_child_normal_expected_1.yaml", equate_method: :hash_equal)
      result = normal.add_child({type:"normal_group"})
      normal = Form::Group::Normal.find_full(normal.uri)
      check_file_actual_expected(normal.to_h, sub_dir, "add_child_normal_expected_2.yaml", equate_method: :hash_equal)
    end

    it "add normal groups and common" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X2"), note: "OK", ordinal: 1, completion: "None")
      expect(normal.errors.count).to eq(0)
      result = normal.add_child({type:"normal_group"})
      result = normal.add_child({type:"normal_group"})
      result = normal.add_child({type:"common_group"})
      normal = Form::Group::Normal.find_full(normal.uri)
      check_file_actual_expected(normal.to_h, sub_dir, "add_child_common_expected_1.yaml", equate_method: :hash_equal)
    end

    it "add normal groups and common, error" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X3"), note: "OK", ordinal: 1, completion: "None")
      expect(normal.errors.count).to eq(0)
      result = normal.add_child({type:"normal_group"})
      result = normal.add_child({type:"normal_group"})
      result = normal.add_child({type:"common_group"})
      result = normal.add_child({type:"common_group"})
      expect(normal.errors.count).to eq(1)
      expect(normal.errors.full_messages[0]).to eq("Normal group already contains a Common Group")
      normal = Form::Group::Normal.find_full(normal.uri)
      check_file_actual_expected(normal.to_h, sub_dir, "add_child_common_expected_4.yaml", equate_method: :hash_equal)
    end

    it "add normal groups and common, check clash" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal_1 = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X4"), note: "OK", ordinal: 1, completion: "None")
      expect(normal_1.errors.count).to eq(0)
      result = normal_1.add_child({type:"normal_group"})
      result = normal_1.add_child({type:"normal_group"})
      result = normal_1.add_child({type:"normal_group"})
      result = normal_1.add_child({type:"normal_group"})
      result = normal_1.add_child({type:"common_group"})
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      check_file_actual_expected(normal_1.to_h, sub_dir, "add_child_common_expected_2.yaml", equate_method: :hash_equal)
      normal_2 = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X5"), note: "OK", ordinal: 1, completion: "None")
      expect(normal_2.errors.count).to eq(0)
      result = normal_2.add_child({type:"normal_group"})
      result = normal_2.add_child({type:"normal_group"})
      result = normal_2.add_child({type:"common_group"})
      # Normal 1 should not have changed
      normal_1 = Form::Group::Normal.find_full(normal_1.uri)
      check_file_actual_expected(normal_1.to_h, sub_dir, "add_child_common_expected_2.yaml", equate_method: :hash_equal)
      normal_2 = Form::Group::Normal.find_full(normal_2.uri)
      check_file_actual_expected(normal_2.to_h, sub_dir, "add_child_common_expected_3.yaml", equate_method: :hash_equal)
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
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
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
  