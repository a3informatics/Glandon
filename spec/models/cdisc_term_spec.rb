require 'rails_helper'

describe "CdiscTerm" do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
  end

  describe "CDISC Terminology General" do

    before :all do
      data_files = 
      ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
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
      check_file_actual_expected(actual, sub_dir, "children_pagination_1.yaml")
      results = ct.managed_children_pagination({offset: 10, count: 5})
      actual = []
      results.each {|x| actual << x.to_h}
      check_file_actual_expected(actual, sub_dir, "children_pagination_2.yaml")
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

    it "returns child class" do
      expect(CdiscTerm.child_klass).to eq(::CdiscCl)
    end

    it "returns the next version" do
      expect(CdiscTerm.next_version).to eq(11)
    end

  end

end