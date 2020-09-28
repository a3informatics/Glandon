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

    def add_extension(name, datatype, label, definition, default)
      sparql = Sparql::Update.new
      uri = Uri.new(namespace: self.class.rdf_type.namespace, fragment: "#{name}")
      add_extension_definition(sparql, uri, datatype, label, definition, default)
    end

  private

    def add_extension_definition(sparql, uri, datatype, label, definition, default)
      sparql.add({uri: uri}, {prefix: :rdf, fragment: "type"}, {prefix: :owl, fragment: "DatatypeProperty" })
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "domain"}, {uri: self.class.rdf_type})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "range"}, {uri: datatype.to_uri.to_ref})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "label"}, {{literal: label, primitive_type: XSDDatatype.string}})
      sparql.add({uri: uri}, {prefix: :rdfs, fragment: "definition"}, {{literal: "definition}", primitive_type: XSDDatatype.string}})
      sparql.add({uri: uri}, {prefix: :isoC, fragment: "extensionPropertyDefaultValue"}, {{literal: "#{datatype.to_literal(default)}", primitive_type: datatype}})
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