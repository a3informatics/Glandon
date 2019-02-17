# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Properties

    include Fuseki::Naming

    def properties_inherit
      merged = {}
      klass_ancestors = self.class.ancestors.grep(Fuseki::Resource).reverse
      klass_ancestors.delete(Fuseki::Base) # Remove the base class
      klass_ancestors.each {|klass| merged.merge!(klass.instance_variable_get(:@properties))}
      self.class.instance_variable_set(:@properties, merged)
      self.class.instance_variable_get(:@properties).each {|name, value| self.instance_variable_set(name, value[:default])}
    end

    def properties_predicate
      properties = self.class.instance_variable_get(:@properties)
      type = properties[:@rdf_type][:default]
      properties.each do |name, entry|
        next if name == :@rdf_type
        properties[name][:predicate] = Uri.new(namespace: type.namespace, fragment: to_schema(name))
      end
      properties = self.class.instance_variable_set(:@properties, properties)
    end

  end

end