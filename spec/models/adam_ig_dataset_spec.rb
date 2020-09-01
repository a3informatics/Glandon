require 'rails_helper'

describe AdamIgDataset do

  include DataHelpers

  def sub_dir
    return "models/adam_ig_dataset"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ADAM_IG_1-0-0 Draft.ttl"]
    load_files(schema_files, data_files)
  end

  it "allows an ADaM IG to be found" do
    item = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIGBDS"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows an ADaM IG to get children (domains)" do
    actual = []
    item = AdamIgDataset.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRAdamIgT/CDISC/V1#AIG-CDISC_ADAMIGBDS"))
    children = item.get_children
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

end