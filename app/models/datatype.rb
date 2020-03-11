# Datatype
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Datatype < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#PreferredTerm",
            base_uri: "http://#{IsoRegistrationAuthority.repository_scope.authority}/DT",
            uri_unique: :short_label,
            cache: true,
            key_property: :short_label

  data_property :xsd
  data_property :short_label
  data_property :odm

  @@methods = 
  { 
    "http://www.w3.org/2001/XMLSchema#string": {typed: :to_s, literal: :to_s}
    "http://www.w3.org/2001/XMLSchema#boolean": {typed: :to_bool, literal: :to_s}
    "http://www.w3.org/2001/XMLSchema#dateTime": {typed: :to_time_with_default, literal: :iso8601}
    "http://www.w3.org/2001/XMLSchema#integer": {typed: :to_i, literal: :to_s}
    "http://www.w3.org/2001/XMLSchema#positveInteger": {typed: :to_i, literal: :to_s}
  }

  # Set a simple typed value
  def to_typed(value)
    value.send(@@methods[self.type][:typed])
  end

  # Build the object literal as a string
  def to_literal(value)
    value.send(@@methods[self.type][:literal])
  end

end