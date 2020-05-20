require 'rails_helper'

describe 'triple store add rank schema' do

  migration_file_name = Dir[Rails.root.join('db/migrate/20200519094500_ts_add_rank_schema.rb')].first
  require migration_file_name
  
  def sub_dir
    return "migrations/ts_add_rank_schema"
  end

  before :each do
    # Set of schema files pre migration
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", 
      "business_operational.ttl", "annotations.ttl",
      "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl", "BusinessDomain.ttl", "test.ttl"
    ]
    load_files(schema_files, [])
    load_local_file_into_triple_store(sub_dir, "thesaurus.ttl")
    @skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
    @rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
  end

  def check_triple(triples, predicate, value)
    expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
  end

  def check_updated
    # Check updated triples, should still be old version
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#Subset"))
    check_triple(triples, @skos_def, "The head of the list by which a code list is ordered.")
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#SubsetMember"))
    check_triple(triples, @skos_def, "Ordered list member.")
    check_triple(triples, @rdfs_label, "Subset Member")
  end

  def check_new
    # Check sample of new triples
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#RankedCollection"))
    check_triple(triples, @skos_def, "The head of the collection by which a code list is ranked.")
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#RankedMember"))
    check_triple(triples, @skos_def, "Rank list member.")
    check_triple(triples, @rdfs_label, "Rank Member")
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#rank"))
    check_triple(triples, @skos_def, "The rank value.")
    check_triple(triples, @rdfs_label, "Rank")
  end

  def check_old
    # Old triples check
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#Subset"))
    check_triple(triples, @skos_def, "Thesaurus Concept")
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#SubsetMember"))
    check_triple(triples, @skos_def, "Thesaurus Concept")
    check_triple(triples, @rdfs_label, "Subset")
  end

  it 'add rank schema' do
    # Definitions, check triple store count
    skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
    rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
    expected = 28 # Number of extra triples
    base = triple_store.triple_count
    expect(base).to eq(1584)

    # Old triples check
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#Subset"))
    check_triple(triples, skos_def, "Thesaurus Concept")
    triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#SubsetMember"))
    check_triple(triples, skos_def, "Thesaurus Concept")
    check_triple(triples, rdfs_label, "Subset")

    # Run migration
    migration = TsAddRankSchema.new
    migration.change

    # Check results
    expect(triple_store.triple_count).to eq(base + expected)
    check_updated
    check_new
  end

  it 'add rank schema, exception upload' do
    # Definitions, check triple store count
    skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
    rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
    expected = 28 # Number of extra triples
    base = triple_store.triple_count
    expect(base).to eq(1584)

    # Old triples check
    check_old

    # Run migration
    expect_any_instance_of(Sparql::File).to receive(:upload).and_raise("ERROR")
    migration = TsAddRankSchema.new
    expect{migration.change}.to raise_error(Errors::UpdateError, /Migration error, step: 1/)
      
    # Check triple count, no change and updated triples, should still be old version
    expect(triple_store.triple_count).to eq(base)
    check_old
  end

  it 'add rank schema, exception update' do
    # Definitions, check triple store count
    expected = 28 # Number of extra triples
    base = triple_store.triple_count
    expect(base).to eq(1584)

    # Old triples check
    check_old

    # Run migration
    expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
    migration = TsAddRankSchema.new
    expect{migration.change}.to raise_error(Errors::UpdateError, /Migration error, step: 2/)
      
    # Check triple count, no change, updated triples should still be old and new triples 
    # should be present
    expect(triple_store.triple_count).to eq(base + expected)
    check_old
    check_new
  end

end