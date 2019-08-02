# Fuseki Metadata Property. Handles a single metadata property. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Resource
  
    class Property

      # Initialize
      #
      # @param name [Symbol] the name of the property. Must be as declared in the rails class
      # @return [Object] the newly created object
      def initialize(ref, name, metadata)
        @parent = ref
        @name = name
        @metadata = metadata
        @instance_variable_name = "@#{@name}".to_sym # @<name> as a symbol
        @array = array?
      end

      # name
      # 
      # @return [Symbol] the name of the property
      def name
        @name
      end

      # Klass
      # 
      # @return [Class] the class for a given property
      def klass
        @metadata[:model_class]
      end

      alias :target :klass

      # Cardinality
      # 
      # @return [Symbol] the cardinality for the specified property, either :one or :many
      def cardinality
        @metadata[:cardinality]
      end

      # Predicate
      # 
      # @return [Uri] the predicate for the property
      def predicate
        @metadata[:predicate]
      end

      # Object?
      # 
      # @return [Boolean] true if the property is an object property, false otherwise (data property)
      def object?
        @metadata[:type] == :object
      end

      # Array?
      # 
      # @return [Boolean] true if the property is an array object property, false otherwise (single object property)
      def array?
        @metadata[:cardinality] != :one
      end

      # Default Value
      # 
      # @return [Object] the property's default value
      def default_value
        @metadata[:default].dup
      end

      # URI? Does the named property contain a URI
      #
      # @return [Boolean] true if a URI.
      def uri?
        value = get
        value.is_a?(Array) ? value.first.is_a?(Uri) : value.is_a?(Uri)
      end

      # Set Value.
      #
      # @param value [String] the value
      # @return [Void] no return
      def set_value(value)
        object? ? set_uri(value) : set_simple(value)
      end

      # From Hash. Sets the property specified from a hash
      #
      # @param value [Hash] the hash
      # @return [Void] no return
      def set_from_hash(value)
        set(klass.from_h(value))
      end

      # From URI. Sets the named property with the specified URI
      #
      # @param value [Object] the uri, either a sting or a Uri
      # @return [Void] no return
      def set_uri(value)
        value = Uri.new(uri: value) if value.is_a? String
        set(value)
      end

      # From Simple. Sets the named property with the specified scalar value
      #
      # @param value [String] the property value
      # @return [Void] no return
      def set_simple(value)
        set_single(to_typed(@metadata[:base_type], value))
      rescue => e
        puts "simple: Error #{name}=#{value}"
      end

      # def replace_uri(name, object)
      #   properties = self.class.instance_variable_get(:@properties)
      #   return if !properties.key?(name) # Ignore values if no property declared.
      #   remove_uri(name, object.uri)
      #   set_object(name, object)
      # end

      # Set
      #
      # @param value [Object] the property value
      # @return [Void] no return
      def set(value)
        array? ? @parent.instance_variable_get(@instance_variable_name).push(value) : @parent.instance_variable_set(@instance_variable_name, value)
      end

      # Get
      #
      # @return [Object] the value
      def get
        @parent.instance_variable_get(@instance_variable_name)
      end

      # Schema Predicate Name
      #
      # @param name [Symbol] the property name
      # @return [String] schema version of the name 
      def self.schema_predicate_name(name) 
        "#{name}".camelcase(:lower) # Camelcase with lower first char
      end

    private

      # Set an object, either single or array
      def set_single(value)
        @parent.instance_variable_set(@instance_variable_name, value)
      end

      # # Remove an item based on its URI
      # def remove_uri(name, uri)
      #   value = instance_variable_get(name)
      #   return if !value.is_a?(Array)
      #   value.delete_if {|x| x.is_a?(Uri) && x == uri}
      # end

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