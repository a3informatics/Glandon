require 'rails_helper'

describe Association do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/association/data"
  end

  describe "create data" do

    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl", "SDTM_Sponsor_Domain.ttl" ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")      
    end

    after :all do
      delete_all_public_test_files
    end

    it "create data, IG Domain, HEIGHT and WEIGHT BCs" do
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_VS/V4#IGD"))
      bc = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      association = Association.create({semantic: "BC SDTM Association"}, sdtm_ig_domain)
      association.the_subject = sdtm_ig_domain
      association.associated_with = [bc, bc2]
      results = []
      results << association
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "association_IG_domain.ttl")
    end

    it "create data, Sponsor Domain, HEIGHT and WEIGHT BCs" do
      sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AAA/V1#SPD"))
      bc = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bc2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      association = Association.create({semantic: "BC SDTM Association"}, sdtm_sponsor_domain)
      association.the_subject = sdtm_sponsor_domain
      association.associated_with = [bc, bc2]
      results = []
      results << association
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "association.ttl")
    end

  end

end