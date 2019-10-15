require 'rails_helper'

describe "Thesaurus::Where" do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/where"
  end

  before :all do
    IsoHelpers.clear_cache
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..25)
  end

  after :all do
  end

  it "allows a terminology where search, single" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    actual = ct.where_children(identifier: "C66770")
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_1.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology where search, single" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    actual = ct.where_children(label: "Units for Vital Signs Results")
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_1.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology where search, single" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    actual = ct.where_children(notation: "VSRESU")
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_1.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology where search, mutliple" do
    ct_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    ct_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V24#TH"))
    ct_3 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V23#TH"))
    ct_4 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V22#TH"))
    ct_5 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V21#TH"))
    actual = Thesaurus.where_children_multiple({notation: "VSRESU"}, [ct_1.uri, ct_2.uri, ct_3.uri, ct_4.uri, ct_5.uri])
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_1.yaml", equate_method: :hash_equal)
    # Note, results should all find the same single Code List
  end

  it "allows a terminology where search, mutliple" do
    ct_1 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    ct_2 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V24#TH"))
    ct_3 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V23#TH"))
    ct_4 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V22#TH"))
    ct_5 = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V21#TH"))
    actual = Thesaurus.where_children_multiple({notation: "mg"}, [ct_1.uri, ct_2.uri, ct_3.uri, ct_4.uri, ct_5.uri])
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_2.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology where search, current set" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V25#TH"))
    ct.has_state.make_current
    actual = Thesaurus.where_children_current({notation: "mg"})
    results = actual.map{|x| x.to_h}
    check_file_actual_expected(results, sub_dir, "where_children_3.yaml", equate_method: :hash_equal)
  end

end