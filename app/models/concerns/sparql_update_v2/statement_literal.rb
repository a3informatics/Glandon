# Sparql Update Statment Literal
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class SparqlUpdateV2::StatementLiteral

  C_CLASS_NAME = self.name

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
    "\"#{literal_value}\"^^xsd:#{@type}"
  end

  # To Ref
  #
  # @return [String] fully qualified version of the object (note no type being added currently)
  def to_ref
    "\"#{literal_value}\""
  end

  # To Tutle
  #
  # @return [String] turtle string representation of the object
  def to_turtle
    to_s
  end

private

  # Process literal value
  def literal_value
    return @value if @type != BaseDatatype.to_xsd(BaseDatatype::C_STRING) && @type != BaseDatatype.to_xsd(BaseDatatype::C_DATETIME) 
    return SparqlUtility::replace_special_chars(@value)
  end

  # Check the args received
  def check_args(args)
    return if args.key?(:literal) && args.has_key?(:primitive_type)
    raise Errors.application_error(C_CLASS_NAME, __method__.to_s, "Invalid triple literal detected. Args: #{args}") 
  end

end

    