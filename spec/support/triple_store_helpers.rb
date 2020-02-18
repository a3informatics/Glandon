module TripleStoreHelpers

  class TripleStore
  
    def clear
      sparql_query = "CLEAR DEFAULT"
      CRUD.update(sparql_query)
      sparql_query = "DROP DEFAULT"
      CRUD.update(sparql_query)
    end

    def check_load
      query_string = %Q{
        SELECT ?o WHERE 
        {
          <http://www.assero.co.uk/ISO11179Identification#Namespace> <http://www.w3.org/2000/01/rdf-schema#label> ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      raise if query_results.empty?
      raise if query_results.by_object(:o).first != "Namespace"
    end

    def rdf_type_count(rdf_type)
      query_string = %Q{
        SELECT (COUNT(?s) as ?count) WHERE 
        {
          ?s rdf:type #{rdf_type.to_ref}
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      result = query_results.by_object(:count).first.to_i
  puts colourize("Count #{rdf_type}=#{result}", "blue")
      result
    end

    def triple_count()
      query_string = %Q{
        SELECT (COUNT(?s) as ?count) WHERE 
        {
          ?s ?p ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      result = query_results.by_object(:count).first.to_i
  puts colourize("Total count=#{result}", "blue")
      result
    end

    def subject_present?(subject)
      query_string = %Q{
        ASK { #{subject.to_ref} ?p ?o }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      result = query_results.ask?
  puts colourize("Present #{subject}=#{result}", "blue")
      result
    end

    def check_uris(set)
      overall_result = true
      set.each do |entry|
        result = triple_store.subject_present?(entry[:uri])
        puts colourize("Present #{entry[:uri]}=#{result}, should be #{entry[:present]}", "red") if result != entry[:present]
        overall_result = overall_result && result == entry[:present]
      end
      overall_result
    end

  end

end
