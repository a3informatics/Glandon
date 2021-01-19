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

    after :all do
      #
    end

    it "associate" do
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      result = domain.associate([bc_1.id])
      check_file_actual_expected(result.to_h, sub_dir, "associate_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end