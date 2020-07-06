require 'rails_helper'
require 'rake'

describe 'R3.1.0 schema migration' do
 
  before :all do
    Rails.application.load_tasks  
  end

  def sub_dir
    return "tasks/r3_1_0/update"
  end

  describe 'schema and data' do
    
    before :all do
      clear_triple_store
      load_local_file_into_triple_store(sub_dir, "database.nq.gz")
      Rake::Task['r3_1_0:schema'].invoke
      Rake::Task['r3_1_0:data'].invoke
    end

    def check_subsets
      owner = IsoRegistrationAuthority.owner
      query_string = %Q{
        SELECT ?cl ?cli WHERE {
          ?cl rdf:type th:ManagedConcept .
          ?cl th:subsets ?source .
          {?cl th:narrower ?cli} MINUS {?cl th:refersTo ?cli}
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_object_set([:cl, :cli]).each do |r|
        puts colourize("CL: #{r[:cl]}, CLI:#{r[:cli]}")
      end
      query_results.empty?
    end

    def check_extensions
      owner = IsoRegistrationAuthority.owner
      query_string = %Q{
        SELECT ?cl ?cli WHERE {
          ?cl rdf:type th:ManagedConcept .
          ?cl th:extends ?source .
          ?cl th:refersTo ?cli .
          ?cli ^th:narrower ?parent .
          FILTER (EXISTS {?parent isoT:hasIdentifier/isoI:hasScope <http://www.assero.co.uk/NS#CDISC>})
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_object_set([:cl, :cli]).each do |r|
        puts colourize("CL: #{r[:cl]}, CLI:#{r[:cli]}")
      end
      query_results.empty?
    end

    def check_references
      owner = IsoRegistrationAuthority.owner
      query_string = %Q{
        SELECT ?cl ?cli WHERE {
          ?cl rdf:type th:ManagedConcept .
          ?cl th:refersTo ?cli .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      results = query_results.by_object_set([:cl, :cli])
      results.each do |r|
        puts colourize("CL: #{r[:cl]}, CLI:#{r[:cli]}")
      end
      results.any?
    end

    it 'check subsets' do
      expect(check_subsets).to be(true)
    end

    it 'check extensions' do
      expect(check_subsets).to be(true)
    end

    it 'check references' do
      expect(check_references).to be(true)
    end

  end

end