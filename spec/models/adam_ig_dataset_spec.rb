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

# =begin
#   def check_model(result, expected)
#     expect(result[:children].count).to eq(expected[:children].count)
#     result[:children].each do |r|
#       item = expected[:children].find { |e| e[:id] == r[:id] }
#       expect(item).to_not be_nil
#       expect(r).to eq(item)
#     end
#   end
# =end

#   it "validates a valid object" do
#     item = AdamIgDataset.new
#     ra = IsoRegistrationAuthority.new
#     ra.uri = "na" # Bit naughty
#     ra.organization_identifier = "123456789"
#     ra.international_code_designator = "DUNS"
#     ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
#     item.registrationState.registrationAuthority = ra
#     si = IsoScopedIdentifier.new
#     si.identifier = "X FACTOR"
#     item.scopedIdentifier = si
#     item.ordinal = 1
#     result = item.valid?
#     expect(item.rdf_type).to eq("http://www.assero.co.uk/BusinessDomain#IgDataset")
#     expect(item.errors.full_messages.to_sentence).to eq("")
#     expect(result).to eq(true)
#   end

#   it "builds an object" do
#     input = read_yaml_file(sub_dir, "build_input_1.yaml")
#     result = AdamIgDataset.build(input)
#   #Xwrite_yaml_file(result.to_json, sub_dir, "build_expected_1.yaml")
#     expected = read_yaml_file(sub_dir, "build_expected_1.yaml")
#     expect(result.to_json).to hash_equal(expected)
#   end

end