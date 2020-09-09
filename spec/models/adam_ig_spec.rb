require 'rails_helper'

describe AdamIg do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/adam_ig"
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
    item = AdamIg.find_minimum(Uri.new(uri: "http://www.cdisc.org/ADAM_IG/V1#AIG"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an ADaM IG to get children (domains)" do
    actual = []
    item = AdamIg.find_minimum(Uri.new(uri: "http://www.cdisc.org/ADAM_IG/V1#AIG"))
    children = item.managed_children_pagination({offset: 0, count: 10})
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

end