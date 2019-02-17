# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    include Fuseki::Persistence::Property

    module ClassMethods

      # Find
      #
      # @param [UriV4|id] the identifier, either a URI or the id
      # @return [Object] a class object.
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

      #def where(properties)
      #  sparql = Sparql::Query.new()
      #  query_string = "SELECT ?s ?p ?o WHERE {" +
      #    "  ?s rdf:type #{@rdf_type.to_ref} ."
      #  properties.each do |property|
      #    qruery_string += "  ?s (#{uri.to_ref} as ?s) ." +
      #    "}"
      #  end
      #  results = Sparql::Query.new.query(query_string, uri.namespace, [])
      #end

    end

    def id
      self.uri.to_id
    end

    def create
      sparql = Sparql::Update.new()
      sparql.default_namespace(@uri.namespace)
      properties = self.class.instance_variable_get(:@properties)
      instance_variables.each do |name|
        next if name == :@uri
        next if !properties.key?(name) # Ignore variables if no property declared.
        predicate = properties[name][:predicate]
        object = instance_variable_get(name)
byebug
        sparql.add({:uri => @uri}, {:uri => predicate}, object)
      end
  byebug
    end

  end

end