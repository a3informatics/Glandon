module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    include Fuseki::Persistence::Property

    module ClassMethods

      # Find
      #
      # @param [Symbol, ID] scope
      #   scope can be :all, :first or an ID
      # @param [Hash] args
      #   args can contain:
      #     :conditions - Hash of properties and values
      #     :limit      - Fixnum, limiting the amount of returned records
      # @return [Spira::Base, Array]
      def find(id)
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        query_string = "SELECT ?s ?p ?o WHERE {" +
          "  #{uri.to_ref} ?p ?o ." +
          "  BIND (#{uri.to_ref} as ?s) ." +
          "}"
        results = Sparql::Query.new.query(query_string, uri.namespace, [])
        raise Exceptions::NotFoundError.new("Failed to find #{uri} in #{self.class.name} object.") if results.empty?
        from_results(uri, results.by_subject)
      end

      def from_results(uri, results)
        object = new
        object.instance_variable_set("@uri", uri)
        results[uri.to_s].each do |triple|
          next if triple[:predicate].to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          object.set_property(triple)
        end
        object
      end

    end

    def id
      self.uri.to_id
    end

  end

end