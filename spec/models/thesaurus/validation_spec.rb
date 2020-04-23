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
      expect(child.errors.full_messages.to_sentence).to eq("Duplicate submission value 'OTHER EVENT'")
      pt = Thesaurus::PreferredTerm.new(label: "Protocol Milestone")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT1", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(false)
      expect(child.errors.full_messages.to_sentence).to eq("Duplicate preferred term 'Protocol Milestone'")
      child = Thesaurus::UnmanagedConcept.new(notation: "OTHER EVENT", preferred_term: pt)
      result = item.valid_child?(child)
      expect(result).to eq(false)
      expect(child.errors.full_messages.to_sentence).to eq("Duplicate submission value 'OTHER EVENT' and Duplicate preferred term 'Protocol Milestone'")
    end

  end

end
