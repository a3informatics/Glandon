require 'rails_helper'

describe "Thesaurus::Validation" do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/validation"
  end

  describe Thesaurus::Identifiers do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
    end

    after :all do
    end

    before :each do
    end

    after :each do
    end

    it "valid child" do
      item = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74558/V8#C74558"))
      pt = Thesaurus::PreferredTerm.new(label: "Not a sub set")
      child = Thesaurus::UnmanagedConcept.new(notation: "XXX", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(true)
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(false)
      expect(child.errors.full_messages.to_sentence).to eq("Notation duplicate detected 'OTHER EVENT'")
      pt = Thesaurus::PreferredTerm.new(label: "Protocol Milestone")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT1", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(false)
      expect(child.errors.full_messages.to_sentence).to eq("Preferred term duplicate detected 'Protocol Milestone'")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(false)
      expect(child.errors.full_messages.to_sentence).to eq("Notation duplicate detected 'OTHER EVENT' and Preferred term duplicate detected 'Protocol Milestone'")
    end

    it "valid children" do
      item = Thesaurus::ManagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C74558/V8#C74558"))
      item.narrower.each{|x| x.preferred_term_objects}
      result = item.valid_children?
      expect(result).to eq(true)

      item.errors.clear
      pt = Thesaurus::PreferredTerm.new(label: "Not a sub set 1")
      child = Thesaurus::UnmanagedConcept.new(notation: "XXX", preferred_term: pt)
      item.narrower << child
      result = item.valid_children?
      expect(result).to eq(true)

      item.errors.clear
      pt = Thesaurus::PreferredTerm.new(label: "Not a sub set 2")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT", preferred_term: pt)
      item.narrower << child
      result = item.valid_children?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Notation duplicates detected 'OTHER EVENT'")

      item.errors.clear
      pt = Thesaurus::PreferredTerm.new(label: "Protocol Milestone")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT1", preferred_term: pt)
      item.narrower << child
      result = item.valid_children?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Notation duplicates detected 'OTHER EVENT' and Preferred term duplicates detected 'Protocol Milestone'")

      item.errors.clear
      pt = Thesaurus::PreferredTerm.new(label: "Protocol Milestone 1")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT", preferred_term: pt)
      item.narrower << child
      result = item.valid_children?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Notation duplicates detected 'OTHER EVENT' and Preferred term duplicates detected 'Protocol Milestone'")
    end

  end

end
