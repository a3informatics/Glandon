require 'rails_helper'

describe Export do

	include DataHelpers

  def sub_dir
    return "models/exports"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("form_example_dm1.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("CT_ACME_V1.ttl")
    load_test_file_into_triple_store("thesaurus.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "generates the thesaurus list" do
    results = Export.new.terminologies
  #write_yaml_file(results, sub_dir, "thesaurus_export_1.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_export_1.yaml")
    expect(results).to hash_equal(expected)
  end
  
  it "generates the BCs list" do
    results = Export.new.biomedical_concepts
  #write_yaml_file(results, sub_dir, "biomedical_concepts_export_1.yaml")
    expected = read_yaml_file(sub_dir, "biomedical_concepts_export_1.yaml")
    expect(results).to hash_equal(expected)
  end
  
  it "generates the thesaurus list" do
    results = Export.new.forms
  #write_yaml_file(results, sub_dir, "forms_export_1.yaml")
    expected = read_yaml_file(sub_dir, "forms_export_1.yaml")
    expect(results).to hash_equal(expected)
  end
  
end