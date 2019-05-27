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
      klass_ancestors.each do |klass| 
        props = klass.instance_variable_get(:@properties)
        next if props.nil?
        merged.merge!(props) 
      end
      self.instance_variable_set(:@properties, merged)
    end

    def properties_read(scope)
      base = scope == :class ? self : self.class
      base.properties_inherit if scope == :class
      base.instance_variable_get(:@properties)
    end

    def properties_class
      base.properties_inherit
      properties_scoped(self)
    end

    def properties_instance
      properties_scoped(self.class)
    end

    def properties_scoped(scope)
      if scope.instance_variable_defined?(:@_properties)
        return scope.instance_variable_get(:@_properties)
      else
        return scope.instance_variable_set(:@_properties, PropertiesMap.new(scope.instance_variable_get(:@properties)))
      end      
    end

    class PropertiesMap

      def initialize(map)
        @map = map
      end

      def relationships
        @map.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class]}}
      end

    end


  end

end