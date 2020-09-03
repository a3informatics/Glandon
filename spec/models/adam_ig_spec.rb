require 'rails_helper'

describe AdamIg do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/adam_ig"
  end

 before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ADAM_IG_1-0-0 Draft.ttl"]
    load_files(schema_files, data_files)
  end

  it "allows an ADaM IG to be found" do
    item = AdamIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an ADaM IG to get children (domains)" do
    actual = []
    item = AdamIg.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIG"))
    children = item.managed_children_pagination({offset: 0, count: 10})
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

end