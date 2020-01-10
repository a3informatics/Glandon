require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/import/data/base/cs"
  end

  describe "Baseline Create Tags" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "Baseline Tags" do
      cs = IsoConceptSystem.root
      cdisc = cs.add({label: "CDISC", description: "CDISC related tags"})
      sdtm = cdisc.add({label: "SDTM", description: "SDTM related information."})
      cdash = cdisc.add({label: "CDASH", description: "CDASH related information."})
      adam = cdisc.add({label: "ADaM", description: "ADaM related information."})
      send = cdisc.add({label: "SEND", description: "SEND related information."})
      protocol = cdisc.add({label: "Protocol", description: "Protocol related information."})
      qs = cdisc.add({label: "QS", description: "Questionnaire related information."})
      qs_ft = cdisc.add({label: "QS-FT", description: "Questionnaire and Functional Test related information."})
      coa = cdisc.add({label: "COA", description: "Clinical Outcome Assessent related information."})
      qrs = cdisc.add({label: "QRS", description: "Questionnaire and Rating Scale related information."})

      cs.is_top_concept_objects
      cdisc.narrower_objects

      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      cs.to_sparql(sparql, true)
      cdisc.to_sparql(sparql, true)
      cdisc.narrower.each {|x| x.to_sparql(sparql, true)}
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems.ttl")
    end

  end

  describe "Migration One" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "migration 1, add define.xml" do
      cs = IsoConceptSystem.root
      cdisc = IsoConceptSystem.path(["CDISC"])
      define = cdisc.add({label: "Define-XML", description: "Define.xml related information."})
      
      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      define.to_sparql(sparql, true)
      sparql.add({uri: cdisc.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:isoC), :fragment => "narrower"}, {uri: define.uri})
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_iso_concept_systems_migration_1.ttl")
    end

  end

end