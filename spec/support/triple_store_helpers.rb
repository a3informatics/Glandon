module TripleStoreHelpers

  class TripleStoreAccess
  
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

    def rdf_type_count(rdf_type, terminal_output=false)
      query_string = %Q{
        SELECT (COUNT(?s) as ?count) WHERE 
        {
          ?s rdf:type #{rdf_type.to_ref}
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      result = query_results.by_object(:count).first.to_i
      puts colourize("Count #{rdf_type}=#{result}", "blue") if terminal_output
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

    def subject_present?(subject, terminal_output=false)
      query_string = %Q{
        ASK { #{subject.to_ref} ?p ?o }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      result = query_results.ask?
      puts colourize("Present #{subject}=#{result}", "blue") if terminal_output
      result
    end

    def subject_triples(subject, terminal_output=false)
      query_string = %Q{
        SELECT ?p ?o { #{subject.to_ref} ?p ?o }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      results = query_results.by_object_set([:p, :o])
      puts colourize("Subject #{subject}", "blue") if terminal_output
      results.each{|x| puts colourize("  #{x[:p]}, #{x[:o]}", "blue")} if terminal_output
      results
    end

    def subject_used_by(subject, terminal_output=false)
      query_string = %Q{
        SELECT ?s ?p { ?s ?p #{subject.to_ref} }
      }
      query_results = Sparql::Query.new.query(query_string, "", []) 
      results = query_results.by_object_set([:s, :p])
      puts colourize("Subject #{subject}", "blue") if terminal_output
      results.each{|x| puts colourize("  #{x[:s]}, #{x[:p]}", "blue")} if terminal_output
      results
    end

    def subject_triples_tree(subject)
      query_string = %Q{
        SELECT DISTINCT?s ?p ?o WHERE
        {
          {
            #{subject.to_ref} (:|!:)* ?s .
            ?s ?p ?o 
          }
          UNION
          {
            #{subject.to_ref} ?p ?o
            BIND (#{subject.to_ref} as ?s)
          }
        }
      }
      query_results = Sparql::Query.new.query(query_string, subject.namespace, []) 
      results = query_results.by_object_set([:s, :p, :o])
      puts colourize("Subject #{subject}, count=#{results.count}", "blue")
      results
    end

    def triples_to_subject_hash(triples)
      result = Hash.new {|h, k| h[k] = []}
      triples.map {|triple| result[triple[:s].to_s] << triple}
      result
    end

    def check_uris(set, terminal_output=false)
      overall_result = true
      set.each do |entry|
        result = triple_store.subject_present?(entry[:uri], terminal_output)
        puts colourize("Present #{entry[:uri]}=#{result}, should be #{entry[:present]}", "red") if result != entry[:present]
        overall_result = overall_result && result == entry[:present]
      end
      overall_result
    end

  end

end
