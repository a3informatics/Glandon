# Datatype
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Datatype < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/Datatypes#Datatype",
            base_uri: "http://#{ENV["url_authority"]}/DT",
            uri_unique: :short_label,
            cache: true,
            key_property: :short_label

  data_property :xsd
  data_property :short_label
  data_property :odm

  validates :xsd, presence: true
  validates :short_label, presence: true
  validates :odm, presence: true

  # To Typed
  #
  # @param value [String] the value
  # @return the value converted to the correct type
  def to_typed(value)
    value.send(datatype_configuration[:typed])
  end

  # To Literal
  #
  # @param value [String] the value
  # @return the value converted to the literal string
  def to_literal(value)
    value.send(datatype_configuration[:literal])
  end

private

  # Read the method configuration for a given datatype
  def datatype_configuration
    result = Rails.configuration.datatypes[self.xsd.to_sym]
    return result if !result.nil?
    Errors.application_error(self.class.name, "datatype_configuration", "Unable to access configuration for type #{self.xsd}.")
  end

end