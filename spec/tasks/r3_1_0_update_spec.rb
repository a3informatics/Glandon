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
          ?cl rdf:type th:ManagedConcept
          ?cl subsets ?source
          {?cl th:narrower ?cli} MINUS {?cl th:refersTo ?cli}
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.each do |r|
        puts colourize("CL: #{r[:cl]}, CLI:#{r[:cli]}")
      end
      query_results.empty?
    end

    it 'check subsets' do
      expect(check_subsets).to be(true)
    end

    it 'check extensions' do
    end

  end

end