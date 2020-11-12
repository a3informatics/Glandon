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
          FILTER (EXISTS {?cli ^th:narrower ?parent . FILTER (?cl != parent)})
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
      mapped_results = Hash.new {|h,k| h[k] = []}
      results.each {|x| mapped_results[x[:cl].to_s] << x[:cli].to_s}
      check_file_actual_expected(mapped_results, sub_dir, "update_references_expected_1.yaml", equate_method: :hash_equal)
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

    it 'check examples' do
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/C96784/V1#C96784_S009967"), true)
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/C74456/V1#C74456_S001153"), true)
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/SN003630E/V1#SN003630E_S100257"), true)
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/C66729/V1#C66729_S003258"), true)
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/SN000185/V1#SN000185_S000911"), true)
      triple_store.subject_used_by(Uri.new(uri: "http://www.sanofi.com/C66729/V1#C66729_S003258"), true)
    end

  end

end