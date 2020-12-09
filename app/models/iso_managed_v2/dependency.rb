# ISO Managed V2. New module to handle dependencies
# @author Dave Iberson-Hurst
# @since 3.6.0
class IsoManagedV2

  module Delete

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Dependency Paths. Returns the paths for any dependencies this class
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

    # Dependency Required By. Return the URIs of the managed items that require this managed item.
    #
    # @return [Array] array of URIs of the managed items using this managed item
    def dependency_required_by
      results = []
      paths = paths_for_klass
      base = "  { #{paths.each {|p| "{ ?uri #{p} #{self.uri.to_ref}}"}.join(\" UNION\")} }"
      parts << "  { ?uri rdf:type ?o . BIND (#{C_RDF_TYPE.to_ref} as ?p) BIND (?uri as ?s) }"
      parts << "  { ?uri  ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?uri as ?s) }"
      parts << "  { ?uri  isoT:hasIdentifier ?s . ?s ?p ?o }"
      parts << "  { ?uri  isoT:hasState ?s . ?s ?p ?o }"
      query_string = "SELECT ?s ?p ?o ?e WHERE { { #{base} #{parts.join(" UNION\n")} }}"
      query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
      by_subject = query_results.by_subject
      query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
        item = from_results_recurse(uri, by_subject)
        set_cached_scopes(item, params[:scope])
        results << item
      end
      results
    end

  private

    def paths_for_klass
      paths = []
      klasses = dependency_configuration[self.class]
      klasses.each do { |x| paths += x.constantize.dependency_paths}
      paths  
    end

    def dependency_configuration
      Rails.configuration.dependency
    end

  end
  
end
