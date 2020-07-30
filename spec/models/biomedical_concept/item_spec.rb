require 'rails_helper'
require 'biomedical_concept/item'

describe BiomedicalConcept::Item do
  
  include DataHelpers
  include SparqlHelpers
  include IsoConceptsHelpers

  def sub_dir
    return "models/biomedical_concept/item"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
  end

  describe "Validation" do

    it "validates a valid object" do
      item = BiomedicalConcept::Item.new
      item.mandatory = true
      item.enabled = false
      item.ordinal = 1
      item.uri = item.create_uri(item.class.base_uri)
      result = item.valid?
      expect(result).to eq(true)
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
      uri_i   = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1")
      property = BiomedicalConcept::Item.find(uri_i)
      results = property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_1.yaml", equate_method: :hash_equal)
      expect(property.multiple_managed_ancestors?).to eq(false)
      expect(property.no_managed_ancestors?).to eq(false)
      expect(property.managed_ancestors?).to eq(true)
    end

    it "finds managed ancestors, multiple" do
      uri_i   = Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1")
      bc = BiomedicalConceptInstance.create(label: "this is XXX", identifier: "XXX")
      bc.has_item_push(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI_BCI1"))
      bc.save
      property = BiomedicalConcept::PropertyX.find(uri_i)
      results = property.managed_ancestor_uris
      check_file_actual_expected(map_ancestors(results), sub_dir, "managed_ancestor_uris_expected_2.yaml", equate_method: :hash_equal)
      expect(property.multiple_managed_ancestors?).to eq(true)
      expect(property.no_managed_ancestors?).to eq(false)
      expect(property.managed_ancestors?).to eq(true)
    end

  end

end
  