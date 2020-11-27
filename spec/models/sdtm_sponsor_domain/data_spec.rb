require 'rails_helper'

describe SdtmSponsorDomain do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/sdtm_sponsor_domain/data"
  end

  describe "Create SDTD Sponsor Domain" do
    
    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      #load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      #load_data_file_into_triple_store("association.ttl")      
    end

    after :all do
      delete_all_public_test_files
    end

    def sdtm_to_ttl(sponsor)
      uri = sponsor.has_identifier.has_scope.uri
      sponsor.has_identifier.has_scope = uri
      uri = sponsor.has_state.by_authority.uri
      sponsor.has_state.by_authority = uri
      sponsor.to_ttl
    end

    it "create Sponsor Domain" do
      domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      sp = SdtmSponsorDomain.create(label: "SDTM Sp", identifier: "AAA")
      sp.includes_column = domain.includes_column
      sp.save
      #sp = SdtmSponsorDomain.from_h(domain.to_h)
      #bd:prefix "CO"^^xsd:string ;
      #bd:structure "One record per comment per subject"^^xsd:string ;
      #bd:basedOnClass <http://www.cdisc.org/SDTM_MODEL_CO/V6#CL> ;
      sponsor = SdtmSponsorDomain.find_full(sp.uri)
      full_path = sdtm_to_ttl(sponsor)
      full_path = sponsor.to_ttl
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "SDTM_Sponsor_Domain.ttl")
    end
  end



end