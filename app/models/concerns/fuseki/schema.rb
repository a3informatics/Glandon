module Fuseki
  
  module Schema
  
    def get_schema(source)
      if !Fuseki::Base.class_variable_defined?(:@@schema) || Fuseki::Base.class_variable_get(:@@schema).nil?
puts "***** READING SCHEMA #{source} *****"
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
        Fuseki::Base.class_variable_set(:@@schema, SchemaMap.new(results.by_subject))
      end
      Fuseki::Base.class_variable_get(:@@schema)
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

  end
  
end