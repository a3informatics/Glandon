require 'rails_helper'

describe Objective do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/objective/data"
  end

  describe "Create Objective" do
    
    before :all do
      data_files = ["endpoints.ttl", "parameter.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_4.ttl")          
    end

    after :all do
      delete_all_public_test_files
    end

    it "Objectives" do

      enum_p = IsoConceptSystem::Node.where(pref_label: "Primary").first
      enum_s = IsoConceptSystem::Node.where(pref_label: "Secondary").first
      enum_t = IsoConceptSystem::Node.where(pref_label: "Tertiary").first
      enum_ns = IsoConceptSystem::Node.where(pref_label: "Not set").first

      ep1 = Endpoint.where(label: "Endpoint 1").first
      ep2 = Endpoint.where(label: "Endpoint 2").first
      ep3 = Endpoint.where(label: "Endpoint 3").first
      ep4 = Endpoint.where(label: "Endpoint 4").first

      objectives =
      [
        {
          label: "Objective 1",
          full_text: "To show the contribution of [[[Intervention]]] to the clinical and parasiticidal effect of [[[Intervention]]] combination by analyzing exposure-response of [[[Intervention]]] measured by [[[Timepoint]]] for the effect and the area under the concentration time curve up to infinity (AUC) of [[[Intervention]]] as PK predictor",
          objective_type: enum_p.uri,
          is_assessed_by: [ep1.uri, ep2.uri]
        },
        {
          label: "Objective 2",
          full_text: "To evaluate the dose response of [[[Intervention]]] combined with [[[Intervention]]] on <Param1> and <Param2> at [[[Timepoint]]]",
          objective_type: enum_s.uri,
          is_assessed_by: [ep1.uri]
        },
        {
          label: "Objective 3",
          full_text: "To evaluate the dose-response of [[[Intervention]]] combined with [[[Intervention]]] on selected secondary endpoints",
          objective_type: enum_s.uri,
          is_assessed_by: [ep1.uri]
        },
        {
          label: "Objective 4",
          full_text: "To evaluate the safety and tolerability of different dosages of [[[Intervention]]] in combination with [[[Intervention]]] and [[[Intervention]]] alone",
          objective_type: enum_s.uri,
          is_assessed_by: [ep1.uri, ep2.uri, ep4.uri]
        }
      ]
      items = []
      objectives.each_with_index do |ep, index|
        item = Objective.new(ep)
        item.set_initial("OBJ #{index+1}")
        items << item
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(items.first.uri.namespace)
      items.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "objectives.ttl")
    end
  
  end

end