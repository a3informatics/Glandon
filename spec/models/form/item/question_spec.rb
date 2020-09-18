require 'rails_helper'

describe Form::Item::Question do
  
  include DataHelpers
  include OdmHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/item/question"
  end

  describe "Validations" do
    
    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
    end

    it "validates a valid object" do
      item = Form::Item::Question.new
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      item.datatype = "string"
      item.format = "20"
      item.question_text = "Hello"
      item.ordinal = 1
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(result).to eq(true)
    end

    it "does not validate an invalid object, question text" do
      result = Form::Item::Question.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.datatype = "S"
      result.format = "20"
      result.question_text = "Hello|€"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
    end

    it "does not validate an invalid object, format" do
      result = Form::Item::Question.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.datatype = "S"
      result.format = "3#"
      result.question_text = "Hello|"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Format contains invalid characters")
    end

    it "get items" do
      question = Form::Item::Question.find_children(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      check_file_actual_expected(question.get_item, sub_dir, "get_item_expected.yaml", equate_method: :hash_equal)
    end
  
  end

  describe "Add child" do
    
    before :each do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "add child I, cli" do
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V4#C66789_C49484"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66790/V4#C66790_C17998"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66790/V4#C66790_C43234"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V13#C66789"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      result = question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      result = question.add_child({type:"tuc_reference", id_set:[{id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end

    # it "add child II, error" do
    #   normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
    #   expect{normal.add_child({type:"x_item"})}.to raise_error(Errors::ApplicationLogicError, "Attempting to add an invalid child type")
    # end

  end

  describe "Destroy" do
    
    before :each do
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Delete question" do
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = question.delete(parent)
      expect{Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1 in Form::Item::Question.")
    end

  end

end
  