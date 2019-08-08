# Fuseki Metadata Property. Handles a single metadata property. 
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Resource
  
    class Property

      # Initialize
      #
      # @param [Symbol] name the name of the property. Must be as declared in the rails class
      # @return [Object] the newly created object
      def initialize(ref, name, metadata)
        @parent = ref
        @name = name
        @metadata = metadata
        @instance_variable_name = "@#{@name}".to_sym # @<name> as a symbol
        @array = array?
      end

      # Name
      # 
      # @return [Symbol] the name of the property
      def name
        @name
      end

      # Name
      # 
      # @return [Symbol] the name in object instance format (:@<name)
      def instance_name
        @instance_variable_name
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
        @array ? value.first.is_a?(Uri) : value.is_a?(Uri)
      end

      # Set Value.
      #
      # @param [String] value the value
      # @return [Void] no return
      def set_value(value)
        object? ? set_uri(value) : set_simple(value)
      end

      # From Hash. Sets the property specified from a hash
      #
      # @param [Hash] value the hash
      # @return [Void] no return
      def set_from_hash(value)
        set(klass.from_h(value))
      end

      # Set Default.
      #
      # @param [Object] value the property value, might be an array
      # @return [Void] no return
      def set_default(value)
        object? ? set_single(value) : set_simple(value)
      end

      # Set URI. Sets the named property with the specified URI. Converts from stroing if necessary to URI object
      #
      # @param [Object] value the uri, either a sting or a Uri object
      # @return [Void] no return
      def set_uri(value)
        value = Uri.new(uri: value) if value.is_a? String
        set(value)
      end

      # Set Simple. Sets the named property with the specified scalar value
      #
      # @param [String] value the property value
      # @return [Void] no return
      def set_simple(value)
        set_single(to_typed(@metadata[:base_type], value))
      rescue => e
        puts "simple: Error #{name}=#{value}"
      end

      # Replace With Object. Replace a URI with the actual object
      #
      # @param [Object] object the object
      # @return [Void] no return
      def replace_with_object(object)
        value = get
        value.delete_if {|x| x.is_a?(Uri) && x == object.uri} if array?
        set(object)
      end

      # Set
      #
      # @param [Object] value the property value
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
      # @param [Symbol] name the property name
      # @return [String] schema version of the name 
      def self.schema_predicate_name(name) 
        "#{name}".camelcase(:lower) # Camelcase with lower first char
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

    private

      # Set an object, either single or array
      def set_single(value)
        @parent.instance_variable_set(@instance_variable_name, value)
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