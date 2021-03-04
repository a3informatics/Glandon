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
      load_test_bc_template_and_instances
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
      load_test_bc_template_and_instances
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

  describe "Validation" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      #load_test_bc_template_and_instances
      ##load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      load_cdisc_term_versions(1..10)
    end

    it "identifier required and not multiple, simple test" do
      bc = BiomedicalConceptInstance.new
      bc.uri = bc.create_uri(bc.class.base_uri)
      item = BiomedicalConcept::Item.new
      item.uri = item.create_uri(item.class.base_uri)
      bc.has_item = [item]
      bc.identified_by = item
      cdt = BiomedicalConcept::ComplexDatatype.new
      cdt.uri = cdt.create_uri(cdt.class.base_uri)
      item.has_complex_datatype = [cdt]
      property = BiomedicalConcept::PropertyX.new
      property.uri = property.create_uri(property.class.base_uri)
      cdt.has_property = [property]
      property.identifier_property = true
      expect(property.valid?).to eq(true) #Has_coded_value empty
      property.has_coded_value_push(1) 
      expect(property.valid?).to eq(true) #Has_coded_value == 1
      property.has_coded_value_push(2) 
      expect(property.valid?).to eq(false) #Has_coded_value == 2
    end


    it "identifier required and not multiple, multiple cv" do
      cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41259"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41260"))
      bc = BiomedicalConceptInstance.create(label: "BC test", identifier: "XXX")
      item = BiomedicalConcept::Item.create
      bc.has_item = [item]
      bc.identified_by = item
      cdt = BiomedicalConcept::ComplexDatatype.create
      item.has_complex_datatype = [cdt]
      property = BiomedicalConcept::PropertyX.create
      cdt.has_property = [property]
      item.save
      cdt.save
      property.save
      bc.save
      bc = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCI"))
      bc.update_property({property_id: property.id, has_coded_value: [{id: cli_1.id, context_id: cl.id}]})
      bc = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCI"))
      result = bc.update_property({property_id: property.id, has_coded_value: [{id: cli_1.id, context_id: cl.id}, {id: cli_2.id, context_id: cl.id}]})
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages).to eq(["Has coded value attempting to add multiple values when the property is the identifier"])
      bc = BiomedicalConceptInstance.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#BCI"))
      expect(bc.has_item.first.has_complex_datatype.first.has_property.first.has_coded_value.count).to eq(1)
    end

  end

  describe "Identifier" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_bc_template_and_instances
    end

    it "finds managed ancestors, single" do
      uri = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI")
      bc = BiomedicalConceptInstance.find(uri)
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      expect(property.identifier_property).to eq(false)
      expect(property.identifier_property?(bc)).to eq(true)
      property.identifier_property = true
      expect(property.identifier_property).to eq(true)
      property.identifier_property = false
      expect(property.identifier_property).to eq(false)
      uri_p = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI4_BCCDTCD_BCPcode")
      property = BiomedicalConcept::PropertyX.find(uri_p)
      expect(property.identifier_property?(bc)).to eq(false)
      expect(property.identifier_property).to eq(false)
    end

  end
end
