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
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")     
    end

    after :all do
      delete_all_public_test_files
    end

    def item_to_ttl(item)
      uri = item.has_identifier.has_scope.uri
      item.has_identifier.has_scope = uri
      uri = item.has_state.by_authority.uri
      item.has_state.by_authority = uri
      item.to_ttl
    end

    it "create Objective" do
      objective = Objective.create(identifier: "OBJ1", label: "Objective 1")
      objective = Objective.find_minimum(objective.uri)
      iso_concept = Intervention.new()
      parameter1 = Parameter.create(label: "Intervention", parameter_rdf_type: iso_concept.rdf_type )
      objective.has_parameter = [parameter1]
      enumerated = Enumerated.create(label: "Primary")
      objective.objective_type = enumerated
      endpoint1 = Endpoint.create(label: "Endpoint1", full_text: "")
      objective.is_assessed_by = [endpoint1]
      objective.full_text = "To show the contribution of [[[Intervention]]] to the clinical and parasiticidal effect of <interventionA/interventionB> 
      combination by analyzing exposure-response of <interventionA> measured by <Timepoint> <Param>for the effect and the area under the concentration time curve up to infinity (AUC) of <interventionA> as PK predictor"
      objective.save
      full_path = item_to_ttl(objective)
      full_path = objective.to_ttl
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "Objective.ttl")
    end
  
  end

end