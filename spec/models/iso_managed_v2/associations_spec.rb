require 'rails_helper'

describe IsoManagedV2::Associations do

  include DataHelpers
  include PublicFileHelpers
  include SdtmSponsorDomainFactory

  def sub_dir
    return "models/iso_managed_v2/associations"
  end

  describe "Basic tests" do

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
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "associate, mutliple BCs" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_2.yaml", equate_method: :hash_equal, write_file: true)
    end


    it "associate, mutliple BCs II" do
      domain = create_sdtm_sponsor_domain("BBB", "SDTM Sponsor Domain", "BB")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id, bc_2.id], "SDTM BC Association")
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_3.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end