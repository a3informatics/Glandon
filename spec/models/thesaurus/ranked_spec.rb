require 'rails_helper'

describe "Thesaurus::Ranked" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/ranked"
  end

  describe "schema load" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "check ranked" do
      tc = Thesaurus::ManagedConcept.create
      other = Thesaurus::ManagedConcept.find(tc.uri)
      expect(other.ranked?).to eq(false)
      tc.is_ranked = Uri.new(uri: "http://www.example.com/A/B#C")
      tc.save
      other = Thesaurus::ManagedConcept.find(tc.uri)
      expect(other.ranked?).to eq(true)
      tc.is_ranked = nil
      tc.save
      other = Thesaurus::ManagedConcept.find(tc.uri)
      expect(other.ranked?).to eq(false)
    end

  end

end
