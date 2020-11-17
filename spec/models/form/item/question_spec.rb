require 'rails_helper'

describe Form::Item::Question do

  include DataHelpers
  include SparqlHelpers
  include IsoManagedHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/form/item/question"
  end

  describe "Validations" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
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

  end

  describe "Basic tests" do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "returns the item array" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      result = item.get_item
      check_file_actual_expected(result, sub_dir, "get_item_expected_1.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, date datatype" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q2"), ordinal: 1, datatype: "date", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_3.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, time datatype" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q3"), ordinal: 1, datatype: "time", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_4.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, float datatype" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q4"), ordinal: 1, datatype: "float", format: "6.2", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_5.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, boolean datatype" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q5"), ordinal: 1, datatype: "boolean", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_6.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, integer datatype" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Q5"), ordinal: 1, datatype: "integer", format: "3", question_text: "Hello")
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_7.yaml", equate_method: :hash_equal)
    end

    it "returns the CRF rendition, CLI ordered" do
      item = Form::Item::Question.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Question1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      ref_2 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Ref2"), ordinal: 2, reference: Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"), local_label: "Ordinal 2")
      ref_2.save
      ref_1 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Ref1"), ordinal: 1, reference: Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"), local_label: "Ordinal 1")
      ref_1.save
      ref_3 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/Ref3"), ordinal: 3, reference: Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"), local_label: "Ordinal 3")
      ref_3.save
      item.has_coded_value_push(ref_1)
      item.has_coded_value_push(ref_3)
      item.has_coded_value_push(ref_2)
      item.save
      check_file_actual_expected(item.to_h, sub_dir, "to_crf_expected_2a.yaml", equate_method: :hash_equal)
      result = item.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_2b.yaml", equate_method: :hash_equal)
    end

    it "returns the children in ordinal order" do
      item = Form::Item::Question.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      expect(item.children_ordered).to eq([])
      ref_2 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R2"), ordinal: 2, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI2"), local_label: "Ordinal 2")
      ref_2.save
      item.has_coded_value_push(ref_2.uri)
      item.save
      result = item.children_ordered
      check_file_actual_expected(result.map{|x| x.to_h}, sub_dir, "children_ordered_expected_1.yaml", equate_method: :hash_equal)
      ref_1 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R1"), ordinal: 1, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI2"), local_label: "Ordinal 1")
      ref_1.save
      ref_4 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R4"), ordinal: 4, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI2"), local_label: "Ordinal 4")
      ref_4.save
      ref_3 = OperationalReferenceV3::TucReference.new(uri: Uri.new(uri: "http://www.s-cubed.dk/R3"), ordinal: 3, reference: Uri.new(uri: "http://www.s-cubed.dk/CLI2"), local_label: "Ordinal 3")
      ref_3.save
      item.has_coded_value_push(ref_1)
      item.has_coded_value_push(ref_4)
      item.has_coded_value_push(ref_3)
      item.save
      result = item.children_ordered
      check_file_actual_expected(result.map{|x| x.to_h}, sub_dir, "children_ordered_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "aCRF" do
    
    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
    end

    it "returns the aCRF rendition" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.mapping = "VSORRESU"
      question.datatype = "datetype" 
      question.question_text = "Question text"
      question.save
      form = Form.find_full(form.uri)
      annotations = Form::Annotations.new(form)
      annotations.domain_list
      annotations.preserve_domain_class(:VS, "domain-1")
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      result = item.to_crf(annotations)
      check_file_actual_expected(result, sub_dir, "to_acrf_expected_1.yaml", equate_method: :hash_equal)
    end
    
  end

  describe "Add child" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      data_files = ["forms/form_test_2.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "adds child I, cli" do
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))
      result = question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))
      result = question.add_child({type:"tuc_reference", id_set:[{id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    it "adds children, removes question and adds children again " do
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))
      result = question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1"))
      question.delete(parent, parent)
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1"))
      parent.add_child({type:"question"})
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q4"))
      result = question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      check_file_actual_expected(result, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end

    it "update question, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "add_child_expected_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected_5a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.add_child_with_clone({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "add_child_expected_5b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "add_child_expected_5b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "add_child_expected_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected_5a.yaml", equate_method: :hash_equal)
    end

  end


  describe "Delete TUc Reference" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      data_files = ["forms/FN000150.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Delete TUc Reference" do
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V4#C66789_C49484"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V13#C66789"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      refs = question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]})
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
      result = question.delete_reference(tuc_reference, question)
      check_file_actual_expected(result, sub_dir, "delete_tuc_reference_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Delete TUc Reference II" do
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
      result = question.delete_reference(tuc_reference, question)
      check_file_actual_expected(result, sub_dir, "delete_tuc_reference_expected_2.yaml", equate_method: :hash_equal)
    end

    it "Delete TUc Reference with clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id:cli_2.id, context_id: context_1.id}, {id:cli_3.id, context_id: context_1.id}]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_tuc_reference_expected_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_tuc_reference_expected_3a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded_TUC2"))
      question = Form::Item::Question.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.delete_reference(tuc_reference, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_tuc_reference_expected_3b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_tuc_reference_expected_3b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_tuc_reference_expected_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_tuc_reference_expected_3a.yaml", equate_method: :hash_equal)
    end

  end

end
