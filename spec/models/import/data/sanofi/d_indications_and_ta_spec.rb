require 'rails_helper'

describe "D - Indications and Therapeutic Areas" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/sanofi"
  end

  before :all do
    IsoHelpers.clear_cache
    clear_triple_store    
    load_local_file_into_triple_store(sub_dir, "sanofi_protocol_base_2.nq.gz")
    test_query # Make sure any loading has finished.
    load_schema_file_into_triple_store("protocol.ttl")
    load_schema_file_into_triple_store("enumerated.ttl")
    load_schema
  end

  after :all do
    #
  end

  before :each do
    #
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Indications and Therapeutic Areas" do

    it "Indications" do
      load_local_file_into_triple_store(sub_dir, "c_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "c_objectives.ttl")

      obj1 = Objective.where(label: "Objective 1").first
      obj2 = Objective.where(label: "Objective 2").first
      obj3 = Objective.where(label: "Objective 3").first
      obj4 = Objective.where(label: "Objective 4").first
      obj5 = Objective.where(label: "Objective 5").first
      obj6 = Objective.where(label: "Objective 6").first
      obj7 = Objective.where(label: "Objective 7").first
      obj8 = Objective.where(label: "Objective 8").first
      obj9 = Objective.where(label: "Objective 9").first

      # Indications
      indications = []
      cl = Thesaurus::ManagedConcept.where(identifier: "NP000023P")
      cl = Thesaurus::ManagedConcept.find_full(cl.first.uri)
      ind_data = [ 
        { name: "ALZHEIMER'S DISEASE", objectives: [obj1.uri, obj3.uri, obj4.uri, obj5.uri, obj6.uri] }, 
        { name: "DIABETES MELLITUS", objectives: [obj7.uri, obj8.uri, obj9.uri] },  
        { name: "TYPE 2 DIABETES MELLITUS", objectives: [obj7.uri, obj8.uri, obj9.uri] },  
        { name: "TYPE 1 DIABETES MELLITUS",  objectives: [obj7.uri, obj8.uri, obj9.uri] }, 
        { name: "RHEUMATOID ARTHRITIS",  objectives: [obj2.uri, obj7.uri] }, 
        { name: "INFLUENZA", objectives: [obj2.uri, obj7.uri] }
      ]
      ind_data.each_with_index do |ind_hash, index|
        tc = cl.narrower.find{|x| x.notation == ind_hash[:name]}
        op_ref = OperationalReferenceV3::TucReference.new(context: cl.uri, reference: tc.uri, optional: false, ordinal: index+1)
        ind = Indication.new(label: tc.preferred_term.label, indication: op_ref, has_objective: ind_hash[:objectives])
        ind.set_initial("IND #{tc.notation}")
        indications << ind
      end

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(indications.first.uri.namespace)
      indications.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "d_indications.ttl")
    end

    it "Therapeutic Areas" do
      load_local_file_into_triple_store(sub_dir, "d_indications.ttl")

      # TAs
      i_1 = Indication.where(label: "Alzheimer's Disease")
      ta_1 = TherapeuticArea.new(label: "Nervous system disorders", includes_indication: [i_1.first.uri])
      ta_1.set_initial("TA NSD")
      i_2a = Indication.where(label: "Diabetes Mellitus")
      i_2b = Indication.where(label: "Type 1 Diabetes Mellitus")
      i_2c = Indication.where(label: "Type 2 Diabetes Mellitus")
      ta_2 = TherapeuticArea.new(label: "Metabolic", includes_indication: [i_2a.first.uri, i_2b.first.uri, i_2c.first.uri])
      ta_2.set_initial("TA M")
      i_3 = Indication.where(label: "Rheumatoid Arthritis")
      ta_3 = TherapeuticArea.new(label: "Inflammation", includes_indication: [i_3.first.uri])
      ta_3.set_initial("TA I")
      i_4 = Indication.where(label: "Influenza")
      ta_4 = TherapeuticArea.new(label: "Vaccines", includes_indication: [i_4.first.uri])
      ta_4.set_initial("TA V")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(ta_1.uri.namespace)
      ta_1.to_sparql(sparql, true)
      ta_2.to_sparql(sparql, true)
      ta_3.to_sparql(sparql, true)
      ta_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "d_therapeutic_areas.ttl")
    end

  end

end
