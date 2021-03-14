require 'rails_helper'

describe "I - Blank Protocol" do

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

  describe "Protocol BLANK" do

    it "blank protocols" do
      load_local_file_into_triple_store(sub_dir, "a_protocol_templates.ttl")
      load_local_file_into_triple_store(sub_dir, "b_parameters.ttl")
      load_local_file_into_triple_store(sub_dir, "c_endpoints.ttl")
      load_local_file_into_triple_store(sub_dir, "c_objectives.ttl")
      load_local_file_into_triple_store(sub_dir, "d_indications.ttl")
      load_local_file_into_triple_store(sub_dir, "d_therapeutic_areas.ttl")
      load_local_file_into_triple_store(sub_dir, "e_forms.ttl")

      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V68#TH"))

      protocols = []

      tc = th.find_by_identifiers(["C99076", "C82639"])["C82639"]
      im_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 1)
      tc = th.find_by_identifiers(["C66735", "C49659"])["C49659"]
      m_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 2)
      tc = th.find_by_identifiers(["C66737", "C15602"])["C15602"]
      phase_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 3)
      tc = th.find_by_identifiers(["C99077", "C98388"])["C98388"]
      type_ref = OperationalReferenceV3::TucReference.new(context: th.uri, reference: tc, optional: false, ordinal: 4)
      ta = TherapeuticArea.where(label: "Vaccines")
      ind = Indication.where(label: "Influenza")
      (1..5).each_with_index do |p, index|
        version = index + 1
        protocol = Protocol.new(label: "Blank Protocol #{version}", title: "A made up protocol title", short_title: "BLANKY #{version}", acronym: "BLANKGO #{version}",
        in_ta: ta.first.uri, for_indication: [ind.first.uri], study_type: type_ref,
        study_phase: phase_ref, masking: m_ref, intervention_model: im_ref)
        protocol.set_initial("BLANK #{version}")
        protocols << protocol
      end

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(protocols.first.uri.namespace)
      protocols.each do |proto|
        proto.to_sparql(sparql, true)
      end

      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "blank_protocols.ttl")
    end

  end

end
