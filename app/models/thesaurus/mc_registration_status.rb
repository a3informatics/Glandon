# Thesaurus Custom Property
#
# @author Dave Iberson-Hurst
# @since 3.4.0
class Thesaurus

  module McRegistrationStatus

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # Update Status Dependent Items. The depedent items that we could update. Default method always return no items.
    #
    # @return [Array] array of items, default is just self
    def update_status_dependent_items(operation)
      results = []
      query_string = %Q{
        SELECT ?s ?p ?o ?e WHERE
        {
          #{self.uri.to_ref} (^th:subsets|^th:extends) ?e
          {
            {
              ?e rdf:type ?o . 
              BIND (#{Fuseki::Base::C_RDF_TYPE.to_ref} as ?p)
              BIND (?e as ?s)
            }
            UNION
            {
              ?e ?p ?o .
              FILTER (strstarts(str(?p), "http://www.assero.co.uk/ISO11179"))
              BIND (?e as ?s)
            }
            UNION
            {
              ?e isoT:hasIdentifier ?s .
              ?s ?p ?o .
            }
            UNION
            {
              ?e isoT:hasState ?s .
              ?s ?p ?o
            }
          }
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT, :bo, :th])
      by_subject = query_results.by_subject
      query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
        item = IsoManagedV2.from_results_recurse(uri, by_subject)
        ns_uri = item.has_identifier.has_scope
        item.has_identifier.has_scope = IsoNamespace.find(ns_uri)
        ra_uri = item.has_state.by_authority
        item.has_state.by_authority = IsoRegistrationAuthority.find(ra_uri)
        ns_uri = item.has_state.by_authority.ra_namespace
        item.has_state.by_authority.ra_namespace = IsoNamespace.find(ns_uri)
        results << item
      end
      results    
    end

  end

end