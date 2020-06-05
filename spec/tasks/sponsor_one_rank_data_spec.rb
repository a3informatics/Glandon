require 'rails_helper'
require 'rake'

describe 'sponsor one rank data migration rake task' do
  
  before :all do
    Rake.application.rake_require "tasks/sponsor_one_rank_data"
    Rake::Task.define_task(:environment)
  end

  describe 'sponsor one rank data' do
    
    before :each do
      # Set of schema files is post schema migration
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
      load_data_file_into_triple_store("sponsor_one/ct/CT_V3-0.ttl")
      @ct_26 = Thesaurus.find_minimum(Uri.new(uri: "http://www.sanofi.com/2019_R1/V1#TH"))
      @ct_30 = Thesaurus.find_minimum(Uri.new(uri: "http://www.sanofi.com/2020_R1/V1#TH"))
    end

    def mark_done
      sparql = Sparql::Update.new
      sparql_update = %Q{
        DELETE
        {
          ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        }      
        INSERT 
        {
          ?s1 bo:reference <http://www.sanofi.com/C66784/V1#C66784> .
        }
        WHERE 
        {
          <http://www.sanofi.com/2019_R1/V1#TH> th:isTopConceptReference ?s1 .
          ?s1 bo:reference <http://www.cdisc.org/C66784/V34#C66784> .
        }         
      }
      sparql.sparql_update(sparql_update, "", [:th, :bo])
    end

    def check_triple(triples, predicate, value)
      expect(triples.find{|x| x[:p] == predicate.to_s}[:o]).to eq(value)
    end

    def check_updated
      {"C66784" => 23, "C87162" => 24, "C66768" => 24, "C66769" => 21}.each do |k, v|
        triples = triple_store.subject_triples(Uri.new(uri: "http://www.sanofi.com/#{k}/V1##{k}"))
        expect(triples.count).to eq(v)
      end
    end

    def check_against(list, expected, ct)
      list.each_with_index do |identifier, index|
        results = ct.find_by_identifiers([identifier])
    puts "URI: #{results[identifier]}"
        expect(results[identifier]).to eq(expected[index])
      end
    end

    def check_old
      expected = 
      [
        Uri.new(uri: "http://www.cdisc.org/C66784/V34#C66784"),
        Uri.new(uri: "http://www.cdisc.org/C87162/V33#C87162"),
        Uri.new(uri: "http://www.cdisc.org/C66768/V28#C66768"),
        Uri.new(uri: "http://www.cdisc.org/C66769/V17#C66769")
      ]
      check_against(["C66784", "C87162", "C66768", "C66769"], expected, @ct_26)
      expected = 
      [
        Uri.new(uri: "http://www.cdisc.org/C66768/V28#C66768"),
        Uri.new(uri: "http://www.cdisc.org/C66769/V17#C66769")
      ]
      check_against(["C66768", "C66769"], expected, @ct_30)
    end

    def check_new
      expected = 
      [
        Uri.new(uri: "http://www.sanofi.com/C66784/V1#C66784"),
        Uri.new(uri: "http://www.sanofi.com/C87162/V1#C87162"),
        Uri.new(uri: "http://www.sanofi.com/C66768/V1#C66768"),
        Uri.new(uri: "http://www.sanofi.com/C66769/V1#C66769")
      ]
      check_against(["C66784", "C87162", "C66768", "C66769"], expected, @ct_26)
      expected = 
      [
        Uri.new(uri: "http://www.sanofi.com/C66768/V1#C66768"),
        Uri.new(uri: "http://www.sanofi.com/C66769/V1#C66769")
      ]
      check_against(["C66768", "C66769"], expected, @ct_30)
    end


    let :run_rake_task do
      Rake::Task["sponsor_one:rank_data"].reenable
      Rake.application.invoke_task "sponsor_one:rank_data"
    end

    it 'adds rank data' do
      # Definitions, check triple store count
      expected = 1130 + 778 + 153 - 2 # Number of extra triples, minus is for overwrite triples in files
      base = triple_store.triple_count
      expect(base).to eq(1349794)

      # Old triples check
      check_old

      # Run migration
      run_rake_task

      # Check results
      expect(triple_store.triple_count).to eq(base + expected)
      check_updated
      check_new

    end

    it "won't run second time" do
      mark_done
      expect{run_rake_task}.to raise_error(SystemExit, "Data migration not required")
    end

    it 'add rank data, exception upload' do
      # Definitions, check triple store count
      base = triple_store.triple_count
      expect(base).to eq(1349794)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Upload).to receive(:send).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Data migration error, step: 1/)
        
      # Check triple count, no change and updated triples, should still be old version
      expect(triple_store.triple_count).to eq(base)
      check_old
    end

    it 'add rank extensions, exception update' do
      # Definitions, check triple store count
      expected = 1130 + 778 + 153 - 2 # Number of extra triples, minus is for overwrite triples in files
      base = triple_store.triple_count
      expect(base).to eq(1349794)

      # Old triples check
      check_old

      # Run migration
      expect_any_instance_of(Sparql::Update).to receive(:sparql_update).and_raise("ERROR")
      expect{run_rake_task}.to raise_error(SystemExit, /Data migration error, step: 2/)
        
      # Check triple count, no change, updated triples should still be old and new triples 
      # should be present
      expect(triple_store.triple_count).to eq(base + expected)
      check_old
    end

  end

end