require 'rails_helper'

describe SdtmIgDomain do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_ig_domain"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")

  end

  it "allows an IG Domain to be found" do
    item = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an IG Domain to get children (variables)" do
    actual = []
    item = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

  it "allows an IG Domain to get children (variables), WILL CURRENTLY FAIL" do
    actual = []
    item = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_MH/V4#IGD"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children_2.yaml", equate_method: :hash_equal)
  end

  it "allows an IG Domain to get children (variables)" do
    actual = []
    item = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V4#IGD"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children_3.yaml", equate_method: :hash_equal)
  end

  it "unique name in domain, true" do
    ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    ig_var = SdtmIgDomain::Variable.new
    expect(ig_domain.unique_name_in_domain?(ig_var, 'AESEVXX')).to eq(true)
  end

  it "unique name in domain, false" do
    ig_domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
    ig_var = SdtmIgDomain::Variable.new
    expect(ig_domain.unique_name_in_domain?(ig_var, 'AESEV')).to eq(false)
  end

end