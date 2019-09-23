# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Where


    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Search Current. Search the current set. 
      # 
      # @param params [Hash] the hash sent by datatables for a search.
      # @return [Array] objects found
      def where_children_current(params)
        where_children_multiple(params, self.current_set)
      end

      # Search Multiple
      # 
      # @param params [Hash] the hash of properties for a search.
      # @param uris [Array] an array of URIs of the items to be searched.
      # @return [Array] objects found
      def where_children_multiple(params, uris)
        objects = []
        query_results = Sparql::Query.new.query(where_query_string(params, uris), "", [:bo, :th])
        map = query_results.subject_map
        query_results.by_subject.each do |subject, triples|
          objects << map[subject.to_s].constantize.from_results(Uri.new(uri: subject), triples)
        end
        objects
      end

    private

      # Build the search query string
      def where_query_string(params, uris)
        %Q{
          SELECT DISTINCT ?s ?p ?o ?e WHERE
          {
            VALUES ?th { #{uris.map{|x| x.to_ref}.join(" ")} }
            ?th th:isTopConceptReference/bo:reference ?mc .
            {
                {
                  ?mc th:narrower+ ?s .
                  #{property_triples(params, Thesaurus::ManagedConcept)}
                  BIND ("Thesaurus::ManagedConcept" as ?e)
                } UNION
                {
                  BIND (?mc as ?s)
                  #{property_triples(params, Thesaurus::UnmanagedConcept)}
                  BIND ("Thesaurus::UnmanagedConcept" as ?e)
                }
            }
            ?s ?p ?o .
          }}
      end
    
      # Build the property search triples
      def property_triples(params, parent)
        triples = []
        properties = Fuseki::Resource::Properties.new(nil, parent.resources)
        params.each do |name, value|
          next if properties.property(name).object?
          predicate = properties.property(name).predicate
          literal = self.schema_metadata.datatype(predicate) == BaseDatatype.to_xsd(BaseDatatype::C_STRING) ? value.dup.inspect.trim_inspect_quotes : value
          triples << "  ?s #{predicate.to_ref} \"#{literal}\"^^xsd:#{self.schema_metadata.datatype(predicate)} ."
        end
        triples.join("\n")
      end

    end

    # Search. 
    # 
    # @param params [Hash] the hash of properties for a search.
    # @return [Array] objects found
    def where_children(params)
      self.class.where_children_multiple(params, [self.uri])
    end

  end

end