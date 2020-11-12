# XSD Datatype. The XSD datatype (simple datatypes)
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class XSDDatatype

  C_XML_SCHEMA_NS = "http://www.w3.org/2001/XMLSchema"
  C_XSD_STRING = "string"

  # Initialise
  def initialize(fragment)
    fragment = report_blank if fragment.blank?
    @datatype = "#{C_XML_SCHEMA_NS}##{fragment}"
    @fragment = fragment
  end

  # Fragment
  #
  # @return [String] the fragment part of the datatype
  def fragment
    @fragment
  end

  # String. Return a string object
  #
  # @return [XSDDatatype] an object for the string type
  def self.string
    self.new(C_XSD_STRING)
  end

  # String?
  #
  # @return [Boolean] true if it is a string
  def string?
    @fragment == C_XSD_STRING
  end

  # Integer?
  #
  # @return [Boolean] true if it is an integer
  def integer?
    @fragment == "integer"
  end

  # Datetime?
  #
  # @return [Boolean] true if it is a datetime
  def datetime?
    @fragment == "dateTime"
  end

  # Date?
  #
  # @return [Boolean] true if it is a date
  def date?
    @fragment == "date"
  end

  # Time?
  #
  # @return [Boolean] true if it is a time
  def time?
    @fragment == "time"
  end

  # Boolean?
  #
  # @return [Boolean] true if it is a boolean
  def boolean?
    @fragment == "boolean"
  end

  # Float?
  #
  # @return [Boolean] true if it is a float
  def float?
    @fragment == "float"
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

  # To String. Return as a string
  #
  # @return [String] the object as a string
  def to_s
    @datatype
  end

  # To URI. Return as a URI
  #
  # @return [URI] the object as a URI
  def to_uri
    Uri.new(uri: @datatype)
  end

private

  # Debug for a blank fragment
  def report_blank
    puts "\n\n********** WARNING FRAGMENT BLANK TRACE **********\n\n"
    puts "#{caller.join("\n")}\n\n"
    ""
  end

  # Read the method configuration for a given datatype
  def datatype_configuration
    result = Rails.configuration.datatypes[@datatype.to_sym]
    return result if !result.nil?
    Errors.application_error(self.class.name, "datatype_configuration", "Unable to access configuration for type #{@datatype}.")
  end

end
