require 'rails_helper'

describe Form do

  include DataHelpers
  include SparqlHelpers
  include SecureRandomHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/form"
  end

  describe "Validation Tests" do
    
    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "validates a valid object" do
      result = Form.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "FFF"
      result.completion = "F"
      result.has_state = IsoRegistrationStateV2.new
      result.has_state.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#RS_A00001")
      result.has_state.by_authority = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      result.has_identifier = IsoScopedIdentifierV2.new
      result.has_identifier.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#SI_A00001")
      result.has_identifier.identifier = "AAA"
      result.has_identifier.semantic_version = "0.0.1"
      result.has_identifier.version = 1
      expect(result.valid?).to eq(true)
    end

    it "allows validity of the object to be checked - error" do
      result = Form.new
      result.valid?
      expect(result.errors.count).to eq(3)
      expect(result.errors.full_messages[0]).to eq("Uri can't be blank")
      expect(result.errors.full_messages[1]).to eq("Has identifier empty object")
      expect(result.errors.full_messages[2]).to eq("Has state empty object")
      expect(result.valid?).to eq(false)
    end

  end

  describe "Find Tests" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "allows a Form to be found" do
      item = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a Form to be found, full" do
      item = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(item.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a Form to be found, minimum" do
      item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(item.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
    end

    it "get items" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected.yaml", equate_method: :hash_equal)
    end

    it "get items II" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/VSTADIABETES/V1#F"))
      check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_2.yaml", equate_method: :hash_equal)
    end

    it "get items III" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_3.yaml", equate_method: :hash_equal)
    end

    it "get items IV" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.get_items, sub_dir, "get_items_with_references_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "CRF Tests" do
    
    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl", 
                    "forms/FN000150.ttl", "forms/CRF TEST 1.ttl","forms/FN000120.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
    end

    it "to crf I" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_1.yaml", equate_method: :hash_equal)
    end

    it "to crf II" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_2.yaml", equate_method: :hash_equal)
    end

    it "to crf III" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_3.yaml", equate_method: :hash_equal)
    end

    it "to crf IV, bc repeating group, disable property" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      coded_value_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG1_BP3_TUC1"))
      coded_value_reference.enabled = false
      coded_value_reference.save
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_4.yaml", equate_method: :hash_equal)
    end

    it "to crf V, common group, disable property" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      coded_value_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_CG1_CI2_TUC1"))
      coded_value_reference.enabled = false
      coded_value_reference.save
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_5.yaml", equate_method: :hash_equal)
    end

    it "to crf VI, move node" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_6_a.yaml", equate_method: :hash_equal)
      parent = Form::find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      item = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG3"))
      result = parent.move_down(item)
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.to_crf, sub_dir, "to_crf_6_b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Get referenced items Tests" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "get referenced items" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected.yaml", equate_method: :hash_equal)
    end

    it "get referenced items II" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/VSTADIABETES/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_2.yaml", equate_method: :hash_equal)
    end

    it "get referenced items III" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_3.yaml", equate_method: :hash_equal)
    end

    it "get referenced items IV" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(form.get_referenced_items, sub_dir, "get_referenced_items_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add child" do
    
    before :all do
      data_files = ["forms/FN000150.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "add child I" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.find_minimum(uri)
      result = form.add_child({type:"normal_group"})
      form = Form.find_full(uri)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected.yaml", equate_method: :hash_equal)
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      result = form.add_child({type:"normal_group"})
      form = Form.find_full(uri)
      check_file_actual_expected(form.to_h, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    # it "add child II, error" do
    #   form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    #   expect{form.add_child({type:"x_group"})}.to raise_error(Errors::ApplicationLogicError, "Attempting to add an invalid child type")
    # end

  end

  describe "Path Tests" do

    it "returns read path" do
      check_file_actual_expected(Form.read_paths, sub_dir, "read_paths_expected.yaml", equate_method: :hash_equal)
    end

    it "returns delete path" do
      check_file_actual_expected(Form.delete_paths, sub_dir, "delete_paths_expected.yaml", equate_method: :hash_equal)
    end

  end

  describe "Update Tests" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "update normal group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_1a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.update_with_clone({label: "New label"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_1b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_1a.yaml", equate_method: :hash_equal)
    end

    it "update question, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_2a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.update_with_clone({label: "New label"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_2b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_2b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_2a.yaml", equate_method: :hash_equal)
    end

    it "update text label, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"text_label"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_3a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      text_label = Form::Item::TextLabel.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#TL_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      text_label.update_with_clone({label_text: "New label text"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_3b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_3b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_3a.yaml", equate_method: :hash_equal)
    end

    it "update placeholder, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"placeholder"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_4a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_4a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      placeholder = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#PL_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      placeholder.update_with_clone({free_text: "New free text"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_4b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_4b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_4a.yaml", equate_method: :hash_equal)
    end

    it "update mapping, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"mapping"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_5a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      mapping = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#MA_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      mapping.update_with_clone({mapping: "New mapping"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_5b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_5b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_5a.yaml", equate_method: :hash_equal)
    end

    it "update normal group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_6a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_6a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      sub_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      sub_group.update_with_clone({label: "New label"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_6b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_6b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_6a.yaml", equate_method: :hash_equal)
    end

    it "update common group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"common_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_7a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_7a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      common_group = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238_CG"))
      common_group.update_with_clone({label: "New label"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_7b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_7b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_7a.yaml", equate_method: :hash_equal)
    end

  end

  describe "Update Tests" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..59)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    
    it "update bc group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_form_8a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_8a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      bc_group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      bc_group.update_with_clone({label: "New label"}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_form_8b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_form_8b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "update_form_8a.yaml", equate_method: :hash_equal)
    end

  end

  describe "Delete Tests" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "delete normal group, clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_1a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      expect(new_form.has_group.count).to eq(1)
      expect(form.has_group.count).to eq(1)
      normal_group.delete(new_form, new_form)
      new_form = Form.find_full(new_form.uri)
      expect(new_form.has_group.count).to eq(0)
      check_dates(new_form, sub_dir, "delete_form_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_1b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      expect(form.has_group.count).to eq(1)
      check_dates(form, sub_dir, "delete_form_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_1a.yaml", equate_method: :hash_equal)
    end

    it "delete normal group, clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_2a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      expect(new_form.has_group.count).to eq(1)
      expect(form.has_group.count).to eq(1)
      normal_group.delete(new_form, new_form)
      new_form = Form.find_full(new_form.uri)
      expect(new_form.has_group.count).to eq(0)
      check_dates(new_form, sub_dir, "delete_form_2b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_2b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      expect(form.has_group.count).to eq(1)
      check_dates(form, sub_dir, "delete_form_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_2a.yaml", equate_method: :hash_equal)
    end

    it "delete normal group, clone" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_3a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      sub_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      expect(new_form.has_group.count).to eq(1)
      expect(form.has_group.count).to eq(1)
      sub_group.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      expect(new_form.has_group.count).to eq(1)
      check_dates(new_form, sub_dir, "delete_form_3b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_3b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      expect(form.has_group.count).to eq(1)
      check_dates(form, sub_dir, "delete_form_3a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_3a.yaml", equate_method: :hash_equal)
    end

    it "delete common group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"common_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_4a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_4a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      common_group = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238_CG"))
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      expect(normal_group.has_common.count).to eq(1)
      common_group.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_4b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_4b.yaml", equate_method: :hash_equal)
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      expect(normal_group.has_common.count).to eq(1)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_4a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_4a.yaml", equate_method: :hash_equal)
    end

    it "delete question, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_5a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_5b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_5b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_5a.yaml", equate_method: :hash_equal)
    end

    it "delete question, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_6a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_6a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      question.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_6b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_6b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_6a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_6a.yaml", equate_method: :hash_equal)
    end

    it "delete normal group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"normal_group"})
      normal_group.add_child({type:"normal_group"})
      normal_group.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_7a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_7a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      sub_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      sub_group.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_7b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_7b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_7a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_7a.yaml", equate_method: :hash_equal)
    end

    it "delete normal group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      form.add_child({type:"normal_group"})
      form.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_8a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_8a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      sub_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      sub_group.delete(form, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_8b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_8b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_8a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_8a.yaml", equate_method: :hash_equal)
    end

    it "delete normal group, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"normal_group"})
      normal_group.add_child({type:"question"})
      normal_group.add_child({type:"normal_group"})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_9a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_9a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      sub_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      sub_group.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "delete_form_9b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_9b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "delete_form_9a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_9a.yaml", equate_method: :hash_equal)
    end

  end

  describe "Delete BC Group" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end
    
    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "deletes BC group and common item" do
      # expect{Form::Group::Bc.find(Uri.new(uri: "http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Form::Group::Bc.")
      # expect{Form::Item::Common.find(Uri.new(uri: "http://www.example.com/A#CI_f9fe7128-4b63-482d-9a11-62250e24fe0c"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.example.com/A#CI_f9fe7128-4b63-482d-9a11-62250e24fe0c in Form::Item::Common.")
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/DIABP/V1#BCI"))
      normal_group.add_child({type:"common_group"})
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id]})
      normal_group.add_child({type:"normal_group"})
      normal_group.add_child({type:"normal_group"})
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCP_36d01a04-97fa-4ae9-8f40-9f266a6cdc06"))
      bc_property.make_common
      make_standard(form)
      form = Form.find_full(form.uri)
      #check_dates(form, sub_dir, "delete_form_10a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_10a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      bc_group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCG_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      bc_group.delete(normal_group, new_form)
      new_form = Form.find_full(new_form.uri)
      #check_dates(new_form, sub_dir, "delete_form_10b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "delete_form_10b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_file_actual_expected(form.to_h, sub_dir, "delete_form_10a.yaml", equate_method: :hash_equal)
    end

    # it "deletes BC group, doesn't delete common item" do
    #   allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    #   normal_1 = Form::Group::Normal.create(uri: Uri.new(uri: "http://www.example.com/A#X2"), note: "OK", ordinal: 1, completion: "None")
    #   expect(normal_1.errors.count).to eq(0)
    #   bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/DIABP/V1#BCI"))
    #   bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/SYSBP/V1#BCI"))
    #   result = normal_1.add_child({type:"common_group"})
    #   result = normal_1.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id]})
    #   normal_1.save
    #   normal_1 = Form::Group::Normal.find_full(normal_1.uri)
    #   bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.example.com/A#BCP_b76597f7-972f-40f4-bed7-e134725cf296"))
    #   bc_property.make_common
    #   normal_1 = Form::Group::Normal.find_full(normal_1.uri)
    #   check_file_actual_expected(normal_1.to_h, sub_dir, "delete_bc_group_expected_2a.yaml", equate_method: :hash_equal)
    #   common_item = Form::Item::Common.find(Uri.new(uri: "http://www.example.com/A#CI_9512d1d4-7f6c-4b3c-a330-ff3081f8de24"))
    #   group = Form::Group::Bc.find(Uri.new(uri: "http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
    #   result = group.delete(normal_1)
    #   expect{Form::Group::Bc.find(Uri.new(uri: "http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.example.com/A#BCG_1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Form::Group::Bc.")
    #   common_item = Form::Item::Common.find(Uri.new(uri: "http://www.example.com/A#CI_9512d1d4-7f6c-4b3c-a330-ff3081f8de24"))
    #   check_file_actual_expected(result, sub_dir, "delete_bc_group_expected_2b.yaml", equate_method: :hash_equal)
    # end
  end

  # it "to_xml, I" do
  #   item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   xml = item.to_xml
  # #Xwrite_text_file_2(xml, sub_dir, "to_xml_1.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_1.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
  # it "to_xml, II" do
  #   item = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   xml = item.to_xml
  # #write_text_file_2(xml, sub_dir, "to_xml_2.xml")
  #   expected = read_text_file_2(sub_dir, "to_xml_2.xml")
  #   odm_fix_datetimes(xml, expected)
  #   odm_fix_system_version(xml, expected)
  #   expect(xml).to eq(expected)
  # end
  
  # it "generates the form annotations" do
  #   item = Form.find("F-ACME_TEST1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_1.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_1.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_TEST2", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_2.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_2.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_DM101", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_3.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_3.yaml")
  #   expect(annotations).to eq(expected)
  #   item = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   annotations = item.annotations
  # #write_yaml_file(annotations, sub_dir, "annotations_4.yaml")
  #   expected = read_yaml_file(sub_dir, "annotations_4.yaml")
  #   expect(annotations).to eq(expected)
  # end
  
end