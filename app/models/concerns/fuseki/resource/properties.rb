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

      def property(name)
        Fuseki::Resource::Property.new(@parent, name, @metadata[name])
      end

      def property_from_triple(triple)
        name = "#{triple[:predicate].fragment.underscore}".to_sym
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
