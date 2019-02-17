module Fuseki
  
  module Persistence
  
    module Property

      include Fuseki::Naming

      def set_property(triple)
        # Get the rails names and map to the schema defintions via the class properties.
        name = to_rails(triple[:predicate].fragment)
        properties = self.class.instance_variable_get(:@properties)
        return if !properties.key?(name) # Ignore values if no property declared.
        return if set_uri(name, triple)
        set_simple(name, triple)
      end

      def set_uri(name, triple)
        return false if !triple[:object].is_a? Uri
        if instance_variable_get(name).is_a? Array 
          instance_variable_get(name).push(triple[:object])
        else
          instance_variable_set(name, triple[:object])
        end
        return true
      end

      def set_simple(name, triple)
        instance_variable_set(name, to_typed(triple))
      end

      def to_typed(triple)
        value = triple[:object]
        return value if value.is_a? Uri
        schema = self.class.class_variable_get(:@@schema)
        base_type = schema.range(triple[:predicate])
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