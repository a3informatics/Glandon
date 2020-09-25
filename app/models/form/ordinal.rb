class Form
  
  module Ordinal
    
    def reset_ordinals(parent)
      string_uris = ""
      uris_ordered(parent).each_with_index do |s, index|
        string_uris += "#{s.to_ref} bf:ordinal #{index+1} . "
      end
      query_string = %Q{
        DELETE 
        { ?s bf:ordinal ?x . }
        INSERT
        { #{string_uris} }
        WHERE 
        { ?s bf:ordinal ?x . }
      }
      results = Sparql::Update.new.sparql_update(query_string, "", [:bf])
    end

    def uris_ordered(parent)
      query_string = %Q{
        SELECT ?s WHERE {
          #{parent.uri.to_ref} bf:hasItem ?s. ?s bf:ordinal ?ordinal .
        } ORDER BY ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:s)
    end

  end

end