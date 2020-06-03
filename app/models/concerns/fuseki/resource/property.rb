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
        @to_be_saved = false
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

      # To Be Saved?
      # 
      # @return [Boolean] true if the property is to be saved
      def to_be_saved?
        @to_be_saved
      end

      # Saved. Set the prperty as saved.
      # 
      # @return [Boolean] false
      def saved
        @to_be_saved = false
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
      # def set_default(value)
      #   object? ? set_the_property(value) : set(value)
      # end

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
        set_the_property(to_typed(@metadata[:base_type], value))
      rescue => e
        puts "simple: Error #{name}=#{value}"
      end

      # Replace With Object. Replace a URI with the actual object
      #
      # @param [Object] object the object
      # @return [Void] no return
      def replace_with_object(object)
        value = get
        if array?
          uri = object.is_a?(Uri) ? object : object.uri
          value.delete_if {|x| x.is_a?(Uri) && x == uri}
        end
        set(object)
      end

      # Clear
      #
      # @return [Void] no return
      def clear
        if array?
          set_the_property([]) 
        elsif object?
          set_the_property(nil)
        else
          set_the_property("")
        end
      end

      # Set
      #
      # @param [Object] value the property value
      # @return [Void] no return
      def set(value)
        array? ? push_the_property(value) : set_the_property(value)
      end

      # Set Raw. Sets the property to exactly as the value passed. Use with care.
      #
      # @param [Object] value the property value
      # @return [Void] no return
      def set_raw(value)
        set_the_property(value)
      end

      # Get
      #
      # @return [Object] the value
      def get
        get_the_property
      end

      # Schema Predicate Name
      #
      # @param [Symbol] name the property name
      # @return [String] schema version of the name 
      def self.schema_predicate_name(name) 
        "#{name}".camelcase(:lower) # Camelcase with lower first char
      end

      # To Triples. Output the property as a set of triples
      #
      # @params [Sparql::Update] sparql the update object object
      # @params [Uri] subject the subject uri for the property
      # @return [Void] no return
      def to_triples(sparql, subject)
        objects = get_values
        datatype = @metadata[:base_type]
        objects.each do |object|
          statement = object? ? {uri: uri_for_object(object)} : {literal: "#{to_literal(datatype, object)}", primitive_type: datatype}
          sparql.add({:uri => subject}, {:uri => predicate}, statement)
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

    private

      # Get values for object property. Can be single or an array. Return as an array
      def get_values
        value = get
        return [value] if !object?
        return value if array?
        return [] if value.nil?
        [value]
      end

      # Set an object, either single or array
      def set_the_property(value)
        @parent.instance_variable_set(@instance_variable_name, value)
        @to_be_saved = true
      end

      # Push a value to an array object
      def push_the_property(value)
        @parent.instance_variable_get(@instance_variable_name).push(value)
        @to_be_saved = true
      end

      def get_the_property
        @parent.instance_variable_get(@instance_variable_name)
      end

      # Set a simple typed value
      def to_typed(base_type, value)
        x = false
        if base_type == BaseDatatype.to_xsd(BaseDatatype::C_STRING)
          result = "#{value}"
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_BOOLEAN)
          result = value.to_bool
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME)
          result = value.to_time_with_default
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)
          result = value.to_i
        elsif base_type == BaseDatatype.to_xsd(BaseDatatype::C_POSITIVE_INTEGER)
          result = value.to_i
        else
          x = true
          result = "#{value}"
        end
      puts "***** Schema Issue, Extensible *****" if @name == :extensible && x
        return result
      rescue => e
        byebug
      end

      # Build the object literal as a string
      def to_literal(type, value)
        return type == BaseDatatype.to_xsd(BaseDatatype::C_DATETIME) ? value.iso8601 : value
      end

      def uri_for_object(object)
        return object if object.is_a? Uri
        result = object.uri if object.respond_to?(:uri)
        return result if !result.nil?
        Errors.application_error(self.class.name, __method__.to_s, "The URI for an object for property #{@name} has not been set or cannot be accessed: #{object.to_h}")
      end

    end

  end

end