require 'rails_helper'

describe Indication do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/indication/data"
  end

  describe "Create Indication" do
    
    before :all do
      data_files = ["objectives.ttl", "hackathon_thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "Indications" do

      obj1 = Objective.where(label: "Objective 1").first
      obj2 = Objective.where(label: "Objective 2").first
      obj3 = Objective.where(label: "Objective 3").first
      obj4 = Objective.where(label: "Objective 4").first

      # Indications
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CT/V1#TH"))
      tc_1 = Thesaurus::UnmanagedConcept.where(notation: "AD")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_1.first.uri, optional: false, ordinal: 1)
      i_1 = Indication.new(label: "Alzheimer's Disease", indication: op_ref, has_objective: [obj1.uri, obj3.uri, obj4.uri])
      i_1.set_initial("IND ALZ")
      tc_2 = Thesaurus::UnmanagedConcept.where(notation: "DMelli")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_2.first.uri, optional: false, ordinal: 1)
      i_2 = Indication.new(label: "Diabetes Mellitus", indication: op_ref, has_objective: [obj2.uri])
      i_2.set_initial("IND DIA")
      tc_3 = Thesaurus::UnmanagedConcept.where(notation: "RArth")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_3.first.uri, optional: false, ordinal: 1)
      i_3 = Indication.new(label: "Rheumatoid Arthritis", indication: op_ref, has_objective: [obj1.uri, obj2.uri])
      i_3.set_initial("IND RA")
      tc_4 = Thesaurus::UnmanagedConcept.where(notation: "INF")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_4.first.uri, optional: false, ordinal: 1)
      i_4 = Indication.new(label: "Influenza", indication: op_ref, has_objective: [obj1.uri, obj2.uri, obj3.uri])
      i_4.set_initial("IND INF")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(i_1.uri.namespace)
      i_1.to_sparql(sparql, true)
      i_2.to_sparql(sparql, true)
      i_3.to_sparql(sparql, true)
      i_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "indications.ttl")
    end
  
  end

end