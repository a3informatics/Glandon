require 'rails_helper'

describe Export do

	include DataHelpers

  def sub_dir
    return "models/exports"
  end

  before :all do
    data_files = ["iso_registration_authority_real.ttl","iso_namespace_real.ttl", "form_example_dm1.ttl", "form_example_vs_baseline_new.ttl", "form_example_general.ttl", 
        "CT_V42.ttl", "CT_V43.ttl", "CT_ACME_V1.ttl", "thesaurus.ttl", "BCT.ttl", "BC.ttl"]
    load_files(schema_files, data_files)
    
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "generates the thesaurus list - WILL CURRENTLY FAIL" do
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