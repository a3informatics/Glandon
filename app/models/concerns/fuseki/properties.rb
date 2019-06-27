# Fuseki Properties. Handles access to the class properties
#
# @author Dave Iberson-Hurst
# @since 2.22.0
module Fuseki
  
  module Properties

    def self.included(base)
      base.extend(ClassMethods)
    end

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

      def properties_metadata_class
        properties_inherit
        properties_scoped(self)
      end

      def properties_scoped(scope)
        if scope.instance_variable_defined?(:@_properties)
          return scope.instance_variable_get(:@_properties)
        else
          return scope.instance_variable_set(:@_properties, Fuseki::PropertiesMetadata.new(self, scope.instance_variable_get(:@properties)))
        end      
      end

    end

    def properties_read_instance
      self.class.instance_variable_get(:@properties)
    end

    def properties_metadata
      self.class.properties_scoped(self.class)
    end

  end

  # Class that provides controlled access to the properties
  class PropertiesMetadata

    # Initialize
    #
    # @param [Object] ref the class to which the properties belong (the parent)
    # @param [Hash] metadata the metadata structure.
    def initialize(ref, metadata)
      @parent = ref
      @metadata = metadata
    end

    # Relationships
    # 
    # @return [Array] array of hash each containing the predicate and class for the class' relationships
    def relationships
      @metadata.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class]}}
    end

    # Excluded Relationships
    # 
    # @return [Array] array of hash each containing the predicate of any relationships marked to be excluded
    def excluded_relationships
      result = @metadata.select{|x,y| y[:type]==:object && y[:path_exclude]}.map{|x,y| y[:predicate].to_ref}
      result.join("|")
    end

    # Managed Paths
    # 
    # @return [Array] array of strings each being the path (SPARQL) from the class to form a managed item
    def managed_paths(stack=[])
      top = true if stack.empty?
      result = []
      predicates = @metadata.select{|x,y| y[:type]==:object}.map{|x,y| {predicate: y[:predicate], model_class: y[:model_class], exclude: y[:path_exclude]}}
      predicates.each do |predicate| 
        stack = [] if top
        next if predicate[:exclude]
        klass = predicate[:model_class].constantize
        next if stack.include?(klass)
        stack.push(klass)
        children = klass.properties_metadata_class.managed_paths(stack)
        children.empty? ? result << "#{predicate[:predicate].to_ref}" : children.each {|child| result << "#{predicate[:predicate].to_ref}|#{child}"}
      end
      result
    end

    # Klass
    # 
    # @return [Class] the class for a given property
    def klass(property_name)
      @metadata[property_name][:model_class].constantize
    end

    # Cardinality
    # 
    # @return [Symbol] the cardinality for the specified property, either :one or :many
    def cardinality(property_name)
      @metadata[property_name][:cardinality]
    end

    # Predicate
    # 
    # @return [Uri] the predicate for the property
    def predicate(property_name)
      @metadata[property_name][:predicate]
    end

    # Object?
    # 
    # @return [Boolean] true if the property is an object property, false otherwise (data property)
    def object?(property_name)
      @metadata[property_name][:type] == :object
    end

    # ---------
    # Test Only
    # ---------
    if Rails.env.test?

      def metadata
        @metadata
      end

      def parent
        @parent
      end

    end

  end

end