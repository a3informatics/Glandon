require 'rails_helper'

describe IsoManagedV2::Associations do

  include DataHelpers
  include IsoManagedHelpers
  include SdtmSponsorDomainFactory
  include BiomedicalConceptInstanceFactory

  def sub_dir
    return "models/iso_managed_v2/associations"
  end

  describe "Associate tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "associate, new association, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      association = domain.associate([bc_1.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "associate_expected_1.yaml", equate_method: :hash_equal)
    end

    it "associate, existing association, multiple BCs" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("BMI", "BMI")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      association = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "associate_expected_2.yaml", equate_method: :hash_equal)
    end

    it "associate, new association, multiple BCs II" do
      allow(SecureRandom).to receive(:uuid).and_return("4646b47a-4ae4-4f21-b5e2-565815c8cded") #Needed to get a new Association URI
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain", "BB")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      association = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "associate_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Diassociate tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "diassociate, single BC, error" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      result = domain.diassociate([bc_1.id])
      expect(result.errors.full_messages.to_sentence).to eq("Failed to find association")
    end

    it "diassociate, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      association = domain.associate([bc_1.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_1a.yaml", equate_method: :hash_equal)
      association = domain.diassociate([bc_1.id])
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_1b.yaml", equate_method: :hash_equal)
    end

    it "diassociate, multiple BC" do
      allow(SecureRandom).to receive(:uuid).and_return("4646b47a-4ae4-4f21-b5e2-565815c8cded") #Needed to get a new Association URI
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain", "BB")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      association = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_2a.yaml", equate_method: :hash_equal)
      association = domain.diassociate([bc_1.id])
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_2b.yaml", equate_method: :hash_equal)
    end

    it "diassociate, multiple BC" do
      allow(SecureRandom).to receive(:uuid).and_return("92bf8b74-ec78-4348-9a1b-154a6ccb9b9f") #Needed to get a new Association URI
      domain = create_sdtm_sponsor_domain("CCC", "SDTM Sponsor Domain", "CC")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      association = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_3a.yaml", equate_method: :hash_equal)
      association = domain.diassociate([bc_1.id, bc_2.id])
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_expected_3b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Diassociate all tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "diassociate all, single BC, error" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      result = domain.diassociate_all
      expect(result.errors.full_messages.to_sentence).to eq("Failed to find association")
    end

    it "diassociate all, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      association = domain.associate([bc_1.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_all_expected_1a.yaml", equate_method: :hash_equal)
      result = domain.diassociate_all
      expect{Association.find(association.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/ASSOC#1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Association.")
    end

    it "diassociate all, multiple BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      association = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      association = Association.find(association.id)
      check_file_actual_expected(association.to_h, sub_dir, "diassociate_all_expected_2a.yaml", equate_method: :hash_equal)
      association = Association.find(association.uri)
      result = domain.diassociate_all
      expect{Association.find(association.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/ASSOC#1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Association.")
    end

  end

  describe "Association? tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "association?, false" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      expect(domain.association?).to eq(false)
    end

    it "association?, true" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      expect(domain.association?).to eq(true)
    end

  end

  describe "Associated tests" do

    before :each do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "associated, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      domain.associate([bc_1.id], "SDTM BC Association")
      check_file_actual_expected(domain.associated, sub_dir, "associated_expected_1.yaml", equate_method: :hash_equal)
    end

    it "associate, multiple BCs" do
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain2", "BB")
      bc_1 = create_biomedical_concept_instance("HEIGHT", "Height")
      bc_2 = create_biomedical_concept_instance("WEIGHT", "Weight")
      bc_3 = create_biomedical_concept_instance("BMI", "BMI")
      domain.associate([bc_1.id, bc_2.id, bc_3.id], "SDTM BC Association")
      check_file_actual_expected(domain.associated, sub_dir, "associated_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end