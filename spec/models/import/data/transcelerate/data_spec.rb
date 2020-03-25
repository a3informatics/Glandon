require 'rails_helper'

describe "Transcelerate Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/transcelerate"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
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

  describe "Terminology" do

    it "Terminology" do
      @th_1 = Thesaurus.new
      @th_1.label = "Thesaurus Hackathon"
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "Indication",
          identifier: "H000001",
          definition: "An indication",
          notation: "IND"
        })
      @tc_1.preferred_term = Thesaurus::PreferredTerm.new(label:"Indication")
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "Alzheimer's Disease",
          identifier: "HI000011",
          definition: "The Alzheimer's Disease",
          notation: "AD"
        })
      @tc_1a.preferred_term = Thesaurus::PreferredTerm.new(label:"Alzheimer's Disease")
      @tc_1b = Thesaurus::UnmanagedConcept.from_h({
          label: "Diabetes Mellitus",
          identifier: "HI000012",
          definition: "The Diabetes Mellitus",
          notation: "DMelli"
        })
      @tc_1b.preferred_term = Thesaurus::PreferredTerm.new(label:"Diabetes Mellitus")
      @tc_1c = Thesaurus::UnmanagedConcept.from_h({
          label: "Rheumatoid Arthritis",
          identifier: "HI000013",
          definition: "The Rheumatoid Arthritis",
          notation: "RArth"
        })
      @tc_1c.preferred_term = Thesaurus::PreferredTerm.new(label:"Rheumatoid Arthritis")
      @tc_1d = Thesaurus::UnmanagedConcept.from_h({
          label: "Influenza",
          identifier: "HI000014",
          definition: "The Influenza",
          notation: "INF"
        })
      @tc_1d.preferred_term = Thesaurus::PreferredTerm.new(label:"Influenza")
      @tc_1.narrower << @tc_1a
      @tc_1.narrower << @tc_1b
      @tc_1.narrower << @tc_1c 
      @tc_1.narrower << @tc_1d 
      @tc_1.set_initial(@tc_1.identifier)
      @th_1.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept << @tc_1.uri
      @th_1.set_initial("CT")
      sparql = Sparql::Update.new
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      @tc_1.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_thesaurus.ttl")
    end 

  end

  describe "MDR Data" do

    it "Indications" do
      load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")

      # Indications
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/CT/V1#TH"))
      tc_1 = Thesaurus::UnmanagedConcept.where(identifier: "HI000011")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_1.first.uri, optional: false, ordinal: 1)
      i_1 = Indication.new(label: "Alzheimer's Disease", indication: op_ref)
      i_1.set_initial("IND ALZ")
      tc_2 = Thesaurus::UnmanagedConcept.where(identifier: "HI000012")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_2.first.uri, optional: false, ordinal: 1)
      i_2 = Indication.new(label: "Diabetes Mellitus", indication: op_ref)
      i_2.set_initial("IND DIA")
      tc_3 = Thesaurus::UnmanagedConcept.where(identifier: "HI000013")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_3.first.uri, optional: false, ordinal: 1)
      i_3 = Indication.new(label: "Rheumatoid Arthritis", indication: op_ref)
      i_3.set_initial("IND RA")
      tc_4 = Thesaurus::UnmanagedConcept.where(identifier: "HI000014")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_4.first.uri, optional: false, ordinal: 1)
      i_4 = Indication.new(label: "Influenza", indication: op_ref)
      i_4.set_initial("IND INF")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(i_1.uri.namespace)
      i_1.to_sparql(sparql, true)
      i_2.to_sparql(sparql, true)
      i_3.to_sparql(sparql, true)
      i_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_indications.ttl")
    end

    it "Therapeutic Areas" do
      load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_indications.ttl")

      # TAs
      i_1 = Indication.where(label: "Alzheimer's Disease")
      ta_1 = TherapeuticArea.new(label: "Nervous system disorders", indication: i_1.first.uri)
      ta_1.set_initial("TA NSD")
      i_2 = Indication.where(label: "Diabetes Mellitus")
      ta_2 = TherapeuticArea.new(label: "Metabolic", indication: i_2.first.uri)
      ta_2.set_initial("TA M")
      i_3 = Indication.where(label: "Rheumatoid Arthritis")
      ta_3 = TherapeuticArea.new(label: "Inflammation", indication: i_3.first.uri)
      ta_3.set_initial("TA I")
      i_4 = Indication.where(label: "Influenza")
      ta_4 = TherapeuticArea.new(label: "Vaccines", indication: i_4.first.uri)
      ta_4.set_initial("TA V")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(ta_1.uri.namespace)
      ta_1.to_sparql(sparql, true)
      ta_2.to_sparql(sparql, true)
      ta_3.to_sparql(sparql, true)
      ta_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_tas.ttl")
    end

  end

end