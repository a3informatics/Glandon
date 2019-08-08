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
      # @param ref [Object] the class to which the properties belong (the parent)
      # @param metadata [Hash] the metadata structure.
      # @return [Void] no return
      def initialize(ref, metadata)
        @parent = ref
        @metadata = metadata
      end

      # Ignore. The property has no metadata, so ignore it
      #
      # @param name [String] the name of the property
      # @return [Boolean] true if it does not exists - and can be ignored, false otherwise
      def ignore?(name)
        !@metadata.key?(name)
      end

      # Property. Get the class for an individual property
      #
      # @param name [String] the name of the property
      # @return [Fuseki::Resource::Property] the resulting property
      def property(name)
        Fuseki::Resource::Property.new(@parent, name, @metadata[name])
      end

      # Property From Triple. Set the property valuye from a triple
      #
      # @param triple [Hash] hash containng the triple
      # @return [Fuseki::Resource::Property] the resulting property
      def property_from_triple(triple)
        return nil if triple[:predicate].to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" # Ignore rdf:type, set by the class and fixed.
        name = "#{triple[:predicate].fragment.underscore}".to_sym
        return nil if ignore?(name) # We don't know about this predicate ... can happen if we are assigning to a super class
        object = Fuseki::Resource::Property.new(@parent, name, @metadata[name])
        object.set_value(triple[:object])
        object
      end

      # Each. Iterate over the proeprites
      def each
        @metadata.each {|key, value| yield(Fuseki::Resource::Property.new(@parent, key, value))}
      end

      # Assign. Assign a set of properties to the object
      # 
      # @param params [Hash] A set of property name values
      # @return [Void] no return
      def assign(params)
        params.each do |key, value|
          name = key.to_sym
          next if ignore?(name)
          self.property(name).set(value)
        end
      end

      # ---------
      # Test Only
      # ---------
      if Rails.env.test?

        def parent
          @parent
        end

        def metadata
          @metadata
        end

      end

    end

  end

end
