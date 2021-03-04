require 'rails_helper'

describe BiomedicalConcept::ComplexDatatype do
  
  include DataHelpers
  include SparqlHelpers
  include IsoConceptsHelpers
  include IsoManagedHelpers    

  def sub_dir
    return "models/biomedical_concept/complex_datatype"
  end

  describe "Validity" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
    end

    it "validates a valid object" do
      result = BiomedicalConcept::ComplexDatatype.new
      result.uri = result.create_uri(result.class.base_uri)
      expect(result.valid?).to eq(true)
    end

  end 

  describe "Ancestors" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_local_bc_template_and_instances
      #load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      @uri_cdt = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1_BCCDTCD")
      @property = BiomedicalConcept::ComplexDatatype.find(@uri_cdt)
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

    it "finds path objects" do
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
      triple_store.subject_triples(ma.uri, true)
      triple_store.subject_triples(bc.uri, true)
      triple_store.subject_triples(bc.has_item.first.uri, true)
      triple_store.subject_triples(bc.has_item.first.has_complex_datatype.first.uri, true)
      triple_store.subject_triples(bc.has_item.first.has_complex_datatype.first.has_property.first.uri, true)
      check_file_actual_expected(ma.to_h, sub_dir, "update_with_clone_2b.yaml", equate_method: :hash_equal)
      check_dates(bc, sub_dir, "update_with_clone_2a.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(bc.to_h, sub_dir, "update_with_clone_2a.yaml", equate_method: :hash_equal)
    end

  end

end
  