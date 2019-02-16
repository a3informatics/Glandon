module Fuseki
  
  module Persistence
  
    module Property

      def set_property(triple)
        name = rails_name(triple[:predicate].fragment)
        return if set_uri(name, triple)
        set_simple(name, triple)
      end

      def set_uri(name, triple)
        return if !triple[:object].is_a? Uri
        if instance_variable_get("@#{name}").is_a? Array 
          instance_variable_get("@#{name}").push(triple[:object])
        else
          instance_variable_set("@#{name}", triple[:object])
        end
      end

      def set_simple(name, triple)
        instance_variable_set("@#{name}", convert_value(triple))
      end

      def convert_value(triple)
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

      def rails_name(name)
        return name.underscore
      end

    end

  end

end