require 'rails_helper'

describe Form::Item do

  include DataHelpers
  include IsoManagedHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/form/item"
  end

  describe "Validations" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, completion" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123§"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, note" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK§"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, ordinal" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = ""
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, optional" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      result.optional = ""
      expect(result.valid?).to eq(false)
    end

  end

  describe "Destroy" do

    before :each do
      data_files = ["forms/form_test_2.ttl", "forms/form_test.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Deletes question" do
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1"))
      result = question.delete(parent, parent)
      expect{OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1_TUC1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1_TUC1 in OperationalReferenceV3::TucReference.")
      expect{Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/form_test_2/V1#F_NG1_Q1 in Form::Item::Question.")
      check_file_actual_expected(result, sub_dir, "delete_item_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Deletes placeholder" do
      placeholder = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1"))
      result = placeholder.delete(parent, parent)
      expect{Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/form_test_2/V1#F_NG1_PL2"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/form_test_2/V1#F_NG1_PL2 in Form::Item::Placeholder.")
      check_file_actual_expected(result, sub_dir, "delete_item_expected_2.yaml", equate_method: :hash_equal)
    end

    it "Deletes Common item" do
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1_CI1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(2)
      result = common_item.delete(parent, parent)
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1"))
      expect(parent.has_item.count).to eq(1)
      expect{Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1_CI1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/form_test/V1#F_NG1_CG1_CI1 in Form::Item::Common.")
      check_file_actual_expected(result, sub_dir, "delete_item_expected_3.yaml", equate_method: :hash_equal)
    end

    it "Deletes Common item" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F"))
      params = {registration_status: "Standard", previous_state: "Incomplete"}
      form.update_status(params)
      form = Form.find_full(form.uri)
      fix_dates(form, sub_dir, "delete_item_expected_6a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_item_expected_6a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      parent = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1"))
      common_item = Form::Item::Common.find(Uri.new(uri: "http://www.s-cubed.dk/form_test/V1#F_NG1_CG1_CI1"))
      common_item.delete(parent, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_item_expected_6b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_item_expected_6b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      fix_dates(form, sub_dir, "delete_item_expected_6a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_item_expected_6a.yaml", equate_method: :hash_equal)
    end

    it "Deletes Mapping" do
      parent = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/N1"), note: "OK", ordinal: 1, completion: "None")
      item = Form::Item::Mapping.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, mapping: "string")
      parent.has_item_push(item)
      parent.save
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      check_file_actual_expected(parent.to_h, sub_dir, "delete_item_expected_4a.yaml", equate_method: :hash_equal)
      result = item.delete(parent, parent)
      check_file_actual_expected(result, sub_dir, "delete_item_expected_4b.yaml", equate_method: :hash_equal)
    end

    it "Deletes Text Label" do
      parent = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/N1"), note: "OK", ordinal: 1, completion: "None")
      item = Form::Item::TextLabel.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, label_text: "string")
      parent.has_item_push(item)
      parent.save
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      check_file_actual_expected(parent.to_h, sub_dir, "delete_item_expected_5a.yaml", equate_method: :hash_equal)
      result = item.delete(parent, parent)
      check_file_actual_expected(result, sub_dir, "delete_item_expected_5b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down" do

    before :each do
      data_files = ["forms/FN000150.ttl",]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "move up I, question" do
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q4"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = parent.move_up(item)
      expect(result).to eq(true)
      result = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(result.to_h, sub_dir, "move_up_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move up II, question, error" do
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = parent.move_up(item)
      expect(result).to eq(false)
      expect(parent.errors.count).to eq(1)
      result = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(result.to_h, sub_dir, "move_up_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move down I, question" do
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = parent.move_down(item)
      expect(result).to eq(true)
      result = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(result.to_h, sub_dir, "move_down_expected_1.yaml", equate_method: :hash_equal)
    end

    it "move down II, question, error" do
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q4"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      result = parent.move_down(item)
      expect(result).to eq(false)
      expect(parent.errors.count).to eq(1)
      result = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      check_file_actual_expected(result.to_h, sub_dir, "move_down_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows for move down, two items" do
      parent = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/P1"), note: "OK", ordinal: 1, completion: "None")
      item = Form::Item::Question.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      normal = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/G1"), note: "OK", ordinal: 2, completion: "None")
      parent.has_item_push(item)
      parent.has_sub_group_push(normal)
      parent.save
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      parent.has_sub_group_objects
      check_file_actual_expected(parent.to_h, sub_dir, "move_down_expected_2a.yaml", equate_method: :hash_equal)
      result = parent.move_down(item)
      parent = Form::Group::Normal.find_full(parent.uri)
      check_file_actual_expected(parent.to_h, sub_dir, "move_down_expected_2b.yaml", equate_method: :hash_equal)
      result = parent.move_down(item)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move down past the last node")
    end

    it "allows for move up, two items" do
      parent = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/P1"), note: "OK", ordinal: 1, completion: "None")
      item = Form::Item::Question.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      normal = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/G1"), note: "OK", ordinal: 2, completion: "None")
      parent.has_item_push(item)
      parent.has_sub_group_push(normal)
      parent.save
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      parent.has_sub_group_objects
      check_file_actual_expected(parent.to_h, sub_dir, "move_up_expected_2a.yaml", equate_method: :hash_equal)
      result = parent.move_up(normal)
      parent = Form::Group::Normal.find_full(parent.uri)
      check_file_actual_expected(parent.to_h, sub_dir, "move_up_expected_2b.yaml", equate_method: :hash_equal)
      result = parent.move_up(normal)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move up past the first node")
    end

    it "prevents move up and down, single item" do
      parent = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/P1"), note: "OK", ordinal: 1, completion: "None")
      item = Form::Item::Question.create(uri: Uri.new(uri: "http://www.s-cubed.dk/Q1"), ordinal: 1, datatype: "string", format: "20", question_text: "Hello")
      parent.has_item_push(item)
      parent.save
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      check_file_actual_expected(parent.to_h, sub_dir, "move_up_down_expected_3.yaml", equate_method: :hash_equal)
      result = parent.move_up(item)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move up past the first node")
      parent.errors.clear
      result = parent.move_down(item)
      expect(parent.errors.count).to eq(1)
      expect(parent.errors.full_messages[0]).to eq("Attempting to move down past the last node")
      parent = Form::Group::Normal.find_full(parent.uri)
      parent.has_item_objects
      check_file_actual_expected(parent.to_h, sub_dir, "move_up_down_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down TUC References" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..1)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "move up I, TUC Reference (Coded value), clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_92bf8b74-ec78-4348-9a1b-154a6ccb9b9f"))
      question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "move_up_tuc_ref_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "move_up_tuc_ref_1a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      tuc_ref = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_92bf8b74-ec78-4348-9a1b-154a6ccb9b9f_TUC2"))
      question.move_up_with_clone(tuc_ref, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "move_up_tuc_ref_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "move_up_tuc_ref_1b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "move_up_tuc_ref_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "move_up_tuc_ref_1a.yaml", equate_method: :hash_equal)
    end

    it "move down I, TUC Reference (Coded value), clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_92bf8b74-ec78-4348-9a1b-154a6ccb9b9f"))
      question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "move_down_tuc_ref_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "move_down_tuc_ref_1a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      tuc_ref = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_92bf8b74-ec78-4348-9a1b-154a6ccb9b9f_TUC2"))
      question.move_down_with_clone(tuc_ref, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "move_down_tuc_ref_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "move_down_tuc_ref_1b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "move_down_tuc_ref_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "move_down_tuc_ref_1a.yaml", equate_method: :hash_equal)
    end

  end

end
