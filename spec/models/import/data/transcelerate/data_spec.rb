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
    load_cdisc_term_versions(1..62)
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

  describe "Parameters" do

    it "Parameter" do
      uri = Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance")
      p_1 = Parameter.new(label: "BC", parameter_rdf_type: uri)
      p_1.uri = p_1.create_uri(p_1.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#Intervention")
      p_2 = Parameter.new(label: "Intervention", parameter_rdf_type: uri)
      p_2.uri = p_2.create_uri(p_2.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#TimepointOffset")
      p_3 = Parameter.new(label: "Timepoint", parameter_rdf_type: uri)
      p_3.uri = p_3.create_uri(p_3.class.base_uri)
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      p_1.to_sparql(sparql, true)
      p_2.to_sparql(sparql, true)
      p_3.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_parameters.ttl")
    end 

  end

  describe "MDR Data" do

    it "End Points" do
      endpoints = 
      [
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]] in the Alzheimer’s Disease Assessment Scale – Cognitive Assessment (ADAS-Cog) 14 total score"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to Week [[[Timepoint]]] in the Clinician’s Interview-Based Impression of Change plus caregiver input (CIBIC+)"
        },
        {
          label: "A label",         
          full_text: "The change [absolute] in HbA1c from baseline to [[[Timepoint]]]"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]] in the [[[BC]]]"
        },
        {
          label: "A label", 
          full_text: "The proportion of participants with adverse events, serious adverse events (SAEs), and adverse events leading to study intervention discontinuation over the [x-week] study intervention period"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]] in continuous laboratory tests: Hepatic Function Panel"
        },
        {
          label: "A label", 
          full_text: "The proportion of participants with abnormal (high or low) laboratory measures (urinalysis) during the postrandomization phase"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]] in ECG parameter: QTcF"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]] in the [[[BC]]]"
        },
        {
          label: "A label", 
          full_text: "The change from baseline to [[[Timepoint]]]] in the [[[BC]]]"
        }
      ]
      items = []
      endpoints.each_with_index do |ep, index|
        item = Endpoint.new(ep)
        item.set_initial("EP #{index+1}")
        items << item
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(items.first.uri.namespace)
      items.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_endpoints.ttl")
    end

    it "Objectives" do
      load_local_file_into_triple_store(sub_dir, "hackathon_endpoints.ttl")

      enum_p = Enumerated.new(label: "Primary")
      enum_p.create_uri(enum_p.class.base_uri)
      enum_s = Enumerated.new(label: "Secondary")
      enum_s.create_uri(enum_s.class.base_uri)
      enum_ns = Enumerated.new(label: "Not Set")
      enum_ns.create_uri(enum_ns.class.base_uri)

      objectives = 
      [
        { 
          label: "",
          full_text: "To assess the effect of [[[Intervention]]] on the ADAS-Cog and CIBIC+ scores at [[[Timepoint]]]] in participants with Mild to Moderate Alzheimer’s Disease",
          objective_type: enum_ns.uri,
          is_assessed_by: 
          [
            Uri.new(uri: "http://www.transceleratebiopharmainc.com/EP_1/V1#END"),
            Uri.new(uri: "http://www.transceleratebiopharmainc.com/EP_2/V1#END")
          ]
        },
        { 
          label: "",
          full_text: "To evaluate the efficacy of [[[Intervention]]] administered to individuals with Type 2 Diabetes Mellitus (T2DM)",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        },
        { 
          label: "",
          full_text: "To assess the dose-dependent improvement in behavior. Improved scores on the [[[BC]]] will indicate improvement in these areas",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        },
        { 
          label: "",
          full_text: "To document the safety profile of [[[Intervention]]].",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        },
        { 
          label: "",
          full_text: "To assess the effect of [[[Intervention]]] [vs. comparator X, if applicable] on the measure of behavioral/neuropsychiatric symptoms in participants with [severity] Alzheimer’s Disease",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        },
        { 
          label: "",
          full_text: "To assess the dose-dependent improvements in activities of daily living. Improved scores on the [assessment] will indicate improvement in these areas",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        } 
      ] 
    end

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
      ta_1 = TherapeuticArea.new(label: "Nervous system disorders", includes_indication: [i_1.first.uri])
      ta_1.set_initial("TA NSD")
      i_2 = Indication.where(label: "Diabetes Mellitus")
      ta_2 = TherapeuticArea.new(label: "Metabolic", includes_indication: [i_2.first.uri])
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
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_tas.ttl")
    end

    it "Protocol" do
      load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_indications.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_tas.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_endpoints.ttl")
      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))

      # Visits
      visits = 
      [
        {short_name: "BL", label: "Baseline"},
        {short_name: "Wk8", label: "Week 8"},
        {short_name: "Wk16", label: "Week 16"},
        {short_name: "Wk24", label: "Week 24"}
      ]
      v_items = []
      visits.each_with_index do |v, index|
        item = Visit.new(v)
        item.uri = item.create_uri(item.class.base_uri)
        v_items << item
      end

      # Timepoints
      secs_per_week = 7*24*60*60
      o_items = []
      [0, 8, 16, 24].each_with_index do |v, index|
        item = Timepoint::Offset.new(window_offset: v*secs_per_week, window_minus: 0, window_plus: 0)
        item.uri = item.create_uri(item.class.base_uri)
        o_items << item
      end
      tps = 
      [
        {label: "TP1", in_visit: v_items[0].uri, at_offset: o_items[0].uri},
        {label: "TP2", in_visit: v_items[1].uri, at_offset: o_items[1].uri},
        {label: "TP3", in_visit: v_items[2].uri, at_offset: o_items[2].uri},
        {label: "TP4", in_visit: v_items[3].uri, at_offset: o_items[3].uri},
      ]
      tp_items = []
      tps.each_with_index do |v, index|
        item = Timepoint.new(v)
        item.uri = item.create_uri(item.class.base_uri)
        tp_items << item
      end

      # Epochs & Arms
      e_1 = Epoch.new(label: "Screening", ordinal: 1)
      e_1.uri = e_1.create_uri(e_1.class.base_uri)
      e_2 = Epoch.new(label: "Treatment", ordinal: 2)
      e_2.uri = e_2.create_uri(e_2.class.base_uri)      
      a_1 = Arm.new(label: "High Dose", description: "High Dose", arm_type: "", ordinal: 1)
      a_1.uri = a_1.create_uri(a_1.class.base_uri)
      a_2 = Arm.new(label: "Low Dose", description: "Low Dose", arm_type: "", ordinal: 2)
      a_2.uri = a_2.create_uri(a_2.class.base_uri)
      a_3 = Arm.new(label: "Placebo", description: "Placebo", arm_type: "", ordinal: 3)
      a_3.uri = a_3.create_uri(a_3.class.base_uri)
      el_1 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_1.uri)
      el_1.uri = el_1.create_uri(el_1.class.base_uri)
      el_2 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_2.uri)
      el_2.uri = el_2.create_uri(el_2.class.base_uri)
      el_3 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_3.uri)
      el_3.uri = el_3.create_uri(el_3.class.base_uri)
      el_4 = Element.new(label: "High Dose", in_epoch: e_2.uri, in_arm: a_1.uri)
      el_4.uri = el_4.create_uri(el_4.class.base_uri)
      el_5 = Element.new(label: "Low Dose", in_epoch: e_2.uri, in_arm: a_2.uri)
      el_5.uri = el_5.create_uri(el_5.class.base_uri)
      el_6 = Element.new(label: "Placebo", in_epoch: e_2.uri, in_arm: a_3.uri)
      el_6.uri = el_6.create_uri(el_6.class.base_uri)

      # Protocol
      tc = th.find_by_identifiers(["C99076", "C82639"])["C82639"]
      im_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 1)
      tc = th.find_by_identifiers(["C66735", "C15228"])["C15228"]
      m_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 2)

      # Protocols
      tc = th.find_by_identifiers(["C66737", "C15601"])["C15601"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98388"])["C98388"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Nervous system disorders")
      ind = Indication.where(label: "Alzheimer's Disease")
      p_1 = Protocol.new(label: "LY246708", 
        title: "Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimer’s Disease.", 
        short_title: "", acronym: "H2Q-MC-LZZT", 
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref, 
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref,
        specifies_epoch: [e_1.uri, e_2.uri], specifies_arm: [a_1.uri, a_2.uri, a_3.uri])
      p_1.set_initial("LY246708")

      tc = th.find_by_identifiers(["C66737", "C15600"])["C15600"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98388"])["C98388"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Metabolic")
      ind = Indication.where(label: "Diabetes Mellitus")
      p_2 = Protocol.new(label: "DS8500-A-U202", title: "A made up protocol title", short_title: "", acronym: "MADE UP ACRONYM", 
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref, 
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref)
      p_2.set_initial("DS8500-A-U202")

      tc = th.find_by_identifiers(["C66737", "C15600"])["C15600"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C16084"])["C16084"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Inflammation")
      ind = Indication.where(label: "Rheumatoid Arthritis")
      p_3 = Protocol.new(label: "CPT_TALib-RA-BWE_V002", title: "A made up protocol title", short_title: "", acronym: "MADE UP ACRONYM", 
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref, 
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref)
      p_3.set_initial("CPT_TALib-RA-BWE_V002")

      tc = th.find_by_identifiers(["C66737", "C15602"])["C15602"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98388"])["C98388"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Vaccines")
      ind = Indication.where(label: "Influenza")
      p_4 = Protocol.new(label: "FLU 001", title: "A made up protocol title", short_title: "", acronym: "MADE UP ACRONYM", 
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref, 
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref)
      p_4.set_initial("FLU001")

      tc = th.find_by_identifiers(["C66737", "C49686"])["C49686"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98722"])["C98722"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Nervous system disorders")
      ind = Indication.where(label: "Alzheimer's Disease")
      p_5 = Protocol.new(label: "CPT_TALib-Alzheimers-BWE_V003", title: "A made up protocol title", short_title: "", 
        acronym: "MADE UP ACRONYM", 
        in_ta: ta.first.uri, for_indication: [ind.first.uri],
        study_type: type_ref, study_phase: phase_ref, masking: m_ref, intervention_model: im_ref)
      p_5.set_initial("CPT_TALib-ALZ-BWE_V003")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      e_1.to_sparql(sparql, true)
      e_2.to_sparql(sparql, true)
      a_1.to_sparql(sparql, true)
      a_2.to_sparql(sparql, true)
      a_3.to_sparql(sparql, true)
      el_1.to_sparql(sparql, true)
      el_2.to_sparql(sparql, true)
      el_3.to_sparql(sparql, true)
      el_4.to_sparql(sparql, true)
      el_5.to_sparql(sparql, true)
      el_6.to_sparql(sparql, true)
      p_1.to_sparql(sparql, true)
      p_2.to_sparql(sparql, true)
      p_3.to_sparql(sparql, true)
      p_4.to_sparql(sparql, true)
      p_5.to_sparql(sparql, true)
      v_items.each {|x| x.to_sparql(sparql, true)}
      tp_items.each {|x| x.to_sparql(sparql, true)}
      o_items.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_protocols.ttl")
    end

  end

end