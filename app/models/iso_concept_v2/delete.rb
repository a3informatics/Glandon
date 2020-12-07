# ISO Concept V2. New module to handle deletion
# @author Dave Iberson-Hurst
# @since 3.4.0
class IsoConceptV2

  module Delete

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # ----------------
    # Instance Methods
    # ----------------

    # Delete References. It is assumed the node is being deleted. Covers Custom Properties and Tags
    #
    # @return [Boolean] always returns true
    def delete_references
      query_string = "DELETE { ?s ?p ?o } WHERE { #{uri.to_ref} ^isoC:appliesTo ?s . ?s ?p ?o }"
      results = Sparql::Update.new.sparql_update(query_string, uri.namespace, [:isoC])
      true
    end

    # Delete or Unlink References. Delete or Unlink any custom properties or tags
    #
    # @param [Object] context the context within which the properties are to be deleted
    # @return [true] returns true
    def delete_or_unlink_references(context)
      context_uri = context.is_a?(Uri) ? context : context.uri
      query_string = %Q{
        DELETE
        {
          ?s ?p ?o
        }
        WHERE 
        {            
          FILTER (?count = 1)
          {
            ?s isoC:context #{context_uri.to_ref} . 
          }
          UNION
          {
            ?s isoC:context #{self.uri.to_ref} . 
          }
          ?s ?p ?o .
          {
            SELECT ?s (count(?o) as ?count) WHERE
            {
              ?s isoC:appliesTo #{self.uri.to_ref} .          
              ?s isoC:context ?o
            } GROUP BY ?s  
          }
        };   
        DELETE
        {
          ?s isoC:context #{context_uri.to_ref}
        }
        WHERE 
        {            
          FILTER (?count > 1)
          ?s isoC:context #{context_uri.to_ref} . 
          {
            SELECT ?s (count(?o) as ?count) WHERE 
            {
              ?s isoC:appliesTo #{self.uri.to_ref} .          
              ?s isoC:context ?o
            } GROUP BY ?s
          }
        }
      }
      Sparql::Update.new.sparql_update(query_string, uri.namespace, [:isoC])
      true
    end

  end

end
