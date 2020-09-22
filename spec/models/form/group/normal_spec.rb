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
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
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
      check_file_actual_expected(result, sub_dir, "add_child_error_expected.yaml", equate_method: :hash_equal)
    end

    it "add child III, bc groups" do
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_2.id, bci_3.id ]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end

    it "add child III, bc groups" do
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"bc_group", id_set:[bci_1.id]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_7.yaml", equate_method: :hash_equal)
    end

    it "add child IV, items" do
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"question"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_5.yaml", equate_method: :hash_equal)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = normal.add_child({type:"placeholder"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_6.yaml", equate_method: :hash_equal)
    end

  end
  
end
  