# Fuseki Persistence Property. Handles setting of properties. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    module Property

      # URI? Does the named property contain a URI
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @return [Void] no return
      def uri?(name)
        properties = self.class.instance_variable_get(:@properties)
        object_property?(name, __method__.to_s)
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

      # From Value. Sets the property specified to the value
      #
      # @param name [String] the name of the property. In rails form
      # @param value [String] the value
      # @return [Void] no return
      def from_value(name, value)
        properties = self.class.instance_variable_get(:@properties)
        return if !properties.key?(name) # Ignore values if no property declared.
        properties[name][:type] == :object ? from_uri(name, value) : from_simple(name, value)
      end

      # From Hash. Sets the property specified from a hash
      #
      # @param name [String] the name of the property. In rails form
      # @param value [Hash] the hash
      # @return [Void] no return
      def from_hash(name, value)
        properties = self.class.instance_variable_get(:@properties)
        return if !properties.key?(name) # Ignore values if no property declared.
        object = properties[name][:model_class].from_h(value)
        set_object(name, object)
      end

      def from_object(name, object)
        from_uri(name, object) if object.is_a?(Uri) || object.is_a?(String)
        set_object(name, object)
      end

      # From URI. Sets the named property with the specified URI
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @param object [Object] the object. Might be a Uri, Fuseki::base or a scalar
      # @return [Void] no return
      def from_uri(name, object)
        object = Uri.new(uri: object) if object.is_a? String
        set_object(name, object)
      end

      # From Simple. Sets the named property with the specified scalar value
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @param value [String] the property value
      # @return [Void] no return
      def from_simple(name, value)
        properties = self.class.instance_variable_get(:@properties)
        #property_name = Fuseki::Persistence::Naming.new(name)
        base_type = self.class.schema_metadata.datatype(properties[name][:predicate])
        instance_variable_set(name, to_typed(base_type, value))
      rescue => e
        puts "FromSimple: Error #{name}=#{value}"
        puts schema.to_yaml
      end

      def replace_uri(name, object)
        properties = self.class.instance_variable_get(:@properties)
        return if !properties.key?(name) # Ignore values if no property declared.
        remove_uri(name, object.uri)
        set_object(name, object)
      end

      # Property Target. Get the target class for a property
      #
      # @param name [Symbol] the property name. Needs to be the instance form
      # @raise [ApplicationLogicError] raised if property is not an object property
      # @return [String] the class name
      def property_target(name)
        object_property?(name, __method__.to_s)
        properties_metadata.klass(name)
      end

    private

      # Make sure property is an object property, raise exception if not.
      def object_property?(name, method)
        Errors.application_error(self.class.name, method, "Calling method '#{method}' on non-object property '#{name}'") if !properties_metadata.object?(name)
      end

      # Set an object, either single or array
      def set_object(name, object)
        instance_variable_get(name).is_a?(Array) ? instance_variable_get(name).push(object) : instance_variable_set(name, object)
      end

      # Remove an item based on its URI
      def remove_uri(name, uri)
        value = instance_variable_get(name)
        return if !value.is_a?(Array)
        value.delete_if {|x| x.is_a?(Uri) && x == uri}
      end

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