# Fuseki Metadata Property. Handles setting of a single property. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Resource

    # Class that provides controlled access to the properties
    class Properties

      include Enumerable

      # Initialize
      #
      # @param [Object] ref the class to which the properties belong (the parent)
      # @param [Hash] metadata the metadata structure.
      def initialize(ref, metadata)
        @parent = ref
        @metadata = metadata
      end

      def ignore?(name)
        !@metadata.key?(name)
      end

      def property(name)
        Fuseki::Resource::Property.new(@parent, name, @metadata[name])
      end

      def property_from_triple(triple)
        return nil if triple[:predicate].to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" # Ignore rdf:type, set by the class and fixed.
        name = "#{triple[:predicate].fragment.underscore}".to_sym
        return nil if ignore?(name) # We don't know about this predicate ... can happen if we are assigning to a super class
        object = Fuseki::Resource::Property.new(@parent, name, @metadata[name])
        object.set_value(triple[:object])
        object
      end

      def each
        @metadata.each {|key, value| yield(Fuseki::Resource::Property.new(@parent, key, value))}
      end

      def raw
        @metadata
      end

      # ---------
      # Test Only
      # ---------
      if Rails.env.test?

        def parent
          @parent
        end

      end

    end

  end

end
