require 'rails_helper'

describe "F - ZDUMMYMED Protocol" do

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

  describe "Protocol ZDUMMYMED" do

    it "Protocol" do
      load_local_file_into_triple_store(sub_dir, "a_protocol_templates.ttl")
      load_local_file_into_triple_store(sub_dir, "b_parameters.ttl")
      load_local_file_into_triple_store(sub_dir, "c_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "c_objectives.ttl")
      load_local_file_into_triple_store(sub_dir, "d_indications.ttl")
      load_local_file_into_triple_store(sub_dir, "d_therapeutic_areas.ttl")
      load_local_file_into_triple_store(sub_dir, "e_forms.ttl")

      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V68#TH"))

      # Dummy forms  
      f_ic = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/INFORMED_CONSENT_DEMO/V1#F"))
      f_dm = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DM_DEMO/V1#F"))
      f_lb = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/LB_DEMO/V1#F"))
      f_rand = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/RANDOM_DEMO/V1#F"))
      f_xo = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/X_OVER_DEMO/V1#F"))
      f_ae = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/AE_DEMO/V1#F"))
      f_term = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/TERMINATION_DEMO/V1#F"))
      f_dev = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/DEVICE_ALLOC_DEMO/V1#F"))
      f_cgm = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CGM_RUNNING_DEMO/V1#F"))

      # Full forms
      f_he = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HYPO_FORM/V1#F"))
      f_vs = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/VITAL_SIGNS/V1#F"))

      # BCs
      hba1c = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HBA1C/V1#BCI"))

      "Forms Etc"
      sass_items = []
      mdr_items =
      [
        f_ic, f_dm, f_vs, hba1c, f_lb,                                    # 0
                    f_vs, hba1c,       f_rand,       f_ae, f_he,          # 5
                          hba1c,                     f_ae, f_he,          # 10
                    f_vs, hba1c, f_lb,         f_xo, f_ae, f_he,          # 13
                          hba1c,                     f_ae, f_he,          # 19
                    f_vs, hba1c, f_lb,               f_ae, f_he,          # 22
                    f_vs, hba1c,                     f_ae, f_he, f_term   # 27
      ]
      mdr_items.each do |mdr_item|
        klass = mdr_item.rdf_type == Form.rdf_type ? StudyForm : StudyBiomedicalConcept
        sass = klass.new(label: mdr_item.label, is_derived_from: mdr_item.uri)
        sass.uri = sass.create_uri(sass.class.base_uri)
        sass_items << sass
      end

      # Visits
      visits =
      [
        {short_name: "Vis#01", label: "Baseline"},
        {short_name: "Vis#02", label: "Week 1"},
        {short_name: "Vis#03", label: "Week 6"},
        {short_name: "Vis#04", label: "Week 12"},
        {short_name: "Vis#05", label: "Week 18"},
        {short_name: "Vis#06", label: "Week 24"},
        {short_name: "Vis#07", label: "End of Study"}
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
      [0, 1, 6, 12, 18, 24, 25].each_with_index do |v, index|
        item = Timepoint::Offset.new(window_offset: v*secs_per_week, window_minus: 0, window_plus: 0, unit: "Week")
        item.uri = item.create_uri(item.class.base_uri)
        o_items << item
      end
      tps =
      [
        {
          label: "TP1", in_visit: v_items[0].uri, at_offset: o_items[0].uri,
          has_planned: sass_items[0..4].map{|x| x.uri}
        },
        {
          label: "TP2", in_visit: v_items[1].uri, at_offset: o_items[1].uri,
          has_planned: sass_items[5..9].map{|x| x.uri}
        },
        {
          label: "TP3", in_visit: v_items[2].uri, at_offset: o_items[2].uri,
          has_planned: sass_items[10..12].map{|x| x.uri}
        },
        {
          label: "TP4", in_visit: v_items[3].uri, at_offset: o_items[3].uri,
          has_planned: sass_items[13..18].map{|x| x.uri}
        },
        {
          label: "TP5", in_visit: v_items[4].uri, at_offset: o_items[4].uri,
          has_planned: sass_items[19..21].map{|x| x.uri}
        },
        {
          label: "TP6", in_visit: v_items[5].uri, at_offset: o_items[5].uri,
          has_planned: sass_items[22..26].map{|x| x.uri}
        },
        {
          label: "TP7", in_visit: v_items[6].uri, at_offset: o_items[6].uri,
          has_planned: sass_items[27..31].map{|x| x.uri}
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
          label: "Primary 1",
          full_text: "The change from baseline to Week 25 in HbA1c",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[6].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 11").first,
          is_derived_from: [sass_items[3].uri, sass_items[24].uri]
        },
        {
          label: "Secondary 1",
          full_text: "Number of participants with HbA1c <7% at Week 25",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[6].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 10").first,
          is_derived_from: [sass_items[24].uri]
        },
        {
          label: "Secondary 2",
          full_text: "Change from baseline to Week 25 in fasting plasma glucose (FPG)",
          primary_timepoint: tp_items[0].uri,
          secondary_timepoint: [tp_items[6].uri],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 11").first,
          is_derived_from: [sass_items[26].uri]
        },
        {
          label: "Tertiary 1",
          full_text: "Number of participants with adverse events",
          primary_timepoint: tp_items[6].uri,
          secondary_timepoint: [],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 12").first,
          is_derived_from: []
        },
        {
          label: "Tertiary 2",
          full_text: "Number of participants with at least one hypoglycemic event during the study.",
          primary_timepoint: tp_items[6].uri,
          secondary_timepoint: [],
          derived_from_endpoint: Endpoint.where(label: "Endpoint 13").first,
          is_derived_from: []
        }
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
      enum_t = Enumerated.where(label: "Tertiary").first
      objectives =
      [
        {
          label: "Primary",
          full_text: "To demonstrate the superiority of XXX ZD 5mg daily in comparison to [[[INN, dose, strength, frequency]]] on HbA1c change from Baseline to Week 12 ands 24 in participants with Tyep 2 Diabetes",
          objective_type: enum_p.uri,
          is_assessed_by: [ep_items[0].uri],
          derived_from_objective: Objective.where(label: "Objective 7").first
        },
        {
          label: "Secondary",
          full_text: "To demonstrate the [[[superiority/noninferiority/equivalence]]] of [[[compound number]]] [[[dose, strength, frequency]]] in comparison to [[[INN, dose, strength, frequency]]] on {Glycemic Control}",
          objective_type: enum_s.uri,
          is_assessed_by: [ep_items[1].uri, ep_items[2].uri],
          derived_from_objective: Objective.where(label: "Objective 8").first
        },
        {
          label: "Tertiary",
          full_text: "To demonstrate the superiority of XXX ZD 5mg daily in comparison to [[[INN, dose, strength, frequency]]] on HbA1c change from Baseline to Week 12 ands 24 in participants with Tyep 2 Diabetes",
          objective_type: enum_t.uri,
          is_assessed_by: [ep_items[3].uri, ep_items[4].uri],
          derived_from_objective: Objective.where(label: "Objective 9").first
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
      e_2 = Epoch.new(label: "Double Blind Treatment 1", ordinal: 2)
      e_2.uri = e_2.create_uri(e_2.class.base_uri)
      e_3 = Epoch.new(label: "Double Blind Treatment 2", ordinal: 3)
      e_3.uri = e_3.create_uri(e_3.class.base_uri)
      e_4 = Epoch.new(label: "Follow Up", ordinal: 4)
      e_4.uri = e_4.create_uri(e_4.class.base_uri)
      a_1 = Arm.new(label: "ZD CP", description: "Regimen ZD, CP", arm_type: "", ordinal: 1)
      a_1.uri = a_1.create_uri(a_1.class.base_uri)
      a_2 = Arm.new(label: "CP ZD", description: "Regimen CP, ZD", arm_type: "", ordinal: 2)
      a_2.uri = a_2.create_uri(a_2.class.base_uri)
      el_1 = Element.new(label: "Screening", in_epoch: e_1.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[0].uri])
      el_1.uri = el_1.create_uri(el_1.class.base_uri)
      el_2 = Element.new(label: "Screening", in_epoch: e_1.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[0].uri])
      el_2.uri = el_2.create_uri(el_2.class.base_uri)
      el_3 = Element.new(label: "ZD", in_epoch: e_2.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri])
      el_3.uri = el_3.create_uri(el_3.class.base_uri)
      el_4 = Element.new(label: "CP", in_epoch: e_2.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[1].uri, tp_items[2].uri, tp_items[3].uri])
      el_4.uri = el_4.create_uri(el_4.class.base_uri)
      
      el_5 = Element.new(label: "CP", in_epoch: e_3.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[4].uri, tp_items[5].uri])
      el_5.uri = el_5.create_uri(el_5.class.base_uri)
      el_6 = Element.new(label: "ZD", in_epoch: e_3.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[4].uri, tp_items[5].uri])
      el_6.uri = el_6.create_uri(el_6.class.base_uri)
      
      el_7 = Element.new(label: "Follow Up", in_epoch: e_4.uri, in_arm: a_1.uri, contains_timepoint: [tp_items[6].uri])
      el_7.uri = el_7.create_uri(el_7.class.base_uri)
      el_8 = Element.new(label: "Follow Up", in_epoch: e_4.uri, in_arm: a_2.uri, contains_timepoint: [tp_items[6].uri])
      el_8.uri = el_8.create_uri(el_8.class.base_uri)

      # Protocol
      tc = th.find_by_identifiers(["C99076", "C82637"])["C82637"]
      im_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 1)
      tc = th.find_by_identifiers(["C66735", "C15228"])["C15228"]
      m_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 2)
      tc = th.find_by_identifiers(["C66737", "C15602"])["C15602"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98388"])["C98388"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Metabolic")
      ind = Indication.where(label: "Type 2 Diabetes Mellitus")
      p_1 = Protocol.new(label: "ZDUMMYMED",
        title: "A 26 weeks, randomized, double-blind, comparator-controlled, cross-over group, Efficacy and Safety trial of once daily ZD 5mg oral, as add-on to Basal Insulin in Elderly (>60 years old) Type 2 Diabetes Mellitus patients with insufficient glycemic control.",
        short_title: "ZDUMMYMED", acronym: "ZDUMMYMED",
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref,
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref,
        specifies_epoch: [e_1.uri, e_2.uri, e_3.uri, e_4.uri], specifies_arm: [a_1.uri, a_2.uri],
        specifies_objective: [obj_items[0].uri, obj_items[1].uri, obj_items[2].uri])
      p_1.set_initial("ZDUMMYMED")

      # Study
      s_1 = Study.new(label: "Study for the ZDUMMYMED protocol", description: "Not set yet.", implements: p_1.uri)
      s_1.set_initial("ZDUMMYMED STUDY")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      e_1.to_sparql(sparql, true)
      e_2.to_sparql(sparql, true)
      e_3.to_sparql(sparql, true)
      e_4.to_sparql(sparql, true)
      a_1.to_sparql(sparql, true)
      a_2.to_sparql(sparql, true)
      el_1.to_sparql(sparql, true)
      el_2.to_sparql(sparql, true)
      el_3.to_sparql(sparql, true)
      el_4.to_sparql(sparql, true)
      el_5.to_sparql(sparql, true)
      el_6.to_sparql(sparql, true)
      el_7.to_sparql(sparql, true)
      el_8.to_sparql(sparql, true)
      p_1.to_sparql(sparql, true)
      s_1.to_sparql(sparql, true)
      v_items.each {|x| x.to_sparql(sparql, true)}
      tp_items.each {|x| x.to_sparql(sparql, true)}
      o_items.each {|x| x.to_sparql(sparql, true)}
      obj_items.each {|x| x.to_sparql(sparql, true)}
      ep_items.each {|x| x.to_sparql(sparql, true)}
      sass_items.each {|x| x.to_sparql(sparql, true)}

      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "zdummymed_protocols.ttl")
    end

  end

end
