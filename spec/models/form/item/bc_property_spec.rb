require 'rails_helper'

describe Form::Item::BcProperty do

  include DataHelpers
  include SparqlHelpers
  include SecureRandomHelpers
  include IsoManagedHelpers


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

  describe "To CRF tests" do

    before :all do
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "to CRF I" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      result = bc_property.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_1.yaml", equate_method: :hash_equal)
    end

    it "returns the input_field result, nil datatype" do
       bcp_x = BiomedicalConcept::PropertyX.new(uri: Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCI_BCI11_BCCDTPQR_BCPvalue"), ordinal: 1)
       ref = OperationalReferenceV3.new(uri: Uri.new(uri: "http://www.s-cubed.dk/V1#R1"), ordinal: 1, reference: bcp_x.uri)
       item = Form::Item::BcProperty.new(uri: Uri.new(uri: "http://www.s-cubed.dk/V1#BCP1"), ordinal: 1, has_coded_value: [])
       item.has_property = ref.uri
       item.save
       result = item.input_field(bcp_x)
       check_file_actual_expected(result, sub_dir, "to_crf_expected_2.yaml", equate_method: :hash_equal)
    end

    it "to CRF II, fix enabled bug" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      result = bc_property.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_3.yaml", equate_method: :hash_equal)
      bc_property.has_property_objects.update(enabled: false)
      bc_property.save
      result = bc_property.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_4.yaml", equate_method: :hash_equal)
    end

    it "to CRF III, fix optional bug" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      bc_property.has_property_objects.update(enabled: true)
      bc_property.save
      result = bc_property.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_5.yaml", equate_method: :hash_equal)
      bc_property.has_property_objects.update(optional: true)
      bc_property.save
      result = bc_property.to_crf(nil)
      check_file_actual_expected(result, sub_dir, "to_crf_expected_6.yaml", equate_method: :hash_equal)
    end

  end

  describe "Make common tests" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :all do
      data_files = ["forms/MAKE_COMMON_TEST.ttl", "forms/FN000150.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "make common with clone, error, There is no common group" do
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2_BP3"))
      result = bc_property.make_common_with_clone(nil)
      check_file_actual_expected(bc_property.errors.full_messages, sub_dir, "make_common_expected_2.yaml", equate_method: :hash_equal)
    end

    it "make common I" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_BCG2_BP2"))
      cg = Form::Group::Common.find(Uri.new(uri: "http://www.s-cubed.dk/MAKE_COMMON_TEST/V1#F_NG1_CG1"))
      result = bc_property.make_common(cg)
      check_file_actual_expected(result, sub_dir, "make_common_expected_1.yaml", equate_method: :hash_equal)
    end

    it "make common III, check terminologies" do 
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      cg = normal.add_child({type:"common_group"})
      cg = Form::Group::Common.find(cg.uri)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      normal.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})
      normal = Form::Group::Normal.find_full(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#BCP_92bf8b74-ec78-4348-9a1b-154a6ccb9b9f"))
      result = bc_property.make_common(cg)
      check_file_actual_expected(result, sub_dir, "make_common_expected_3.yaml", equate_method: :hash_equal)
    end

    # it "make common IV, check terminologies" do 
    #   allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    #   normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
    #   cg = normal.add_child({type:"common_group"})
    #   cg = Form::Group::Common.find(cg.uri)
    #   normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
    #   bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
    #   bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
    #   bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
    #   normal.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})
    #   normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
    #   bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#BCP_b76597f7-972f-40f4-bed7-e134725cf296"))
    #   result = bc_property.make_common(cg)
    #   check_file_actual_expected(result, sub_dir, "make_common_expected_4.yaml", equate_method: :hash_equal)
    # end

    it "make common VI, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"common_group"})
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "make_common_expected_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "make_common_expected_5a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCP_36d01a04-97fa-4ae9-8f40-9f266a6cdc06"))
      bc_property.make_common_with_clone(new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "make_common_expected_5b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "make_common_expected_5b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "make_common_expected_5a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "make_common_expected_5a.yaml", equate_method: :hash_equal)
    end

  end

  describe "Update with clone Tests" do

    def make_standard(item)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Incomplete"
      item.update_status(params)
    end

    before :each do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..59)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "update bc property, clone, no errors" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id]})
      make_standard(form)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_bc_property_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_bc_property_1a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCP_36d01a04-97fa-4ae9-8f40-9f266a6cdc06"))
      bc_property.update_with_clone({completion: "New completion", note: "New note", optional: true, enabled: false}, new_form)
      new_form = Form.find_full(new_form.uri)
      check_dates(new_form, sub_dir, "update_bc_property_1b.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(new_form.to_h, sub_dir, "update_bc_property_1b.yaml", equate_method: :hash_equal)
      form = Form.find_full(form.uri)
      check_dates(form, sub_dir, "update_bc_property_1a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(form.to_h, sub_dir, "update_bc_property_1a.yaml", equate_method: :hash_equal)
    end

  end

end
  