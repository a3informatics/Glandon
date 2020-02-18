require 'rails_helper'

describe "Thesaurus::Identifiers" do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/changes"
  end

  describe Thesaurus::Identifiers do

    before :all do
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
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      result = Thesaurus::ManagedConcept.new_identifier
      expect(result).to eq("NX000010AA")
    end

    it "new identifier, child" do
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
      local_configuration = {scheme_type: :flat, child: {generated: {pattern: "NXDD[identifier]", width: "8"}}}
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      result = Thesaurus::UnmanagedConcept.new_identifier
      expect(result).to eq("NXDD00000999")
    end

    it "new identifier, not configured, exception" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect{Thesaurus::ManagedConcept.new_identifier}.to raise_error(Errors::ApplicationLogicError, "Request to generate identifier when not configured.")
      local_configuration = {scheme_type: :flat, child: {as_entered: true}}
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect{Thesaurus::UnmanagedConcept.new_identifier}.to raise_error(Errors::ApplicationLogicError, "Request to generate identifier when not configured.")
    end

    it "generated identifier, false" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.generated_identifier?).to eq(false)
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::UnmanagedConcept.generated_identifier?).to eq(false)
    end

    it "generated identifier, false" do
      local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}, child: {generated: {pattern: "YY[identifier]", width: "4"}}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.generated_identifier?).to eq(true)
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::UnmanagedConcept.generated_identifier?).to eq(true)
    end

    it "identifier scheme, flat I" do
      local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.identifier_scheme).to eq(:flat)
    end

    it "identifier scheme, flat II" do
      local_configuration = {scheme_type: "flat", parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.identifier_scheme_flat?).to eq(true)
    end

    it "identifier scheme, hierarchical I" do
      local_configuration = {scheme_type: :hierarchical, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.identifier_scheme).to eq(:hierarchical)
    end

    it "identifier scheme, hierarchical II" do
      local_configuration = {scheme_type: "hierarchical", parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
      expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.identifier_scheme_flat?).to eq(false)
    end

  end

end
