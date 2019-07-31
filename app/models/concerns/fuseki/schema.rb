module Fuseki
  
  module Schema
  
    def set_schema
      # Note: Set as a class instance base, won't be inherited. 
      if !Fuseki::Base.instance_variable_defined?(:@schema) || Fuseki::Base.instance_variable_get(:@schema).nil?
puts "***** READING SCHEMA *****"
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
        Fuseki::Base.instance_variable_set(:@schema, SchemaMap.new(results.by_subject))
      end
    end

    # Access method
    def schema_metadata
      Fuseki::Base.instance_variable_get(:@schema)
    end

    class SchemaMap

      def initialize(results)
        @map = Hash.new {|h,k| h[k] = {}}
        extract = 
        [ 
          { uri: "http://www.w3.org/2000/01/rdf-schema#label", field: :label, store: :uri },
          { uri: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", field: :rdf_type, store: :uri },
          { uri: "http://www.w3.org/2000/01/rdf-schema#range", field: :range, store: :uri },
          { uri: "http://www.w3.org/2000/01/rdf-schema#range", field: :datatype, store: :fragment },
          { uri: "http://www.w3.org/2000/01/rdf-schema#domain", field: :domain, store: :uri },
        ]
        results.each do |predicate, parts|
          parts.each do |triple|
            extract.each do |e|
              next if triple[:predicate].to_s != e[:uri]
              @map[predicate][e[:field]] = e[:store] == :uri ? triple[:object] : triple[:object].fragment
            end
          end
        end
      end

      def type(predicate)
        @map[predicate.to_s][:rdf_type]
      end

      def range(predicate)
        @map[predicate.to_s][:range]
      end

      def datatype(predicate)
        @map[predicate.to_s][:datatype]
      end

    end

  end
  
end