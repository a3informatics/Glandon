require 'rails_helper'

describe "Thesaurus::Paired" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/paired"
  end

  describe "paired" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "checks paired" do
      tc_1 = Thesaurus::ManagedConcept.create
      tc_2 = Thesaurus::ManagedConcept.create
      expect(tc_1.paired?).to eq(false)
      expect(tc_2.paired?).to eq(false)
      tc_1.paired_with = tc_2.uri
      tc_1.save
      tc_1 = Thesaurus::ManagedConcept.find(tc_1.uri)
      tc_2 = Thesaurus::ManagedConcept.find(tc_2.uri)
      expect(tc_1.paired?).to eq(true)
      expect(tc_2.paired?).to eq(true)
      tc_1.paired_with = nil
      tc_1.save
      tc_1 = Thesaurus::ManagedConcept.find(tc_1.uri)
      tc_2 = Thesaurus::ManagedConcept.find(tc_2.uri)
      expect(tc_1.paired?).to eq(false)
      expect(tc_2.paired?).to eq(false)
    end

    it "checks paired, parent and child" do
      tc_1 = Thesaurus::ManagedConcept.create
      tc_2 = Thesaurus::ManagedConcept.create
      expect(tc_1.paired_as_parent?).to eq(false)
      expect(tc_1.paired_as_child?).to eq(false)
      expect(tc_2.paired_as_child?).to eq(false)
      expect(tc_2.paired_as_parent?).to eq(false)
      tc_1.paired_with = tc_2.uri
      tc_1.save
      tc_1 = Thesaurus::ManagedConcept.find(tc_1.uri)
      tc_2 = Thesaurus::ManagedConcept.find(tc_2.uri)
      expect(tc_1.paired_as_parent?).to eq(true)
      expect(tc_1.paired_as_child?).to eq(false)
      expect(tc_2.paired_as_child?).to eq(true)
      expect(tc_2.paired_as_parent?).to eq(false)
      tc_1.paired_with = nil
      tc_1.save
      tc_1 = Thesaurus::ManagedConcept.find(tc_1.uri)
      tc_2 = Thesaurus::ManagedConcept.find(tc_2.uri)
      expect(tc_1.paired_as_parent?).to eq(false)
      expect(tc_1.paired_as_child?).to eq(false)
      expect(tc_2.paired_as_child?).to eq(false)
      expect(tc_2.paired_as_parent?).to eq(false)
    end

    it "pairs concepts, uri" do
      tc = Thesaurus::ManagedConcept.create
      uri = Uri.new(uri: "http://www.example.com/A/B#C")
      tc.pair(uri)
      result = Thesaurus::ManagedConcept.find(tc.uri)
      expect(result.paired?).to eq(true)
      expect(result.paired_with).to eq(uri)
    end

    it "pairs concepts, id" do
      tc = Thesaurus::ManagedConcept.create
      uri = Uri.new(uri: "http://www.example.com/A/B#C")
      tc.pair(uri.to_id)
      result = Thesaurus::ManagedConcept.find(tc.uri)
      expect(result.paired?).to eq(true)
      expect(result.paired_with).to eq(uri)
    end

    it "unpair concept" do
      tc = Thesaurus::ManagedConcept.create
      tc.paired_with = Uri.new(uri: "http://www.example.com/A/B#C")
      tc.save
      tc.unpair
      result = Thesaurus::ManagedConcept.find(tc.uri)
      expect(result.paired?).to eq(false)
      expect(result.paired_with).to eq(nil)
    end

    it "finds the other of the pair" do
      tc_1 = Thesaurus::ManagedConcept.create
      tc_2 = Thesaurus::ManagedConcept.create
      tc_1.pair(tc_2.uri)
      tc_1 = Thesaurus::ManagedConcept.find(tc_1.uri)
      tc_2 = Thesaurus::ManagedConcept.find(tc_2.uri)
      expect(tc_1.paired?).to eq(true)
      expect(tc_1.other_pair.uri).to eq(tc_2.uri)
      expect(tc_2.other_pair.uri).to eq(tc_1.uri)
    end

  end

end
