# ISO Concept V2. Methods for handling of managed ancestors (parent managed items) operations.
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoConceptV2

  module ManagedAncestors
  
    # ----------------
    # Instance Methods
    # ----------------

    # Managed Ancestor URIs. Find all the URIs of the managed ancstors of this concept.
    #
    # @return [Array] Array of hash containing details of the found ancestors
    def managed_ancestor_uris
      query_string = %Q{
        SELECT ?uri ?identifier ?scope ?type WHERE {
          ?component rdfs:subClassOf* bo:Component .  
          ?uri rdf:type ?component .
          ?uri rdf:type ?type .
          ?uri #{self.class.managed_ancestors_path} #{self.uri.to_ref} .
          ?uri isoT:hasIdentifier ?si .
          ?si isoI:identifier ?identifier .
          ?si isoI:hasScope ?scope .
        }
      }
      triples = Sparql::Query.new.query(query_string, "", [:isoT, :isoI, :bo])
      results = triples.by_object_set([:uri, :identifier, :scope, :type])
      results
    end

    # Multipe Managed Ancestors? Are there multiple managed ancestors attached to this concept.
    #
    # @return [Boolean] true if multiple ancestors found, otherwise false
    def multiple_managed_ancestors?
      managed_ancestor_uris.count > 1
    end

    # No Managed Ancestors? Are there no managed ancestors attached to this concept.
    #
    # @return [Boolean] true if no ancestors found, otherwise false
    def no_managed_ancestors?
      managed_ancestor_uris.empty?
    end

    # Managed Ancestors? Are there managed ancestors attached to this concept.
    #
    # @return [Boolean] true if ancestors found, otherwise false
    def managed_ancestors?
      managed_ancestor_uris.any?
    end

  end

end