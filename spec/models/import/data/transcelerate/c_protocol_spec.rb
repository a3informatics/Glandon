require 'rails_helper'

describe "C - Transcelerate Protocol" do

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
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#Assessment")
      p_4 = Parameter.new(label: "Assessment", parameter_rdf_type: uri)
      p_4.uri = p_4.create_uri(p_4.class.base_uri)
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      p_1.to_sparql(sparql, true)
      p_2.to_sparql(sparql, true)
      p_3.to_sparql(sparql, true)
      p_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_parameters.ttl")
    end 

  end

  describe "MDR Data" do

    it "End Points" do
      endpoints = 
      [
        {
          label: "Endpoint 1", 
          full_text: "The change from baseline to [[[Timepoint]]] in the Alzheimer’s Disease Assessment Scale – Cognitive Assessment (ADAS-Cog) 14 total score"
        },
        {
          label: "Endpoint 2", 
          full_text: "The change from baseline to Week [[[Timepoint]]] in the Clinician’s Interview-Based Impression of Change plus caregiver input (CIBIC+)"
        },
        {
          label: "Endpoint 3",         
          full_text: "The change [absolute] in HbA1c from baseline to [[[Timepoint]]]"
        },
        {
          label: "Endpoint 4", 
          full_text: "The change from baseline to [[[Timepoint]]] in the [[[BC]]]"
        },
        {
          label: "Endpoint 5", 
          full_text: "The proportion of participants with adverse events, serious adverse events (SAEs), and adverse events leading to study intervention discontinuation over the [x-week] study intervention period"
        },
        {
          label: "Endpoint 6", 
          full_text: "The change from baseline to [[[Timepoint]]] in continuous laboratory tests: Hepatic Function Panel"
        },
        {
          label: "Endpoint 7", 
          full_text: "The proportion of participants with abnormal (high or low) laboratory measures (urinalysis) during the postrandomization phase"
        },
        {
          label: "Endpoint 8", 
          full_text: "The change from baseline to [[[Timepoint]]] in ECG parameter: QTcF"
        },
        {
          label: "Endpoint 9", 
          full_text: "The change from baseline to [[[Timepoint]]] in the [[[Assessment]]]"
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
      enum_p.uri = enum_p.create_uri(enum_p.class.base_uri)
      enum_s = Enumerated.new(label: "Secondary")
      enum_s.uri = enum_s.create_uri(enum_s.class.base_uri)
      enum_ns = Enumerated.new(label: "Not Set")
      enum_ns.uri = enum_ns.create_uri(enum_ns.class.base_uri)

      ep1 = Endpoint.where(label: "Endpoint 1").first
      ep2 = Endpoint.where(label: "Endpoint 2").first
      ep3 = Endpoint.where(label: "Endpoint 3").first
      ep4 = Endpoint.where(label: "Endpoint 4").first
      ep5 = Endpoint.where(label: "Endpoint 5").first
      ep6 = Endpoint.where(label: "Endpoint 6").first
      ep7 = Endpoint.where(label: "Endpoint 7").first
      ep8 = Endpoint.where(label: "Endpoint 8").first
      ep9 = Endpoint.where(label: "Endpoint 9").first

      objectives = 
      [
        { 
          label: "Objective 1",
          full_text: "To assess the effect of [[[Intervention]]] on the ADAS-Cog and CIBIC+ scores at [[[Timepoint]]]] in participants with Mild to Moderate Alzheimer’s Disease",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep1.uri, ep2.uri]
        },
        { 
          label: "Objective 2",
          full_text: "To evaluate the efficacy of [[[Intervention]]] administered to individuals with Type 2 Diabetes Mellitus (T2DM)",
          objective_type: enum_ns.uri,
          is_assessed_by: []
        },
        { 
          label: "Objective 3",
          full_text: "To assess the dose-dependent improvement in behavior. Improved scores on the [[[BC]]] will indicate improvement in these areas",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep9.uri]
        },
        { 
          label: "Objective 4",
          full_text: "To document the safety profile of [[[Intervention]]].",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep5.uri, ep6.uri, ep7.uri, ep8.uri]
        },
        { 
          label: "Objective 5",
          full_text: "To assess the effect of [[[Intervention]]] [vs. comparator X, if applicable] on the measure of behavioral/neuropsychiatric symptoms in participants with [severity] Alzheimer’s Disease",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep9.uri]
        },
        { 
          label: "Objective 6",
          full_text: "To assess the dose-dependent improvements in activities of daily living. Improved scores on the [assessment] will indicate improvement in these areas",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep9.uri]
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
      enum_p.to_sparql(sparql, true)
      enum_s.to_sparql(sparql, true)
      enum_ns.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_objectives.ttl")
    end

    it "Indications" do
      load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_objectives.ttl")

      obj1 = Objective.where(label: "Objective 1").first
      obj2 = Objective.where(label: "Objective 2").first
      obj3 = Objective.where(label: "Objective 3").first
      obj4 = Objective.where(label: "Objective 4").first
      obj5 = Objective.where(label: "Objective 5").first
      obj6 = Objective.where(label: "Objective 6").first

      # Indications
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CT/V1#TH"))
      tc_1 = Thesaurus::UnmanagedConcept.where(notation: "AD")
      op_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc_1.first.uri, optional: false, ordinal: 1)
      i_1 = Indication.new(label: "Alzheimer's Disease", indication: op_ref, has_objective: [obj1.uri, obj3.uri, obj4.uri, obj5.uri, obj6.uri])
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
      load_local_file_into_triple_store(sub_dir, "hackathon_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_objectives.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_indications.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_tas.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "hackathon_bc_instances.ttl")
      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      
      bc1 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105183/V1#BCI"))
      bc2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105181/V1#BCI"))
      bc3 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105171/V1#BCI"))
      bc4 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105204/V1#BCI"))
      bc5 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105199/V1#BCI"))
      bc6 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105173/V1#BCI"))
      bc7 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105202/V1#BCI"))
      bc8 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105203/V1#BCI"))
      bc9 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105172/V1#BCI"))
      bc10 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105185/V1#BCI"))
      bc11 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DAD_C105178/V1#BCI"))
      ass1 = Assessment.new(label: "Disability Assessment for Dementia (DAD)")
      [bc1,bc2,bc3,bc4,bc5,bc6,bc7,bc8,bc9,bc10,bc11].each_with_index {|x, index| ass1.add_no_save(x, index+1)}
      ass1.set_initial("ASS DAD")

      sass_items = []
      study_assessments = [ass1, ass1]
      study_assessments.each do |sass_item|
        sass = StudyAssessment.new(label: sass_item.label, is_derived_from: sass_item.uri)
        sass.uri = sass.create_uri(sass.class.base_uri)
        sass_items << sass
      end

      # Visits
      visits = 
      [
        {short_name: "BL", label: "Baseline"},
        {short_name: "Wk8", label: "Week 8"},
        {short_name: "Wk12", label: "Week 12"},
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
      [0, 8, 12, 16, 24].each_with_index do |v, index|
        item = Timepoint::Offset.new(window_offset: v*secs_per_week, window_minus: 0, window_plus: 0, unit: "Week")
        item.uri = item.create_uri(item.class.base_uri)
        o_items << item
      end
      tps = 
      [
        {label: "TP1", in_visit: v_items[0].uri, at_offset: o_items[0].uri, has_planned: [sass_items[0].uri]},
        {label: "TP2", in_visit: v_items[1].uri, at_offset: o_items[1].uri, has_planned: [sass_items[1].uri]},
        {label: "TP3", in_visit: v_items[2].uri, at_offset: o_items[2].uri, has_planned: []},
        {label: "TP4", in_visit: v_items[3].uri, at_offset: o_items[3].uri, has_planned: []},
        {label: "TP5", in_visit: v_items[4].uri, at_offset: o_items[4].uri, has_planned: []},
      ]
      tp_items = []
      tps.each_with_index do |v, index|
        item = Timepoint.new(v)
        item.uri = item.create_uri(item.class.base_uri)
        tp_items << item
      end

    # Endpoints
      endpoints = 
      [
        {
          label: "LY246708 EP1", 
          full_text: "The change from baseline to Week 8, 16 and 24 in the Alzheimer’s Disease Assessment Scale – Cognitive Assessment (ADAS-Cog) 14 total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri, tp_items[3].uri, tp_items[4].uri],
          derived_from: Endpoint.where(label: "Endpoint 1"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP2", 
          full_text: "The change from baseline to Week 8, 16 and 24 in the Clinician’s Interview-Based Impression of Change plus caregiver input (CIBIC+)",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri, tp_items[3].uri, tp_items[4].uri],
          derived_from: Endpoint.where(label: "Endpoint 2"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP3", 
          full_text: "The change from baseline to Week 8 in the Neuropsychiatric Inventory (NPI) total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from: Endpoint.where(label: "Endpoint 9"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP4", 
          full_text: "The proportion of participants with adverse events, serious adverse events (SAEs), and adverse events leading to study intervention discontinuation over the 24-week study intervention period",
          primary_timepoint: tp_items[4].uri,
          secondary_timepoint: [],
          derived_from: Endpoint.where(label: "Endpoint 5"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP5", 
          full_text: "The change from baseline to Week 12 in continuous laboratory tests: Hepatic Function Panel",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[2].uri],
          derived_from: Endpoint.where(label: "Endpoint 6"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP6", 
          full_text: "The proportion of participants with abnormal (high or low) laboratory measures (urinalysis) during the postrandomization phase",
          primary_timepoint: tp_items[1].uri,
          secondary_timepoint: [tp_items[2].uri, tp_items[3].uri, tp_items[4].uri],
          derived_from: Endpoint.where(label: "Endpoint 7"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP7", 
          full_text: "The change from baseline to Week 8 in ECG parameter: QTcF",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from: Endpoint.where(label: "Endpoint 8"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP8", 
          full_text: "The change from baseline to Week 8 in the Neuropsychiatric Inventory (NPI) total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from: Endpoint.where(label: "Endpoint 9"),
          is_derived_from: []
        },
        {
          label: "LY246708 EP9", 
          full_text: "The change from baseline to Week 8 in the DAD total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from: Endpoint.where(label: "Endpoint 9"),
          is_derived_from: [sass_items[0].uri, sass_items[1].uri]
        },
      ]
      ep_items = []
      endpoints.each_with_index do |v, index|
        item = ProtocolEndpoint.new(v)
        item.uri = item.create_uri(item.class.base_uri)
        ep_items << item
      end

      # Objectives
      enum_p = Enumerated.where(label: "Primary").first
      enum_s = Enumerated.where(label: "Secondary").first
      objectives = 
      [
        { 
          label: "LY246708 OBJ1", 
          full_text: "To assess the effect of Xanomeline Transdermal Therapeutic System (TTS) on the ADAS-Cog and CIBIC+ scores at Week 24 in participants with Mild to Moderate Alzheimer’s Disease",
          objective_type: enum_p.uri,
          is_assessed_by: [],
          derived_from: Objective.where(label: "Objective 1").first
        },
        { 
          label: "LY246708 OBJ2", 
          full_text: "To assess the dose-dependent improvement in behavior. Improved scores on the Revised Neuropsychiatric Inventory (NPI-X) will indicate improvement in these areas",
          objective_type: enum_p.uri,
          is_assessed_by: [],
          derived_from: Objective.where(label: "Objective 3").first
        },
        { 
          label: "LY246708 OBJ3", 
          full_text: "To document the safety profile of the xanomeline TTS.",
          objective_type: enum_s.uri,
          is_assessed_by: [],
          derived_from: Objective.where(label: "Objective 4").first
        },
        { 
          label: "LY246708 OBJ4", 
          full_text: "To assess the effect of xanomeline TTS on the measure of behavioral/neuropsychiatric symptoms in participants with  Alzheimer’s Disease",
          objective_type: enum_s.uri,
          is_assessed_by: [],
          derived_from: Objective.where(label: "Objective 5").first
        },
        { 
          label: "LY246708 OBJ5", 
          full_text: "To assess the dose-dependent improvements in activities of daily living. Improved scores on the Disability Assessment for Dementia (DAD) will indicate improvement in these areas",
          objective_type: enum_s.uri,
          is_assessed_by: [],
          derived_from: Objective.where(label: "Objective 6").first
        }
      ]
      obj_items = []
      objectives.each_with_index do |v, index|
        item = ProtocolObjective.new(v)
        item.uri = item.create_uri(item.class.base_uri)
        obj_items << item
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
      el_1 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[0].uri])
      el_1.uri = el_1.create_uri(el_1.class.base_uri)
      el_2 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[0].uri])
      el_2.uri = el_2.create_uri(el_2.class.base_uri)
      el_3 = Element.new(label: "Screen", in_epoch: e_1.uri, in_arm: a_3.uri, contains_timepoint: [tp_items[0].uri])
      el_3.uri = el_3.create_uri(el_3.class.base_uri)
      el_4 = Element.new(label: "High Dose", in_epoch: e_2.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri])
      el_4.uri = el_4.create_uri(el_4.class.base_uri)
      el_5 = Element.new(label: "Low Dose", in_epoch: e_2.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri])
      el_5.uri = el_5.create_uri(el_5.class.base_uri)
      el_6 = Element.new(label: "Placebo", in_epoch: e_2.uri, in_arm: a_3.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri])
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
        specifies_epoch: [e_1.uri, e_2.uri], specifies_arm: [a_1.uri, a_2.uri, a_3.uri],
        specifies_objective: [obj_items[0].uri, obj_items[1].uri, obj_items[2].uri, obj_items[3].uri])
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
      obj_items.each {|x| x.to_sparql(sparql, true)}
      ep_items.each {|x| x.to_sparql(sparql, true)}

      # sbc1.to_sparql(sparql, true)
      # sbc2.to_sparql(sparql, true)
      # sass1.to_sparql(sparql, true)
      # ass.to_sparql(sparql, true)

      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_protocols.ttl")
    end

  end

end