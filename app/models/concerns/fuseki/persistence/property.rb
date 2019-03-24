# Fuseki Persistence Property. Handles setting of properties. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    module Property

      # URI? Does the named proerty contain a URI
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @return [Void] no return
      def uri?(name)
        properties = self.class.instance_variable_get(:@properties)
        Errors.application_error(self.name, __method__.to_s, "Calling method on non-object property.") if !properties[name][:type] == :object
        value = instance_variable_get(name)
        value.is_a?(Array) ? value.first.is_a?(Uri) : value.is_a?(Uri)
      end

      # From Triple. Sets the property using the predicate as the name
      #
      # @param triple [Hash] the triple
      # @return [Void] no return
      def from_triple(triple)
        # Get the rails names and map to the schema defintions via the class properties.
        property_name = Fuseki::Persistence::Naming.new(triple[:predicate].fragment)
        from_value(property_name.as_instance, triple[:object])
      end

      def from_value(name, value)
        properties = self.class.instance_variable_get(:@properties)
        return if !properties.key?(name) # Ignore values if no property declared.
        properties[name][:type] ==:object ? from_uri(name, value) : from_simple(name, value)
      end

      # From URI. Sets the named property with the specified URI
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @param object [Object] the object. Might be a Uri, Fuseki::base or a scalar
      # @return [Void] no return
      def from_uri(name, object)
        instance_variable_get(name).is_a?(Array) ? instance_variable_get(name).push(object) : instance_variable_set(name, object)
      end

      # From Simple. Sets the named property with the specified scalar value
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @param value [String] the property value
      # @return [Void] no return
      def from_simple(name, value)
        properties = self.class.instance_variable_get(:@properties)
        property_name = Fuseki::Persistence::Naming.new(name)
        schema = self.class.class_variable_get(:@@schema)
        base_type = schema.range(properties[name][:predicate])
        instance_variable_set(name, to_typed(base_type, value))
      rescue => e
        puts "FronSimple: Error #{name}=#{value}"
        puts schema.to_yaml
      end

    private

      # Set a simple typed value
      def to_typed(base_type, value)
        if base_type == BaseDatatype.to_xsd(BaseDatatype::C_STRING)
          "#{value}"
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_BOOLEAN)
          value.to_bool
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME)
          value.to_time_with_default
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)
          value.to_i
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_POSITIVE_INTEGER)
          value.to_i
        else
          "#{value}"
        end
      end

    end

  end

end