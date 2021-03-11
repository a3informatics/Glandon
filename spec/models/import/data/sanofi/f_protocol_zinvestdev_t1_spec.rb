require 'rails_helper'

describe "E - Transcelerate Protocol" do

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

  describe "Protocol ZINVESTDEV" do

    it "Protocol" do
      load_local_file_into_triple_store(sub_dir, "a_protocol_templates.ttl")
      load_local_file_into_triple_store(sub_dir, "b_parameters.ttl")
      load_local_file_into_triple_store(sub_dir, "c_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "c_objectives.ttl")
      load_local_file_into_triple_store(sub_dir, "d_therapeutic_areas.ttl")

      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V68#TH"))

      # Visits
      visits =
      [
        {short_name: "Vis#01", label: "Run-in"},
        {short_name: "Vis#02", label: "Baseline"},
        {short_name: "Vis#03", label: "Week 1"},
        {short_name: "Vis#04", label: "Week 2"},
        {short_name: "Vis#05", label: "Week 4"},
        {short_name: "Vis#06", label: "Week 6"},
        {short_name: "Vis#07", label: "Week 8"}
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
      [-1, 1, 7, 14, 28, 42, 56].each_with_index do |v, index|
        item = Timepoint::Offset.new(window_offset: v*secs_per_week, window_minus: 0, window_plus: 0, unit: "Day")
        item.uri = item.create_uri(item.class.base_uri)
        o_items << item
      end
      tps =
      [
        {
          label: "TP1", in_visit: v_items[0].uri, at_offset: o_items[0].uri,
          has_planned: [
            #sass_items[0].uri
            # sass_items[2].uri, sass_items[6].uri, sass_items[10].uri, sass_items[12].uri
          ]
        },
        {
          label: "TP2", in_visit: v_items[1].uri, at_offset: o_items[1].uri,
          has_planned: [
            #sass_items[1].uri
            # sass_items[3].uri, sass_items[7].uri, sass_items[13].uri
          ]
        },
        {
          label: "TP3", in_visit: v_items[2].uri, at_offset: o_items[2].uri,
          has_planned: [
            # sass_items[11].uri
          ]
        },
        {
          label: "TP4", in_visit: v_items[3].uri, at_offset: o_items[3].uri,
          has_planned: [
            # sass_items[4].uri, sass_items[8].uri
          ]
        },
        {
          label: "TP5", in_visit: v_items[4].uri, at_offset: o_items[4].uri,
          has_planned: [
            # sass_items[5].uri, sass_items[9].uri
          ]
        },
        {
          label: "TP6", in_visit: v_items[4].uri, at_offset: o_items[4].uri,
          has_planned: [
            # sass_items[5].uri, sass_items[9].uri
          ]
        },
        {
          label: "TP7", in_visit: v_items[4].uri, at_offset: o_items[4].uri,
          has_planned: [
            # sass_items[5].uri, sass_items[9].uri
          ]
        }
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
          derived_from_endpoint: Endpoint.where(label: "Endpoint 1").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP2",
          full_text: "The change from baseline to Week 8, 16 and 24 in the Clinician’s Interview-Based Impression of Change plus caregiver input (CIBIC+)",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri, tp_items[3].uri, tp_items[4].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 2").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP3",
          full_text: "The change from baseline to Week 8 in the Neuropsychiatric Inventory (NPI) total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 9").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP4",
          full_text: "The proportion of participants with adverse events, serious adverse events (SAEs), and adverse events leading to study intervention discontinuation over the 24-week study intervention period",
          primary_timepoint: tp_items[4].uri,
          secondary_timepoint: [],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 5").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP5",
          full_text: "The change from baseline to Week 12 in continuous laboratory tests: Hepatic Function Panel",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[2].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 6").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP6",
          full_text: "The proportion of participants with abnormal (high or low) laboratory measures (urinalysis) during the postrandomization phase",
          primary_timepoint: tp_items[1].uri,
          secondary_timepoint: [tp_items[2].uri, tp_items[3].uri, tp_items[4].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 7").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP7",
          full_text: "The change from baseline to Week 8 in ECG parameter: QTcF",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 8").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP8",
          full_text: "The change from baseline to Week 8 in the Neuropsychiatric Inventory (NPI) total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 9").first,
          is_derived_from: []
        },
        {
          label: "LY246708 EP9",
          full_text: "The change from baseline to Week 8 in the DAD total score",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[1].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 9").first,
          is_derived_from: [] #[sass_items[0].uri, sass_items[1].uri]
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
      enum_s = Enumerated.where(label: "Tertiary").first
      objectives =
      [
        {
          label: "LY246708 OBJ1",
          full_text: "To assess the effect of Xanomeline Transdermal Therapeutic System (TTS) on the ADAS-Cog and CIBIC+ scores at Week 24 in participants with Mild to Moderate Alzheimer’s Disease",
          objective_type: enum_p.uri,
          is_assessed_by: [ep_items[0].uri, ep_items[1].uri],
          derived_from_objective: Objective.where(label: "Objective 1").first
        },
        {
          label: "LY246708 OBJ2",
          full_text: "To assess the dose-dependent improvement in behavior. Improved scores on the Revised Neuropsychiatric Inventory (NPI-X) will indicate improvement in these areas",
          objective_type: enum_p.uri,
          is_assessed_by: [ep_items[2].uri],
          derived_from_objective: Objective.where(label: "Objective 3").first
        },
        {
          label: "LY246708 OBJ3",
          full_text: "To document the safety profile of the xanomeline TTS.",
          objective_type: enum_s.uri,
          is_assessed_by: [ep_items[3].uri, ep_items[4].uri, ep_items[5].uri, ep_items[6].uri],
          derived_from_objective: Objective.where(label: "Objective 4").first
        },
        {
          label: "LY246708 OBJ4",
          full_text: "To assess the effect of xanomeline TTS on the measure of behavioral/neuropsychiatric symptoms in participants with  Alzheimer’s Disease",
          objective_type: enum_s.uri,
          is_assessed_by: [ep_items[7].uri],
          derived_from_objective: Objective.where(label: "Objective 5").first
        },
        {
          label: "LY246708 OBJ5",
          full_text: "To assess the dose-dependent improvements in activities of daily living. Improved scores on the Disability Assessment for Dementia (DAD) will indicate improvement in these areas",
          objective_type: enum_s.uri,
          is_assessed_by: [ep_items[8].uri],
          derived_from_objective: Objective.where(label: "Objective 6").first
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
      el_4 = Element.new(label: "High Dose", in_epoch: e_2.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri, tp_items[4].uri])
      el_4.uri = el_4.create_uri(el_4.class.base_uri)
      el_5 = Element.new(label: "Low Dose", in_epoch: e_2.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri, tp_items[4].uri])
      el_5.uri = el_5.create_uri(el_5.class.base_uri)
      el_6 = Element.new(label: "Placebo", in_epoch: e_2.uri, in_arm: a_3.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri, tp_items[4].uri])
      el_6.uri = el_6.create_uri(el_6.class.base_uri)

      # Protocol
      tc = th.find_by_identifiers(["C99076", "C82639"])["C82639"]
      im_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 1)
      tc = th.find_by_identifiers(["C66735", "C15228"])["C15228"]
      m_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 2)


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
      ass1.to_sparql(sparql, true)
      v_items.each {|x| x.to_sparql(sparql, true)}
      tp_items.each {|x| x.to_sparql(sparql, true)}
      o_items.each {|x| x.to_sparql(sparql, true)}
      obj_items.each {|x| x.to_sparql(sparql, true)}
      ep_items.each {|x| x.to_sparql(sparql, true)}
      sass_items.each {|x| x.to_sparql(sparql, true)}

      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "zinvestdev1_protocols.ttl")
    end

  end

end
