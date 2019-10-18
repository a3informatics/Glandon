require 'rails_helper'

describe "CdiscTerm" do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
  end

  def check_term_differences(results, expected)
    expect(results[:status]).to eq(expected[:status])
    expect(results[:result]).to eq(expected[:result])
    expect(results[:children].count).to eq(expected[:children].count)
    results[:children].each do |key, result|
      found = expected[:children][key]
      expect(result).to eq(found)
    end
  end

  def load_versions(range)
    range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
  end

  describe "CDISC Terminology General" do

    before :all do
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
        "CT_V1.ttl",
        "CT_V2.ttl",
        "CT_V3.ttl",
        "CT_V4.ttl",
        "CT_V5.ttl",
        "CT_V6.ttl",
        "CT_V7.ttl",
        "CT_V8.ttl",
        "CT_V9.ttl",
        "CT_V10.ttl"
      ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      #
    end

    it "get children" do
      actual = []
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
      results = ct.managed_children_pagination({offset: 0, count: 10})
      results.each {|x| actual << x.to_h}
      check_file_actual_expected(actual, sub_dir, "children_pagination_1.yaml", write_file: true)
      results = ct.managed_children_pagination({offset: 10, count: 5})
      actual = []
      results.each {|x| actual << x.to_h}
      check_file_actual_expected(actual, sub_dir, "children_pagination_2.yaml", write_file: true)
    end

    it "returns the owner" do
      CdiscTerm.clear_owner
      expect(CdiscTerm.get_owner).to be_nil
      result = CdiscTerm.owner
      expect(result.to_h).to eq(IsoRegistrationAuthority.find_by_short_name("CDISC").to_h)
      expect(CdiscTerm.get_owner).to_not be_nil
    end

    it "get version dates" do
      actual = CdiscTerm.version_dates
      check_file_actual_expected(actual, sub_dir, "version_dates_expected_1.yaml")
    end

    it "add item"

    it "configuration"

    it "child class"

  end

end