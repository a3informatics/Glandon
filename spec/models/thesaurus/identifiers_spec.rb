require 'rails_helper'

describe Thesaurus::Identifiers do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/changes"
  end

  describe Thesaurus::Identifiers do

    before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
    end

    before :each do
      NameValue.destroy_all
    end

    after :each do
      NameValue.destroy_all
    end

    it "new identifier, parent" do
      NameValue.create(name: "thesaurus_parent_identifier", value: "10")
      local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      result = mc.new_identifier
      expect(result).to eq("NX000010AA")
    end

    it "new identifier, child" do
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
      local_configuration = {scheme_type: :flat, child: {generated: {pattern: "NXDD[identifier]", width: "8"}}}
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::UnmanagedConcept.new
      result = mc.new_identifier
      expect(result).to eq("NXDD00000999")
    end

    it "new identifier, not configured, exception" do
      local_configuration = {scheme_type: :flat, parent: {as_entered: true}, child: {as_entered: true}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      expect{mc.new_identifier}.to raise_error(Errors::ApplicationLogicError, "Request to generate identifier when not configured.")
      local_configuration = {scheme_type: :flat, child: {as_entered: true}}
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::UnmanagedConcept.new
      expect{mc.new_identifier}.to raise_error(Errors::ApplicationLogicError, "Request to generate identifier when not configured.")
    end

    it "generated identifier, false" do
      local_configuration = {scheme_type: :flat, parent: {as_entered: true}, child: {as_entered: true}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      expect(mc.generated_identifier?).to eq(false)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::UnmanagedConcept.new
      expect(mc.generated_identifier?).to eq(false)
    end

    it "generated identifier, false" do
      local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}, child: {generated: {pattern: "YY[identifier]", width: "4"}}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      expect(mc.generated_identifier?).to eq(true)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::UnmanagedConcept.new
      expect(mc.generated_identifier?).to eq(true)
    end

    it "identifier scheme, flat" do
      local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      expect(mc.identifier_scheme).to eq(:flat)
    end

    it "identifier scheme, hierarchical" do
      local_configuration = {scheme_type: :hierarchical, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      mc = Thesaurus::ManagedConcept.new
      expect(mc.identifier_scheme).to eq(:hierarchical)
    end

  end

end
