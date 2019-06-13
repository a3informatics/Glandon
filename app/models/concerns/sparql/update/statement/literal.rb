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
          "\"#{string_escape}\"^^xsd:#{@type}"
        end

        # To Ref
        #
        # @return [String] fully qualified version of the object (note no type being added currently)
        def to_ref
          "\"#{string_escape}\""
        end

        # To Tutle
        #
        # @return [String] turtle string representation of the object
        def to_turtle
          "\"#{string_escape}\"^^xsd:#{@type}"
        end

      private

        # Process literal value
        # def literal_value
        #   return @value if @type != BaseDatatype.to_xsd(BaseDatatype::C_STRING) && @type != BaseDatatype.to_xsd(BaseDatatype::C_DATETIME) 
        #   return string_escape
        # end

        # Check the args received
        def check_args(args)
          return if args.key?(:literal) && args.has_key?(:primitive_type)
          raise Errors.application_error(C_CLASS_NAME, __method__.to_s, "Invalid triple literal detected. Args: #{args}") 
        end

        # def turtle_escape
        #   return @value if @type != BaseDatatype.to_xsd(BaseDatatype::C_STRING)
        #   text = @value.dup
        #   text.gsub!("\r", "<LINEFEED>")
        #   text.gsub!("\n", "<CARRIAGERETURN>")
        #   text.gsub!("\\", "\\\\\\\\")
        #   text.gsub!("<LINEFEED>", "\\r")
        #   text.gsub!("<CARRIAGERETURN>", "\\n")
        #   text.gsub!("\"", "\\\"")
        #   return text
        # end

        def string_escape
          return @value if @type != BaseDatatype.to_xsd(BaseDatatype::C_STRING)
          text = @value.dup
          text.gsub!("\\", "\\\\")
          text.gsub!("\r", "\\r")
          text.gsub!("\n", "\\n")
          text.gsub!("\t", "\\t")
          text.gsub!("\"", "\\\"")
          return text
        end

      end
      
    end

  end
  
end

    