# Fuseki Utility. Utility functions for classes
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Extension

    include Fuseki::Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

    end

    def add_extension(name, datatype, label, definition)
      sparql = Sparql::Update.new
      uri = Uri.new(namespace: self.class.rdf_type.namespace, fragment: "#{name}")
      add_extension_definition(sparql, uri, name, datatype, label, definition)
    end

  private

    def add_extension_definition()
      sparql.add({uri: uri}, {prefix: :rdf, fragment: "type"}, {prefix: :owl, fragment: "DatatypeProperty" })
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "domain"}, {uri: self.class.rdf_type.namespace})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "range"}, {uri: datatype})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "label"}, {{literal: "#{datatype.to_literal(label)}", primitive_type: "string"}})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "definition"}, {{literal: "#{datatype.to_literal(definition)}", primitive_type: "string"}})
    end

    def add_extension_defaults()
      sparql_query = %Q{
        INSERT { ?s  #{uri.to_ref} "#{default_value}"} 
        WHERE { ?s rdf:type #{self.class.rdf_type.to_ref} }
      }
    end

    def delete_extension_value()
      sparql_query = %Q{
        DELETE { ?s  #{uri.to_ref} "#{default_value}"} 
        WHERE { ?s rdf:type #{self.class.rdf_type.to_ref} }
      }
    end

  end

end