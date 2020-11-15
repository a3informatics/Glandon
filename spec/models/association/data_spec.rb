require 'rails_helper'

describe Association do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/association/data"
  end

  describe "create data" do

    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
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

    it "create data, HEIGHT and WEIGHT BC" do
      association = Association.new()
      association.uri = association.create_uri(Uri.new(uri: "http://www.example.com/path#a")) 
      bc = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_VS/V4#IGD"))
      association.the_subject = bc
      association.associated_with = [sdtm_ig_domain]
      association.semantic = "BC SDTM Association"
      results = []
      results << association
      association2 = Association.new()
      association2.uri = association2.create_uri(Uri.new(uri: "http://www.example.com/path#b")) 
      bc2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      sdtm_ig_domain = SdtmIgDomain.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG_VS/V4#IGD"))
      association2.the_subject = bc2
      association2.associated_with = [sdtm_ig_domain]
      association2.semantic = "BC SDTM Association"
      results << association2
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "association.ttl")
  	end

  end

end