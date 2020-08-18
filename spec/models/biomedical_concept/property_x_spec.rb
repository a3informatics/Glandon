require 'rails_helper'

describe BiomedicalConcept::PropertyX do

  include DataHelpers
  include SparqlHelpers
  include IsoConceptsHelpers
  include IsoManagedHelpers    

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

  describe "Clones" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD_BCPcode")
      @property = BiomedicalConcept::PropertyX.find(@uri_p)
    end

    it "clones object including reference" do
      result = @property.clone
      check_file_actual_expected(result.to_h, sub_dir, "clone_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Ancestors" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD_BCPcode")
      @property = BiomedicalConcept::PropertyX.find(@uri_p)
    end

    it "finds managed ancestors, single" do
      results = @property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_1.yaml", equate_method: :hash_equal)
      expect(@property.multiple_managed_ancestors?).to eq(false)
      expect(@property.no_managed_ancestors?).to eq(false)
      expect(@property.managed_ancestors?).to eq(true)
    end

    it "finds managed ancestors, multiple" do
      bc = BiomedicalConceptInstance.create(label: "this is XXX", identifier: "XXX")
      bc.has_item_push(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1"))
      bc.save
      results = @property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_2.yaml", equate_method: :hash_equal)
      expect(@property.multiple_managed_ancestors?).to eq(true)
      expect(@property.no_managed_ancestors?).to eq(false)
      expect(@property.managed_ancestors?).to eq(true)
    end

    it "finds path objcts" do
      ma = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      results = @property.managed_ancestor_path_uris(ma)
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "managed_ancestor_path_objects_1.yaml", equate_method: :hash_equal)
    end

    it "updates and clones if needed, single" do
      ma = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      results = @property.update_with_clone({label: "new_label"}, ma)
      check_file_actual_expected(BiomedicalConceptInstance.find_full(ma.uri).to_h, sub_dir, "update_with_clone_1.yaml", equate_method: :hash_equal)
    end

    it "updates and clones if needed, multiple" do
      bc = BiomedicalConceptInstance.create(label: "this is XXX", identifier: "XXX")
      bc.has_item_push(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1"))
      bc.save
      ma = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      results = @property.update_with_clone({label: "all nodes should change"}, bc)
      bc = BiomedicalConceptInstance.find_full(bc.uri)
      ma = BiomedicalConceptInstance.find_full(ma.uri)
      # Useful debugging, set the flag to true for output to console.
      triple_store.subject_triples(ma.uri, false)
      triple_store.subject_triples(bc.uri, false)
      triple_store.subject_triples(bc.has_item.first.uri, false)
      triple_store.subject_triples(bc.has_item.first.has_complex_datatype.first.uri, false)
      triple_store.subject_triples(bc.has_item.first.has_complex_datatype.first.has_property.first.uri, false)
      triple_store.subject_triples(bc.has_item.first.has_complex_datatype.first.has_property.first.has_coded_value.first.uri, false)
      check_file_actual_expected(ma.to_h, sub_dir, "update_with_clone_2b.yaml", equate_method: :hash_equal)
      check_dates(bc, sub_dir, "update_with_clone_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(bc.to_h, sub_dir, "update_with_clone_2a.yaml", equate_method: :hash_equal)
    end

  end

end
