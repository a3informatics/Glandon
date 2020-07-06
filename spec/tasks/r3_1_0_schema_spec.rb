require 'rails_helper'
require 'rake'

describe 'R3.1.0 schema migration' do
  
  before :all do
    Rake.application.rake_require "tasks/r3_1_0_schema"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/r3_1_0/schema"
  end

  describe 'schema' do
    
    before :each do
      # Set of schema files pre migration
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "business_operational.ttl", "annotations.ttl", "BusinessForm.ttl", 
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
      1612
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_new
      # Check sample of new triples
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#pairedWith"))
      check_triple(triples, @skos_def, "A relationship linking a managed concept with a paired managed concept.")
      check_triple(triples, @rdfs_label, "Paired with relationship")  
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#refersTo"))
      check_triple(triples, @skos_def, "Relationship indicating that the concept is refered to rather than created/owned.")
      check_triple(triples, @rdfs_label, "Refers to relationship")
    end

    def check_old
      # Old triples check
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property"))
      check_triple(triples, @rdfs_label, "ISO21090Property")
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/CDISCBiomedicalConcept#hasItem"))
      check_triple(triples, @rdfs_label, "Link to the constiuent parts of the Biomedical Concept (Instance or Template)")
    end

    def mark_done
      sparql = Sparql::Update.new
      sparql_update = %Q{
        DELETE 
        {
          <http://www.assero.co.uk/CDISCBiomedicalConcept#Node> rdfs:label ?o .
        }      
        WHERE 
        {
          <http://www.assero.co.uk/CDISCBiomedicalConcept#Node> rdfs:label ?o .
        }  
      }
      sparql.sparql_update(sparql_update, "", [:th])
    end

    let :run_rake_task do
      Rake::Task["r3_1_0:schema"].reenable
      Rake.application.invoke_task "r3_1_0:schema"
    end

    # Used to find new schema triple count, dont' delete
    # it "new triple count" do
    #   schema_files = ["thesaurus_migration_20200705.ttl", "biomedical_concept.ttl"]
    #   load_files(schema_files, [])
    #   triple_store.triple_count
    # end

    it "add R3.1.0 schema" do
      # Definitions, check triple store count
      expected = -9 # Number of extra triples, less in new schemas
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_new
    end

    it "won't run second time" do
      mark_done
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it 'add R3.1.0 schema, exception upload' do
      # Definitions, check triple store count
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

    it 'add R3.1.0 schema, exception update after file load' do
      # Definitions, check triple store count
      expected = 126 # Number of extra triples, 127 from above -1 for the repeated ontology triple
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 3/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_old
      check_new
    end

    it 'add R3.1.0 schema, success checks fail I' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:triple_count).and_return(400, 500) # Fake wrong triple count
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

    it 'add R3.1.0 schema, success checks fail II' do
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