require 'rails_helper'

describe "D - Transcelerate Protocol Templates" do

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

  it "Protocol" do
    load_local_file_into_triple_store(sub_dir, "hackathon_thesaurus.ttl")
    load_local_file_into_triple_store(sub_dir, "hackathon_indications.ttl")
    load_local_file_into_triple_store(sub_dir, "hackathon_tas.ttl")
    load_local_file_into_triple_store(sub_dir, "hackathon_endpoints.ttl")
    load_local_file_into_triple_store(sub_dir, "hackathon_bc_instances.ttl")

    # Templates
    protocol_templates = 
    [
      {
        label: "Cross Over, 4 Epoch",
        identifier: "CROSS 4 EPOCH",
        epochs: 
        [
          {label: "Screening", ordinal: 1},
          {label: "Treatment 1", ordinal: 2},
          {label: "Treatment 2", ordinal: 3},
          {label: "Follow Up", ordinal: 4}
        ],
        arms: 
        [
          {label: "AB", ordinal: 1},
          {label: "BA", ordinal: 2}
        ],
        elements:
        [
          ["Screen", "Screen"], 
          ["Treatment A", "Treatment B"], 
          ["Treatment B", "Treatment A"], 
          ["Follow-up", "Follow-up"]
        ]
      },
      {
        label: "Parallel, Simple",
        identifier: "PARALLEL SIMPLE",
        epochs: 
        [
          {label: "Screening", ordinal: 1},
          {label: "Treatment", ordinal: 2},
          {label: "Follow Up", ordinal: 3}
        ],
        arms: 
        [
          {label: "A", ordinal: 1},
          {label: "B", ordinal: 2}
        ],
        elements:
        [
          ["Screen", "Screen"], 
          ["Treatment A", "Treatment B"], 
          ["Follow-up", "Follow-up"]
        ]
      }
    ]

    # Build
    items = []
    protocol_templates.each do |pt|
      epochs = []
      arms = []
      pt[:epochs].each do |epoch|
        e = Epoch.new(epoch)
        e.uri = e.create_uri(e.class.base_uri)
        items << e
        epochs << e
      end
      pt[:arms].each do |arm|
        a = Arm.new(arm)
        a.uri = a.create_uri(a.class.base_uri)
        items << a
        arms << a
      end
      epochs.each do |epoch|
        arms.each do |arm|
          label = pt[:elements][epoch.ordinal - 1][arm.ordinal - 1]
          e = Element.new(label: label, in_epoch: epoch.uri, in_arm: arm.uri)
          e.uri = e.create_uri(e.class.base_uri)
          items << e
        end
      end
      p = ProtocolTemplate.new(
        label: pt[:label],
        specifies_epoch: epochs.map{|x| x.uri}, 
        specifies_arm: arms.map{|x| x.uri}
      )
      p.set_initial(pt[:identifier])
      items << p
    end

    # Generate
    sparql = Sparql::Update.new
    sparql.default_namespace(ProtocolTemplate.base_uri.namespace)
    items.each {|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_protocol_templates.ttl")
  end

end