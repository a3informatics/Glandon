# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Properties

    def properties_inherit
      merged = {}
      klass_ancestors = self.ancestors.grep(Fuseki::Resource).reverse
      klass_ancestors.delete(Fuseki::Base) # Remove the base class
      klass_ancestors.each {|klass| merged.merge!(klass.instance_variable_get(:@properties))}
      self.instance_variable_set(:@properties, merged)
    end

    # Move to persistence
    #def properties_predicate
    #  properties = self.instance_variable_get(:@properties)
    #  type = self.rdf_type
    #  properties.each do |name, entry| 
    #    property_name = Fuseki::Persistence::Naming.new(name)
    #    properties[name][:predicate] = Uri.new(namespace: type.namespace, fragment: property_name.as_schema)
    #  end
    #  properties = self.instance_variable_set(:@properties, properties) # @todo Required? Check.
    #end

    def properties_read(scope)
      base = scope == :class ? self : self.class
      if scope == :class
        base.properties_inherit
        #base.properties_predicate
      end
      base.instance_variable_get(:@properties)
    end

  end

end