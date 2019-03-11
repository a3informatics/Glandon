# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern
    include Fuseki::Persistence::Property
    include Fuseki::Properties

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
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        from_results(uri, results.by_subject[uri.to_s])
      end

      # Find
      #
      # @param [UriV4|id] the identifier, either a URI or the id
      # @return [Object] a class object.
      def find_children(id)
        parts = [0]
        klass_map = {}
        uri = id.is_a?(Uri) ? id : Uri.new(id: id)
        schema = self.read_schema
        properties = properties_read(:class)
        parts[0] = "  { #{uri.to_ref} ?p ?o .  BIND (#{uri.to_ref} as ?s) . BIND ('#{self.name}' as ?e) }" 
        properties.each do |name, value|
          #next if name == :@rdf_type
          next if properties[name][:type] != :object
          klass = properties[name][:model_class]
          klass_map[klass] = properties[name]
          predicate = properties[name][:predicate]
          parts << "  { #{uri.to_ref} #{predicate.to_ref} ?ref .  BIND (?ref as ?s) .  BIND ('#{klass}' as ?e) .  ?ref ?p ?o . }"
        end
        query_string = "SELECT ?s ?p ?o ?e WHERE { #{parts.join(" UNION\n")} }"
        results = Sparql::Query.new.query(query_string, uri.namespace, [])
        raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
        objects = []
        map = results.subject_map
        parent = from_results(uri, results.by_subject[uri.to_s])
        results.by_subject.each do |subject, triples|
          next if subject == parent.uri.to_s
          klass = map[subject.to_s].constantize
          properties = klass_map[klass.name]
          name = properties[:name]
          object = klass.new.class.from_results(Uri.new(uri: subject), triples)
          properties[:cardinality] == :one ? parent.instance_variable_set("@#{name}".to_sym, object) : parent.instance_variable_get("@#{name}".to_sym).push(object)
        end
        parent
      end

      def where(params)
        schema = self.read_schema
        properties = properties_read(:class)
        sparql = Sparql::Query.new()
        query_string = "SELECT ?s ?p ?o WHERE {" +
          "  ?s rdf:type #{rdf_type.to_ref} ."
        params.each do |name, value|
          predicate = properties["@#{name}".to_sym][:predicate]
          query_string += "  ?s #{predicate.to_ref} \"#{value}\"^^xsd:#{schema.range(predicate)} ."
        end
        query_string += "  ?s ?p ?o ."
        query_string += "}"
        results = Sparql::Query.new.query(query_string, "", [])
        objects = []
        results.by_subject.each do |subject, triples|
          objects << from_results(Uri.new(uri: subject), triples)
        end
        objects
      end

      def where_only(params)
        Errors.application_error(C_CLASS_NAME, __method__.to_s, "Multiple properties specified.") if params.count != 1
        results = where(params)
        return nil if results.empty?
        Errors.application_error(C_CLASS_NAME, __method__.to_s, "Multiple objects found for #{params}.") if results.count > 1
        return results.first
      end

      # Find all objects
      #
      # @return [Array] Array of objects
      def all
        where({})
      end

      def create(params)
        object = new(params)
        object.create_or_update(:create) if object.valid?(:create)
        object
      end

      def object_results(query_string, params)
        default_namespace = params.key?(:default_namespace) ? params[:default_namespace] : ""
        prefixes = params.key?(:prefixes) ? params[:prefixes] : []
        Sparql::Query.new.query(query_string, default_namespace, prefixes)
      end

      def from_results(uri, triples)
        object = new
        object.instance_variable_set("@uri", uri)
        triples.each do |triple|
          next if triple[:predicate].to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          object.from_triple(triple)
        end
        object
      end

    end

    def id
      self.uri.nil? ? nil : self.uri.to_id
    end

    def update
      create_or_update(:update) if valid?(:update)
    end

    def delete
      Sparql::Update.new.delete(self.uri)
    end

    def generic_objects(name, klass)
      objects = []
      properties = properties_read(:instance)
      predicate = properties["@#{name}".to_sym][:predicate]  
      klass = properties["@#{name}".to_sym][:model_class].constantize
      cardinality = properties["@#{name}".to_sym][:cardinality]
      sparql = Sparql::Query.new()
      query_string = "SELECT ?s ?p ?o WHERE {" +
          "  #{uri.to_ref} #{predicate.to_ref} ?s ." +
          "  ?s ?p ?o ." +
          "}"
      results = Sparql::Query.new.query(query_string, "", [])
      objects = []
      results.by_subject.each do |subject, triples|
        objects << klass.new.class.from_results(Uri.new(uri: subject), triples)
      end
      cardinality == :one ? instance_variable_set("@#{name}".to_sym, objects.first) : instance_variable_set("@#{name}".to_sym, objects)
      objects
    end

    def generic_objects?(name)
      !uri?("@#{name}".to_sym)
    end

    def create_or_update(operation)
      sparql = Sparql::Update.new()
      sparql.default_namespace(@uri.namespace)
      properties = properties_read(:instance)
      schema = self.class.class_variable_get(:@@schema)
      sparql.add({uri: @uri}, {prefix: :rdf, fragment: "type"}, {uri: self.class.rdf_type})
      instance_variables.each do |name|
        next if name == :@uri #|| name == :@rdf_type
        next if !properties.key?(name) # Ignore variables if no property declared.
        property_to_triple(sparql, properties[name], schema, @uri, properties[name][:predicate], instance_variable_get(name))
      end
      operation == :create ? sparql.create : sparql.update(@uri)
      self
    end

  private

    def property_to_triple(sparql, property, schema, subject, predicate, objects)
      objects = [objects] if !objects.is_a? Array
      objects.each do |object|
        statement = object.respond_to?(:uri) ? {uri: object.uri} : {literal: "#{object}", primitive_type: schema.range(predicate)}
        sparql.add({:uri => subject}, {:uri => predicate}, statement)
      end
    end

  end

end