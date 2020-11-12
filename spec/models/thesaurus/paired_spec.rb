require 'rails_helper'

describe "Thesaurus::Paired" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/paired"
  end

  def create_mc(notation)
    result = Thesaurus::ManagedConcept.create
    result.notation = notation
    result.save
    result
  end

  describe "paired" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "checks valid pairing, valid combinations" do
      tc_1 = create_mc("AATESTCD")
      tc_2 = create_mc("AATEST")
      expect(tc_1.valid_pairing?(tc_2)).to eq(true)
      tc_1 = create_mc("AATSCD")
      tc_2 = create_mc("AATS")
      expect(tc_1.valid_pairing?(tc_2)).to eq(true)
      tc_1 = create_mc("AATC")
      tc_2 = create_mc("AATN")
      expect(tc_1.valid_pairing?(tc_2)).to eq(true)
      tc_1 = create_mc("AAPARMCD")
      tc_2 = create_mc("AAPARM")
      expect(tc_1.valid_pairing?(tc_2)).to eq(true)
    end

    it "checks valid pairing, invalid combinations" do
      tc_1 = create_mc("AXTESTCD")
      tc_2 = create_mc("AATEST")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, mismatch in name AX versus AA. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
      tc_1 = create_mc("AATESTCD")
      tc_2 = create_mc("AATESTX")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, trying to pair AATESTCD with AATESTX. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
      tc_1 = create_mc("AATCD")
      tc_2 = create_mc("AATS")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, trying to pair AATCD with AATS. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
      tc_1 = create_mc("AATC")
      tc_2 = create_mc("AATH")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, trying to pair AATC with AATH. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
      tc_1 = create_mc("AATC")
      tc_2 = create_mc("AAT")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, trying to pair AATC with AAT. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
      tc_1 = create_mc("ASPARMCD")
      tc_2 = create_mc("AAPARM")
      expect(tc_1.valid_pairing?(tc_2)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, mismatch in name AS versus AA. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM).")
    end

    it "validate and pairs" do
      tc_1 = create_mc("EGTESTCD")
      tc_2 = create_mc("EGTEST")
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(true)
      tc_1 = create_mc("EGxTESTCD")
      tc_2 = create_mc("EGTEST")
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, mismatch in name EGx versus EG. Valid pairs are (--TESTCD, --TEST), (--TSCD, --TS), (--TC, --TN), (--PARMCD, --PARM). and Pairing not permitted, trying to pair EGxTESTCD with EGTEST.")
    end

    it "validate and pairs, already paired" do
      tc_1 = create_mc("EGTESTCD")
      tc_2 = create_mc("EGTEST")
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(true)
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, already paired.")
    end

    it "validate and unpair" do
      tc_1 = create_mc("EGTESTCD")
      tc_2 = create_mc("EGTEST")
      expect(tc_1.validate_and_unpair).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Cannot unpair as the item is not paired.")
      tc_1.errors.clear
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(true)
      tc_1.errors.clear
      expect(tc_1.validate_and_pair(tc_2.id)).to eq(false)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, already paired.")
      tc_1.errors.clear
      expect(tc_1.validate_and_unpair).to eq(true)
    end

    it "already paired" do
      tc_1 = create_mc("EGTESTCD")
      tc_2 = create_mc("EGTEST")
      tc_1.validate_and_pair(tc_2.id)
      expect(tc_1.already_paired?).to eq(true)
      expect(tc_1.errors.full_messages.to_sentence).to eq("Pairing not permitted, already paired.")
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
