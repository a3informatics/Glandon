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
        "BusinessDomain.ttl", "test.ttl", "thesaurus.ttl"
      ]
      clear_triple_store
      schema_files.each {|x| load_local_file_into_triple_store(sub_dir, x)}
      @skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      @rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
    end

    def expected_triple_count
      1477
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_deletion
      # Check triples removed
      expect(Sparql::Utility.new.ask?("th:narrowerReference ?p ?o", [:th])).to eq(false)
    end

    def check_extension
      # Check sample of new triples
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#pairedWith"))
      check_triple(triples, @skos_def, "A relationship linking a managed concept with a paired managed concept.")
      check_triple(triples, @rdfs_label, "Paired with relationship")  
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/Thesaurus#refersTo"))
      check_triple(triples, @skos_def, "Relationship indicating that the concept is refered to rather than created/owned.")
      check_triple(triples, @rdfs_label, "Refers to relationship")
    end

    def check_bc
      # Check sample of new triples
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#hasCodeValue"))
      check_triple(triples, @skos_def, "Reference to a coded value.")
      check_triple(triples, @rdfs_label, "Has Coded Value Realtionship")  
    end

    def check_still_old
      sparql_ask = %Q{
        th:pairedWith rdfs:label "Paired with relationship"^^xsd:string .
        bc:ComplexDatatype rdfs:label "Biomedical Concept Complex Datatype"^^xsd:string .
      }
      expect(Sparql::Utility.new.ask?(sparql_ask, [:th, :bc])).to be(false)
      expect(Sparql::Utility.new.ask?("th:narrowerReference ?p ?o", [:th])).to be(true)
    end

    def mark_done_1
      query = %Q{INSERT DATA {bc:ComplexDatatype rdfs:label \"Biomedical Concept Complex Datatype\"^^xsd:string}}
      Sparql::Update.new.sparql_update(query, "", [:bc])
    end

    def mark_done_2
      query = %Q{INSERT DATA {<http://www.assero.co.uk/CDISCBiomedicalConcept#A> rdfs:label \"xxx\"^^xsd:string}}
      Sparql::Update.new.sparql_update(query, "", [:th])
    end

    def mark_done_3
      query = %Q{DELETE {th:narrowerReference ?p ?o} WHERE {th:narrowerReference ?p ?o}}
      Sparql::Update.new.sparql_update(query, "", [:th])
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
      expected = 126 - 6 # Number of extra triples.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_extension
      check_bc
      check_deletion
    end

    it "won't run second time, new triple present" do
      mark_done_1
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it "won't run second time, old schema is present but not expected" do
      mark_done_2
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it "won't run second time, old schema to be removed not present" do
      mark_done_3
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it 'add R3.1.0 schema, exception first upload' do
      # Definitions, check triple store count
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      expect_any_instance_of(Sparql::Upload).to receive(:send).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 1/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base)
      check_still_old
    end

    it 'add R3.1.0 schema, exception second upload' do
      # Definitions, check triple store count
      expected = 0 
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      call_count = 0
      allow_any_instance_of(Sparql::Upload).to receive(:send) do
        call_count += 1
        call_count == 1 ? "" : raise("ERROR")
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 2/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base + expected)
    end

    it 'add R3.1.0 schema, exception update' do
      # Definitions, check triple store count
      expected = 126
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration error, step: 3/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_extension
      check_bc
    end

    it 'add R3.1.0 schema, success checks fail I' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:triple_count).and_return(400, 500) # Fake wrong triple count
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

    it 'add R3.1.0 schema, success checks fail II' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Run migration
      call_index = -1
      result = [false, true, false, false] # First 3 are to run the migration, fourth is the check result.
      allow_any_instance_of(Sparql::Utility).to receive(:ask?) do |arg|
        call_index += 1
        result[call_index]
      end
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

  end

end