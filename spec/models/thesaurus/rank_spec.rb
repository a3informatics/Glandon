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
      result = rank.remove_all
      expect{Thesaurus::Rank.find(rank.uri)}.to raise_error(Errors::NotFoundError,
        "Failed to find http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8 in Thesaurus::Rank.")
      expect{Thesaurus::RankMember.find(rank_member.uri)}.to raise_error(Errors::NotFoundError,
        "Failed to find http://www.assero.co.uk/TRM#b55166df-4fd1-4569-8600-f1d7176d607f in Thesaurus::RankMember.")
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741"))
      expect(tc.is_ranked).to be(nil)
      #actual_tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741"))
      #expect(actual_rank.members).not_to be(nil)
      #expect{Thesaurus::Rank.find(actual_rank.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/TRC#fd5728d9-8e89-4a4d-8871-f05eef691a93 in Thesaurus::Rank.")
      #expect(actual_tc.is_ranked).to eq(actual_rank.uri)
    end

  end

end
