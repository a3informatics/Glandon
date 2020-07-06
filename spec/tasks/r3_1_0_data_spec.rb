require 'rails_helper'
require 'rake'

describe 'R3.1.0 data migration' do
  
  before :all do
    Rake.application.rake_require "tasks/r3_1_0_data"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/r3_1_0/data"
  end

  def schema_dir
    return "tasks/r3_1_0/schema"
  end

  describe 'data' do
    
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
        load_local_file_into_triple_store(schema_dir, x)
      end
      load_cdisc_term_versions(1..65)
      load_local_file_into_triple_store(sub_dir, "thesaurus_migration_3_1_0.ttl")
    end

    def expected_triple_count
      1253399
    end

    def mark_done
      sparql = Sparql::Update.new
      sparql_update = %Q{
        INSERT DATA
        {
          <http://www.a3informatics.com/dummy#A> th:refersTo <http://www.a3informatics.com/C66784/V1#C66784> .
        }
      }
      sparql.sparql_update(sparql_update, "", [:th])
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_old
      expect(Sparql::Utility.new.ask?("?s th:refersTo ?o", [:th])).to be(false)
    end

    def check_new
      expect(Sparql::Utility.new.ask?("<http://www.acme-pharma.com/E00001/V1#E00001> th:refersTo <http://www.cdisc.org/C99079/V28#C99079_C98779>", [:th])).to be(true)
      expect(Sparql::Utility.new.ask?("<http://www.acme-pharma.com/E00001/V1#S00001> th:refersTo <http://www.cdisc.org/C99079/V47#C99079_C125938>", [:th])).to be(true)
    end

    let :run_rake_task do
      Rake::Task["r3_1_0:data"].reenable
      Rake.application.invoke_task "r3_1_0:data"
    end

    it "updates R3.1.0 data" do
      # Definitions, check triple store count
      expected = 13 # Number of extra triples
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
      expect{run_rake_task}.to raise_error(SystemExit, "Data migration not required")
    end

    it 'add rank extensions, exception update' do
      # Definitions, check triple store count
      expected = 0 # Number of extra triples expected
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Data migration error, step: 1/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_old
    end

    it 'add rank data, success checks fail II' do
      base = triple_store.triple_count
      expect(base).to eq(expected_triple_count)

      # Old triples check
      check_old

      # Run migration
      allow_any_instance_of(Sparql::Utility).to receive(:ask?).and_return(false, false) # Fake the ask results
      expect{run_rake_task}.to raise_error(SystemExit, /Data migration not succesful, checks failed/)
    end

  end

end