require 'rails_helper'

describe "Thesaurus::Rank" do

  include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/thesaurus/rank"
  end

  describe "rank" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "rank_input_1.ttl")
    end

    it "update rank" do
      rank_member_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRM#cfaf817d-6abf-4b60-8096-8a0594f0efbf")
      rank_member = Thesaurus::RankMember.find(rank_member_uri_1)
      rank_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8")
      rank = Thesaurus::Rank.find(rank_uri_1)
      rank.update([{cli_id:Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C87054").to_id, rank: 2}])
      actual_rank = Thesaurus::Rank.find(rank_uri_1)
      actual_rank_member = Thesaurus::RankMember.find(rank_member_uri_1)
      check_file_actual_expected(actual_rank_member.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update rank" do
      params = [{cli_id: Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C84372").to_id, rank: 3},{cli_id: Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C87054").to_id, rank: 4}]
      rank_member_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRM#cfaf817d-6abf-4b60-8096-8a0594f0efbf")
      rank_member_1 = Thesaurus::RankMember.find(rank_member_uri_1)
      rank_member_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TRM#9ca1d4b4-fad4-45f2-9321-a33788698352")
      rank_member_2 = Thesaurus::RankMember.find(rank_member_uri_2)
      rank_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8")
      rank = Thesaurus::Rank.find(rank_uri_1)
      rank.update(params)
      actual_rank = Thesaurus::Rank.find(rank_uri_1)
      actual_rank_member_1 = Thesaurus::RankMember.find(rank_member_uri_1)
      actual_rank_member_2 = Thesaurus::RankMember.find(rank_member_uri_2)
      check_file_actual_expected(actual_rank_member_1.to_h, sub_dir, "update_expected_2a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(actual_rank_member_2.to_h, sub_dir, "update_expected_2b.yaml", equate_method: :hash_equal)
    end

    it "update rank" do
      params = [{cli_id: Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C84372").to_id, rank: 1},{cli_id: Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C87054").to_id, rank: 2}]
      rank_member_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRM#cfaf817d-6abf-4b60-8096-8a0594f0efbf")
      rank_member_1 = Thesaurus::RankMember.find(rank_member_uri_1)
      rank_member_uri_2 = Uri.new(uri: "http://www.assero.co.uk/TRM#9ca1d4b4-fad4-45f2-9321-a33788698352")
      rank_member_2 = Thesaurus::RankMember.find(rank_member_uri_2)
      rank_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8")
      rank = Thesaurus::Rank.find(rank_uri_1)
      rank.update(params)
      actual_rank = Thesaurus::Rank.find(rank_uri_1)
      actual_rank_member_1 = Thesaurus::RankMember.find(rank_member_uri_1)
      actual_rank_member_2 = Thesaurus::RankMember.find(rank_member_uri_2)
      check_file_actual_expected(actual_rank_member_1.to_h, sub_dir, "update_expected_3a.yaml", equate_method: :hash_equal)
      check_file_actual_expected(actual_rank_member_2.to_h, sub_dir, "update_expected_3b.yaml", equate_method: :hash_equal)
    end

    it "remove all" do
      rank_member_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRM#b55166df-4fd1-4569-8600-f1d7176d607f")
      rank_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8")
      rank = Thesaurus::Rank.find(rank_uri_1)
      rank_member = Thesaurus::Rank.find(rank_member_uri_1)
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741"))
      tc.is_ranked = rank
      tc.save
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741"))
      expect(tc.is_ranked).to eq(rank.uri)
      rank.remove_all
      expect{Thesaurus::Rank.find(rank.uri)}.to raise_error(Errors::NotFoundError,
        "Failed to find http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8 in Thesaurus::Rank.")
      expect{Thesaurus::RankMember.find(rank_member.uri)}.to raise_error(Errors::NotFoundError,
        "Failed to find http://www.assero.co.uk/TRM#b55166df-4fd1-4569-8600-f1d7176d607f in Thesaurus::RankMember.")
      actual_tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741"))
      expect(actual_tc.is_ranked).to be(nil)
    end

  end

end
