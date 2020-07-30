require 'rails_helper'

describe BiomedicalConcept::PropertyX do

  include DataHelpers
  include SparqlHelpers
  include IsoConceptsHelpers

  def sub_dir
    return "models/biomedical_concept/property_x"
  end

  describe "Validity Tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object I" do
      item = BiomedicalConcept::PropertyX.new
      item.question_text = "Draft 123"
      item.prompt_text = "Draft 123"
      item.uri = item.create_uri(item.class.base_uri)
      result = item.valid?
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(result).to eq(true)
    end

    it "validates a valid object II" do
      result = BiomedicalConcept::PropertyX.new
      result.question_text = "Draft 123"
      result.prompt_text = "Draft 123"
      result.format = "5.2"
      result.uri = result.create_uri(result.class.base_uri)
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object - Question Text" do
      result = BiomedicalConcept::PropertyX.new
      result.uri = result.create_uri(result.class.base_uri)
      result.question_text = "Draft 123€"
      result.prompt_text = "Draft 123"
      result.format = "5.2"
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
    end

    it "does not validate an invalid object - Prompt Text" do
      result = BiomedicalConcept::PropertyX.new
      result.question_text = "Draft 123"
      result.prompt_text = "Draft 123€"
      result.format = "5.2"
      result.uri = result.create_uri(result.class.base_uri)
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Prompt text contains invalid characters")
    end

    it "does not validate an invalid object - Format" do
      result = BiomedicalConcept::PropertyX.new
      result.question_text = "Draft 123"
      result.prompt_text = "Draft 123"
      result.format = "5.2s"
      result.uri = result.create_uri(result.class.base_uri)
      expect(result.valid?).to eq(false)
      expect(result.errors.full_messages.to_sentence).to eq("Format contains invalid characters")
    end

  end

  describe "Ancestors" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "finds managed ancestors, single" do
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      results = property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_1.yaml", equate_method: :hash_equal)
      expect(property.multiple_managed_ancestors?).to eq(false)
      expect(property.no_managed_ancestors?).to eq(false)
      expect(property.managed_ancestors?).to eq(true)
    end

    it "finds managed ancestors, multiple" do
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD_BCPcode")
      bc = BiomedicalConceptInstance.create(label: "this is XXX", identifier: "XXX")
      bc.has_item_push(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1"))
      bc.save
      property = BiomedicalConcept::PropertyX.find(uri_p)
      results = property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_2.yaml", equate_method: :hash_equal)
      expect(property.multiple_managed_ancestors?).to eq(true)
      expect(property.no_managed_ancestors?).to eq(false)
      expect(property.managed_ancestors?).to eq(true)
    end

  end

  # it "allows coded to be set" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   property.set_coded
  #   expect(property.coded?).to eq (true)
  # end

  # it "prevents coded being set on complex property" do
  #   property = BiomedicalConcept::Property.find("BCT-Obs_PQR_DefinedObservation_nameCode_CD_originalText", "http://www.assero.co.uk/MDRBCTs/V1")
  #   property.set_coded
  #   expect(property.coded?).to eq (false)
  # end

  # it "allows coded to be determined" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   property.set_coded
  #   expect(property.coded?).to eq (true)
  # end

  # it "allows the object to be found - TC Refs" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   check_file_actual_expected(property.to_json, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
  # end

  # it "allows the property to be updated" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
  #   params = {}
  #   params[:question_text] = "New Q"
  #   params[:prompt_text] = "New P"
  #   params[:enabled] = "true"
  #   params[:collect]= "true"
  #   params[:format] = "10.1"
  #   property.update(params)
  #   expect(property.errors.count).to eq(0)
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   check_file_actual_expected(property.to_json, sub_dir, "update.yaml", equate_method: :hash_equal)
  # end

  # it "prevents a property being updated with invalid data" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
  #   params = {}
  #   params[:question_text] = "£££££££"
  #   params[:prompt_text] = "New P"
  #   params[:enabled] = "true"
  #   params[:collect]= "true"
  #   params[:format] = "10.1"
  #   property.update(params)
  #   expect(property.errors.full_messages.to_sentence).to eq("Question text contains invalid characters")
  #   expect(property.errors.count).to eq(1)
  # end

  # it "handles errors during an update" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
  #   params = {}
  #   params[:question_text] = "New Q"
  #   params[:prompt_text] = "New P"
  #   params[:enabled] = "true"
  #   params[:collect]= "true"
  #   params[:format] = "10.1"
  #   response = Typhoeus::Response.new(code: 200, body: "")
  #   expect(Rest).to receive(:sendRequest).and_return(response)
  #   expect(response).to receive(:success?).and_return(false)
  #   expect(ConsoleLogger).to receive(:info)
  #   expect{property.update(params)}.to raise_error(Exceptions::UpdateError)
  # end

  # it "allows term references to be added" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   refs = []
  #   refs << { :subject_ref => {id: "new_1", namespace: "http://example.com/term" }, ordinal: 5}
  #   refs << { :subject_ref => {id: "new_2", namespace: "http://example.com/term" }, ordinal: 6}
  #   property.add({ tc_refs: refs })
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  # #Xwrite_yaml_file(property.to_json, sub_dir, "add_term.yaml")
  #   check_file_actual_expected(property.to_json, sub_dir, "add_term.yaml", equate_method: :hash_equal)
  #   expect(property.tc_refs.count).to eq(6)
  # end

  # it "handles error adding term references" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   refs = []
  #   refs << { :subject_ref => {id: "new_3", namespace: "http://example.com/term" }, ordinal: 7}
  #   response = Typhoeus::Response.new(code: 200, body: "")
  #   expect(Rest).to receive(:sendRequest).and_return(response)
  #   expect(response).to receive(:success?).and_return(false)
  #   expect(ConsoleLogger).to receive(:info)
  #   expect{property.add({ tc_refs: refs })}.to raise_error(Exceptions::UpdateError)
  # end

  # it "allows term refs to be removed" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   property.remove
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  # #Xwrite_yaml_file(property.to_json, sub_dir, "remove_term.yaml")
  #   expected = read_yaml_file(sub_dir, "remove_term.yaml")
  #   expect(property.tc_refs.count).to eq(0)
  #   expect(property.to_json).to eq(expected)
  # end

  # it "handles error removing term references" do
  #   property = BiomedicalConcept::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_value_PQR_code", "http://www.assero.co.uk/MDRBCs/V1")
  #   response = Typhoeus::Response.new(code: 200, body: "")
  #   expect(Rest).to receive(:sendRequest).and_return(response)
  #   expect(response).to receive(:success?).and_return(false)
  #   expect(ConsoleLogger).to receive(:info)
  #   expect{property.remove}.to raise_error(Exceptions::UpdateError)
  # end

end
