# Sparql Statment Literal
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Sparql

  class Update

    class Statement

      class Literal

        # Initialize
        #
        # @param [Hash] args the hash of arguments
        # @option [String] :literal the literal value
        # @option [String] :primitive_type the datatype
        #
        # @example literal
        #   {:literal => string, primitive_type => xsd:type as string} - Only valid for objects
        #
        # @return [SparqlUpdateV2::StatementLiteral] the object
        def initialize(args)  
          check_args(args)
          @value = args[:literal]
          @type = args[:primitive_type]
        end

        # To String
        #
        # @return [String] string representation of the object
        def to_s
          "\"#{normal_escape}\"^^xsd:#{@type.fragment}"
        end

        # To Ref
        #
        # @return [String] fully qualified version of the object (note no type being added currently)
        def to_ref
          "\"#{normal_escape}\""
        end

        # To Tutle
        #
        # @return [String] turtle string representation of the object
        def to_turtle
          "\"#{turtle_escape}\"^^xsd:#{@type.fragment}"
        end

      private

        # Check the args received
        def check_args(args)
          return if args.key?(:literal) && args.has_key?(:primitive_type)
          raise Errors.application_error(C_CLASS_NAME, __method__.to_s, "Invalid triple literal detected. Args: #{args}") 
        end

        # Turtle Escape. Note the single inpsect but the need to remove the quotes on start and end of string
        def turtle_escape
          return @value if !@type.string?
          @value.dup.inspect.trim_inspect_quotes #.inspect.trim_inspect_quotes << Seems we don't need double operation.
        end

        # Normal Escape. Note the single inpsect but the need to remove the quotes on start and end of string
        def normal_escape
          return @value if !@type.string?
          @value.dup.inspect.trim_inspect_quotes
        end

      end
      
    end

  end
  
end

    