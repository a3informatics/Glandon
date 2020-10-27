require 'rails_helper'

describe AdamIgDataset do

  include DataHelpers

  def sub_dir
    return "models/adam_ig_dataset"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("cdisc/adam_ig/ADAM_IG_V1.ttl")
  end

  it "allows an ADaM IG to be found" do
    item = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.cdisc.org/BDS/V1#ADS"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an ADaM IG to get children (domains)" do
    actual = []
    item = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.cdisc.org/BDS/V1#ADS"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

end