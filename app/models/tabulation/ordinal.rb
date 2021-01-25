# Tabulation ordinal. Mixin to handle ordinal actions
#
# @author Clarisa Romero
# @since 3.2.0
class Tabulation
  
  module Ordinal
    
    # Reset Ordinals. Reset the ordinals within the enclosing parent
    #
    # @return [Boolean] true if reordered, false otherwise.
    def reset_ordinals
      local_uris = uris_by_ordinal
      return false if local_uris.empty?
      string_uris = {delete: "", insert: "", where: ""}
      local_uris.each_with_index do |s, index|
        string_uris[:delete] += "#{s.to_ref} bd:ordinal ?x#{index} . "
        string_uris[:insert] += "#{s.to_ref} bd:ordinal #{index+1} . "
        string_uris[:where] += "#{s.to_ref} bd:ordinal ?x#{index} . "
      end
      query_string = %Q{
        DELETE 
          { #{string_uris[:delete]} }
        INSERT
          { #{string_uris[:insert]} }
        WHERE 
          { #{string_uris[:where]} }
      }
      results = Sparql::Update.new.sparql_update(query_string, "", [:bd])
      true
    end

  private

    # Return URIs of the children objects ordered by ordinal
    def uris_by_ordinal
      query_string = %Q{
        SELECT ?s WHERE {
          #{self.uri.to_ref} bd:includesColumn ?s . 
          ?s bd:ordinal ?ordinal .
        } ORDER BY ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      query_results.by_object(:s)
    end

  end

end