module Fuseki
  
  module Persistence
  
    extend ActiveSupport::Concern

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

    def read_schema
      sparql_query = "SELECT ?s ?p ?o WHERE\n" +
        "{\n" +
        "  {\n" + 
        "    ?s rdf:type :ObjectProperty .\n" +
        "    ?s ?p ?o .\n" +
        "  }\n" +
        "  UNION\n" +
        "  {\n" + 
        "    ?s rdf:type :DatatypeProperty .\n" +
        "    ?s ?p ?o .\n" +
        "  }\n" +
        "}"
      results = Sparql::Query.new.query(sparql_query, Uri.namespaces.namespace_from_prefix(:owl), [])
      SchemaMap.new(results.by_subject)
    end

    def id
      self.uri.to_id
    end
    
    def set_property(triple)
      name = rails_name(triple[:predicate].fragment)
      return if set_uri(name, triple)
      set_simple(name, triple)
    end

    def set_uri(name, triple)
      return if !triple[:object].is_a? Uri
      instance_variable_get("@#{name}").push(triple[:object])
    end

    def set_simple(name, triple)
      instance_variable_set("@#{name}", convert_value(triple))
    end

    class SchemaMap

      def initialize(results)
        @map = Hash.new {|h,k| h[k] = {}}
        extract = 
        [ 
          { uri: "http://www.w3.org/2000/01/rdf-schema#label", field: :label },
          { uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", field: :rdf_type },
          { uri: "http://www.w3.org/2000/01/rdf-schema#range", field: :range },
          { uri: "http://www.w3.org/2000/01/rdf-schema#domain", field: :domain },
        ]
        results.each do |predicate, parts|
          parts.each do |triple|
            extract.each do |e|
              @map[predicate][e[:field]] = triple[:object] if triple[:predicate].to_s == e[:uri]
            end
          end
        end
      end

      def type(predicate)
        @map[predicate.to_s][:rdf_type]
      end

      def range(predicate)
        @map[predicate.to_s][:range].fragment
      end

    end

 private

    def convert_value(triple)
      value = triple[:object]
      return value if value.is_a? Uri
      schema = self.class.class_variable_get(:@@schema)
      base_type = schema.range(triple[:predicate])
      if base_type == BaseDatatype.to_xsd(BaseDatatype::C_STRING)
        "#{value}"
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_BOOLEAN)
        value.to_bool
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME)
        value.to_time_with_default
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)
        value.to_i
      elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_POSITIVE_INTEGER)
        value.to_i
      else
        "#{value}"
      end
    end

    def rails_name(name)
      return name.underscore
    end

  end

end