require 'rails_helper'

describe "C - End Points and Objectives" do

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

  describe "End Points and Objectives" do

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
        },
        {
          label: "Endpoint 10",
          full_text: "Number of participants with HbA1c <7% at [[[Timepoint]]]]"
        },
        {
          label: "Endpoint 11",
          full_text: "Change from baseline to [[[Timepoint]]]] in [[[BC]]]"
        },
        {
          label: "Endpoint 12",
          full_text: "Number of participants with adverse events"
        },
        {
          label: "Endpoint 13",
          full_text: "Number of participants with at least one hypoglycemic event during the [[[period]]]"
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
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "c_endpoints.ttl")
    end

    it "Objectives" do
      load_local_file_into_triple_store(sub_dir, "c_endpoints.ttl")

      enum_p = Enumerated.new(label: "Primary")
      enum_p.uri = enum_p.create_uri(enum_p.class.base_uri)
      enum_s = Enumerated.new(label: "Secondary")
      enum_s.uri = enum_s.create_uri(enum_s.class.base_uri)
      enum_t = Enumerated.new(label: "Tertiary")
      enum_t.uri = enum_t.create_uri(enum_t.class.base_uri)
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
      ep10 = Endpoint.where(label: "Endpoint 10").first
      ep11 = Endpoint.where(label: "Endpoint 11").first
      ep12 = Endpoint.where(label: "Endpoint 12").first
      ep13 = Endpoint.where(label: "Endpoint 13").first

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
          full_text: "To assess the effect of [[[Intervention]]] [[[vs. comparator X, if applicable]]] on the measure of behavioral/neuropsychiatric symptoms in participants with [[[severity]]] Alzheimer’s Disease",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep9.uri]
        },
        {
          label: "Objective 6",
          full_text: "To assess the dose-dependent improvements in activities of daily living. Improved scores on the [[[assessment]]] will indicate improvement in these areas",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep9.uri]
        },
        {
          label: "Objective 7",
          full_text: "To demonstrate the [[[superiority/noninferiority/equivalence]]] of [[[compound number]]] [[[dose, strength, frequency]]] in comparison to [[[INN, dose, strength, frequency]]] on {HbA1c change} from Baseline to [[[Week X/other]]] in participants with [[[indication]]]",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep4.uri]
        },
        {
          label: "Objective 8",
          full_text: "To demonstrate the [[[superiority/noninferiority/equivalence]]] of [[[compound number]]] [[[dose, strength, frequency]]] in comparison to [[[INN, dose, strength, frequency]]] on {Glycemic Control}",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep10.uri, ep11.uri]
        },
        {
          label: "Objective 9",
          full_text: "To evaluate the safety of [[[insert INN if available, otherwise compound number]]], [[[insert dose, strength as needed, frequency]]] and [[[insert INN, dose, strength as needed, frequency]]]",
          objective_type: enum_ns.uri,
          is_assessed_by: [ep12.uri, ep13.uri]
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
      enum_t.to_sparql(sparql, true)
      enum_ns.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "c_objectives.ttl")
    end

  end

end
