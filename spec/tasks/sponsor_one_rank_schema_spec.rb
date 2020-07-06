require 'rails_helper'
require 'rake'

describe 'sponsor one rank schema migration' do
  
  before :all do
    Rake.application.rake_require "tasks/sponsor_one_rank_schema"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/sponsor_one/rank_schema"
  end

  describe 'sponsor one rank data' do
    
    before :each do
      # Set of schema files pre migration
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", 
        "business_operational.ttl", "annotations.ttl", "BusinessForm.ttl", 
        "CDISCBiomedicalConcept.ttl", "BusinessDomain.ttl", "test.ttl", "thesaurus.ttl"
      ]
      clear_triple_store
      schema_files.each do |x|
        load_local_file_into_triple_store(sub_dir, x)
      end
      @skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      @rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
    end

    def expected_triple_count
      1599
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

    def mark_done
      sparql = Sparql::Update.new
      sparql_update = %Q{
        DELETE 
        {
          th:SubsetMember rdfs:label ?o2 .
        }      
        INSERT 
        {
          th:SubsetMember rdfs:label "Subset Member"^^xsd:string .
        }
        WHERE 
        {
          th:SubsetMember rdfs:label ?o2 .
        }  
      }
      sparql.sparql_update(sparql_update, "", [:th])
    end

    let :run_rake_task do
      Rake::Task["sponsor_one:rank_schema"].reenable
      Rake.application.invoke_task "sponsor_one:rank_schema"
    end

    it 'add rank schema' do
      # Definitions, check triple store count
      skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
      expected = 28 # Number of extra triples
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#Subset"))
      check_triple(triples, skos_def, "Thesaurus Concept")
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#SubsetMember"))
      check_triple(triples, skos_def, "Thesaurus Concept")
      check_triple(triples, rdfs_label, "Subset")

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_updated
      check_new
    end

    it "won't run second time" do
      mark_done
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it 'add rank schema, exception upload' do
      # Definitions, check triple store count
      skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
      expected = 28 # Number of extra triples
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Upload).to receive(:send).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 1/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base)
      check_old
    end

    it 'add rank schema, exception update' do
      # Definitions, check triple store count
      expected = 28 # Number of extra triples
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 2/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_old
      check_new
    end

    it 'add rank schema, success checks fail I' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:triple_count).and_return(400, 500) # Fake wrong triple count
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

    it 'add rank schema, success checks fail II' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:ask?).and_return(false) # Fake wrong ask result
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

  end

end