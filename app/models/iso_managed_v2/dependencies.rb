# ISO Managed V2. New module to handle dependencies
# @author Dave Iberson-Hurst
# @since 3.6.0
class IsoManagedV2

  module Dependencies
    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Dependency Paths. Returns the paths for any dependencies this class may have.
      #
      # @raise [Errors::ApplicationLogicError] raised to indicate the class has not configured the method
      # @return [Array] array of strings suitable for inclusion in a sparql query
      def dependency_paths
        Errors.application_error(self.name, __method__.to_s, "Method not implemented for class.")
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Dependency Required By. Return the info for the managed items that require this managed item.
    #
    # @return [Array] array of MI minimum info of the managed items using this managed item
    def dependency_required_by
      parts = []
      results = []
      paths = paths_for_klass
      return results if paths.empty?
      base = "  { #{paths.map {|p| "{ ?e #{p} #{self.uri.to_ref}}"}.join(" UNION")} }"
      parts << "  { ?e rdf:type ?o . BIND (rdf:type as ?p) BIND (?e as ?s) }"
      parts << "  { ?e ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?e as ?s) }"
      parts << "  { ?e isoT:hasIdentifier ?s . ?s ?p ?o }"
      parts << "  { ?e isoT:hasState ?s . ?s ?p ?o }"
      query_string = "SELECT ?s ?p ?o ?e WHERE { { #{base} #{parts.join(" UNION\n")} }}"
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
      by_subject = query_results.by_subject
      query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
        object = IsoManagedV2.from_results_recurse(uri, by_subject)
        object.has_identifier.has_scope = IsoNamespace.find(object.has_identifier.has_scope)
        object.has_state.by_authority = IsoRegistrationAuthority.find(object.has_state.by_authority)
        object.has_state.by_authority.ra_namespace = IsoNamespace.find(object.has_state.by_authority.ra_namespace)
        results << object
      end
      results
    end

  private

    # Get the dependency paths for the class
    def paths_for_klass
      paths = []
      klasses = dependency_configuration[self.class.to_s.to_sym]
      klasses.each { |x| paths += x.constantize.dependency_paths}
      paths  
    end

    # Get the dependency configuiration
    def dependency_configuration
      Rails.configuration.dependencies
    end

  end
  
end
