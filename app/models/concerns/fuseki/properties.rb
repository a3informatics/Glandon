# Fuseki Resource. Handles the methods to create properties in a class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Properties

    extend ActiveSupport::Concern

    module ClassMethods

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

      def properties_read_class
        properties_inherit
        self.instance_variable_get(:@properties)
      end

      def properties_metadata
        properties_inherit
        properties_scoped(self)
      end

      def properties_scoped(scope)
        if scope.instance_variable_defined?(:@_properties)
          return scope.instance_variable_get(:@_properties)
        else
          return scope.instance_variable_set(:@_properties, PropertiesMetadata.new(scope.instance_variable_get(:@properties)))
        end      
      end

    end

    def properties_read_instance
      self.class.instance_variable_get(:@properties)
    end

    def properties_metadata
      self.class.properties_scoped(self.class)
    end

    class PropertiesMetadata

      def initialize(metadata)
        @metadata = metadata
      end

      def relationships
        @metadata.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class]}}
      end

      def klass(property_name)
        @metadata[property_name][:model_class].constantize
      end

      def cardinality(property_name)
        @metadata[property_name][:cardinality]
      end

      def predicate(property_name)
        @metadata[property_name][:predicate]
      end

      def object?(property_name)
        @metadata[property_name][:type] == :object
      end

    end

  end

end