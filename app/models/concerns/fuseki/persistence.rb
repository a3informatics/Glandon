# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    include Fuseki::Persistence::Property
    include Fuseki::Naming

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

=begin
      def where(params)
        properties = self.instance_variable_get(:@properties)
        schema = self.read_schema
        sparql = Sparql::Query.new()
        query_string = "SELECT ?s ?p ?o WHERE {" +
          "  ?s rdf:type #{properties[:@rdf_type][:default].to_ref} ."
        params.each do |name, value|
          predicate = properties["@#{name}".to_sym][:predicate]
          query_string += "  ?s #{predicate.to_ref} \"#{value}\"^^xsd:#{schema.range(predicate)} ." +
          "  ?s ?p ?o ." +
          "}"
        end
        results = Sparql::Query.new.query(query_string, "", [])
        raise Exceptions::NotFoundError.new("Failed to find where #{params} in #{self.class.name} object.") if results.empty?
        subject = results.by_subject
        from_results(subject.values.first.first[:subject], subject)
      end
=end

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

    def create
      create_or_update(:create)
    end

    def update
      create_or_update(:update)
    end

  private

    def create_or_update(operation)
      sparql = Sparql::Update.new()
      sparql.default_namespace(@uri.namespace)
      properties = self.class.instance_variable_get(:@properties)
      schema = self.class.class_variable_get(:@@schema)
      sparql.add({uri: @uri}, {prefix: :rdf, fragment: "type"}, {uri: @rdf_type})
      instance_variables.each do |name|
        next if name == :@uri || name == :@rdf_type
        next if !properties.key?(name) # Ignore variables if no property declared.
        property_to_triple(sparql, properties[name], schema, @uri, properties[name][:predicate], instance_variable_get(name))
      end
      operation == :create ? sparql.create : sparql.update(@uri)
    end

    def property_to_triple(sparql, property, schema, subject, predicate, objects)
      objects = [objects] if !objects.is_a? Array
      objects.each do |object|
        statement = object.is_a?(Uri) ? {uri: object} : {literal: "#{object}", primitive_type: schema.range(predicate)}
        sparql.add({:uri => subject}, {:uri => predicate}, statement)
      end
    end

  end


end