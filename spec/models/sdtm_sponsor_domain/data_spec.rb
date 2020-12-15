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

    it "create Sponsor Domain II" do
      domain = SdtmIgDomain.find_full(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_AE/V1#IGD"))
      sponsor_domain = SdtmSponsorDomain.create(label: "SDTM Sponsor Domain", identifier: "AAA", ordinal: 1, prefix: domain.prefix)
      sponsor_domain.structure = domain.structure
      sponsor_domain.based_on_class = domain.based_on_class
      sponsor_columns = []
      domain.includes_column.sort_by {|x| x.ordinal}.each do |dv|
        sponsor_columns << SdtmSponsorDomain::Var.create(parent_uri:sponsor_domain.uri, label: dv.label, ordinal: dv.ordinal, description: dv.description, name: dv.name, based_on_ig_variable: dv.uri, used: true,
        format: dv.format, ct_and_format: dv.ct_and_format, compliance: dv.compliance.uri, ct_reference: dv.ct_reference)
      end
      sponsor_domain.includes_column = sponsor_columns
      sponsor_domain.save
      sponsor_domain = SdtmSponsorDomain.find_full(sponsor_domain.uri)
      full_path = sdtm_to_ttl(sponsor_domain)
      full_path = sponsor_domain.to_ttl
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "SDTM_Sponsor_Domain.ttl")
    end
  
  end

end