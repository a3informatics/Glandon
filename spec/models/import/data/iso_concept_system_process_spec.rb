require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/import/data/base/cs"
  end

  describe "Create Process Tags" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "creates process tags" do
      cs = IsoConceptSystem.root
      process = cs.add({label: "Process", description: "Process related tags"})
      stage = process.add({label: "Stage", description: "Stage related tags"})
      dc = stage.add({label: "DC Stage", description: "Data capture stage"})
      sdtm = stage.add({label: "SDTM Stage", description: "SDTM stage"})
      adam = stage.add({label: "ADaM Stage", description: "ADaM stage"})

      process.narrower_objects
      stage.narrower_objects

      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      sparql.add({uri: cs.uri}, {prefix: :isoC, fragment: "isTopConcept"}, {uri: process.uri})
      process.to_sparql(sparql, true)
      stage.to_sparql(sparql, true)
      stage.narrower.each {|x| x.to_sparql(sparql, true)}
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems_process.ttl")
    end

  end

end