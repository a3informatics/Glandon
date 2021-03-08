require 'rails_helper'
require 'rake'

describe 'R3.1.1 schema migration' do
  
  before :all do
    Rake.application.rake_require "tasks/r3_1_1_schema"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/r3_1_1/schema"
  end

  describe 'schema' do
    
    before :each do
      # Set of schema files pre migration
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "business_operational.ttl", "annotations.ttl", "BusinessForm.ttl", 
        "BusinessDomain.ttl", "test.ttl", "thesaurus.ttl", "biomedical_concept.ttl"
      ]
      clear_triple_store
      schema_files.each {|x| load_local_file_into_triple_store(sub_dir, x)}
      @skos_def = Uri.new(uri: "http://www.w3.org/2004/02/skos/core#definition")
      @rdfs_label = Uri.new(uri: "http://www.w3.org/2000/01/rdf-schema#label")
    end

    def expected_triple_count
      1612
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_framework
      # Check sample of new triples
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.s-cubed.dk/Framework#isA"))
      check_triple(triples, @skos_def, "Relationship indicating the source is defined by the canonical reference.")
      check_triple(triples, @rdfs_label, "Is A Relationship")  
    end

    def check_cdt
      # Check sample of new triples
      triples = triple_store.subject_triples(Uri.new(uri: "http://www.s-cubed.dk/ComplexDatatypes#shortName"))
      check_triple(triples, @skos_def, "The short name for the complex datatype.")
      check_triple(triples, @rdfs_label, "Short Name")  
    end

    def check_still_old
      sparql_ask = %Q{
        fr:definition rdfs:label "Definition"^^xsd:string .
        cdt:label rdfs:label "Label"^^xsd:string .
      }
      expect(Sparql::Utility.new.ask?(sparql_ask, [:fr, :cdt])).to be(false)
    end

    def mark_done_1
      Sparql::Update.new.sparql_update("INSERT DATA {fr:definition rdfs:label \"Definition\"^^xsd:string}", "", [:fr])
    end

    def mark_done_2
      Sparql::Update.new.sparql_update("INSERT DATA {cdt:hasProperty rdfs:label \"Property\"^^xsd:string}", "", [:cdt])
    end

    let :run_rake_task do
      Rake::Task["r3_1_1:schema"].reenable
      Rake.application.invoke_task "r3_1_1:schema"
    end

    it "add schema, success" do
      # Definitions, check triple store count
      expected = 62 # Number of extra triples.
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_still_old

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_framework
      check_cdt
    end

    it "won't run second time" do
      mark_done_1
      mark_done_2
      expect{run_rake_task}.to raise_error(SystemExit, "Schema migration not required")
    end

    it 'add schema, exception first upload' do
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

    it 'add schema, exception second upload' do
      # Definitions, check triple store count
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
        
      # Check triple count, no change and no updated triples as we fake the first (succesful) call
      expect(triple_store.triple_count).to eq(base)
      check_still_old
    end

   it 'add schema, success checks fail I' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:triple_count).and_return(400, 500) # Fake wrong triple count
      expect{run_rake_task}.to raise_error(SystemExit, /Schema migration not succesful, checks failed/)
    end

    it 'add schema, success checks fail II' do
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