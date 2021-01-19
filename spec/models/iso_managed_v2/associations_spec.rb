require 'rails_helper'

describe IsoManagedV2::Associations do

  include DataHelpers
  include PublicFileHelpers
  include SdtmSponsorDomainFactory

  def sub_dir
    return "models/iso_managed_v2/associations"
  end

  describe "Associate tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "associate, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_1.yaml", equate_method: :hash_equal)
    end

    it "associate, multiple BCs" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_2.yaml", equate_method: :hash_equal)
    end


    it "associate, mutliple BCs II" do
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain", "BB")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Diassociate tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "diassociate, single BC, error" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = domain.diassociate([bc_1.id])
      expect(result.errors.full_messages.to_sentence).to eq("Failed to find association")
    end

    it "diassociate, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_1a.yaml", equate_method: :hash_equal)
      result = domain.diassociate([bc_1.id])
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_1b.yaml", equate_method: :hash_equal)
    end

    it "diassociate, multiple BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_2a.yaml", equate_method: :hash_equal)
      result = domain.diassociate([bc_1.id])
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_2b.yaml", equate_method: :hash_equal)
    end

    it "diassociate, multiple BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_3a.yaml", equate_method: :hash_equal)
      result = domain.diassociate([bc_1.id, bc_2.id])
      check_file_actual_expected(result.to_h, sub_dir, "diassociate_expected_3b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Diassociate all tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "diassociate all, single BC, error" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = domain.diassociate_all
      expect(result.errors.full_messages.to_sentence).to eq("Failed to find association")
    end

    it "diassociate all, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      assoc = domain.associate([bc_1.id], "SDTM BC Association")
      check_file_actual_expected(assoc.to_h, sub_dir, "diassociate_all_expected_1a.yaml", equate_method: :hash_equal)
      result = domain.diassociate_all
      expect{Association.find(assoc.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/ASSOC#1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Association.")
    end

    it "diassociate all, multiple BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      assoc = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(assoc.to_h, sub_dir, "diassociate_all_expected_2a.yaml", equate_method: :hash_equal)
      assoc = Association.find(assoc.uri)
      result = domain.diassociate_all
      expect{Association.find(assoc.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/ASSOC#1760cbb1-a370-41f6-a3b3-493c1d9c2238 in Association.")
    end

  end

  describe "Association? tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
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
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      expect(domain.association?).to eq(true)
    end

  end

  describe "Associated tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    before :each do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "associated, single BC" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      assoc = domain.associate([bc_1.id], "SDTM BC Association")
      assoc = Association.find(assoc.uri)
      check_file_actual_expected(assoc.associated, sub_dir, "associated_expected_1.yaml", equate_method: :hash_equal)
    end

    it "associate, multiple BCs" do
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain", "BB")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bc_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      assoc = domain.associate([bc_1.id, bc_2.id, bc_3.id], "SDTM BC Association")
      assoc = Association.find(assoc.uri)
      check_file_actual_expected(assoc.associated, sub_dir, "associated_expected_2.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end