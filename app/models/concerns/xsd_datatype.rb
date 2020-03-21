# XSD Datatype. The XSD datatype (simple datatypes)
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class XSDDatatype

  C_XML_SCHEMA_NS = "http://www.w3.org/2001/XMLSchema"
  C_XSD_STRING = "string"

  # Initialise
  def initialize(fragment)
    byebug if fragment.blank?
    @datatype = "#{C_XML_SCHEMA_NS}##{fragment}"
    @fragment = fragment
  end

  # Fragment
  #
  # @return [String] the fragment part of the datatype
  def fragment
    @fragment
  end

  # String?
  #
  # @return [String] the fragment part of the datatype
  def string?
    @fragment == C_XSD_STRING
  end

  # To Typed
  #
  # @param value [String] the value
  # @return [String] the value converted to the correct type
  def to_typed(value)
    value.send(datatype_configuration[:typed])
  end

  # To Literal
  #
  # @param value [String] the value
  # @return [String] the value converted to the literal string
  def to_literal(value)
    value.send(datatype_configuration[:literal])
  end

  # Default
  #
  # @return [Object] return the default value of the correct datatype.
  def default
    return datatype_configuration[:default] if datatype_configuration[:default_method].nil?
    datatype_configuration[:default].send(datatype_configuration[:default_method])
  end

  # To Hash. Return as a hash
  #
  # @return [Hash] the object as a hash
  def to_h
    {datatype: @datatype, fragment: @fragment}
  end

private

  # Read the method configuration for a given datatype
  def datatype_configuration
    result = Rails.configuration.datatypes[@datatype.to_sym]
    return result if !result.nil?
    Errors.application_error(self.class.name, "datatype_configuration", "Unable to access configuration for type #{@datatype}.")
  end

end