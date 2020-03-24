# Complex Datatype Property
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ComplexDatatype::PropertyX < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/ComplexDatatypes#PropertyX",
            base_uri: "http://#{ENV["url_authority"]}/CDTP",
            uri_property: :label,
            cache: true,
            key_property: :label

  data_property :label
  data_property :simple_datatype
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference"
  
  validates :label, presence: true
  validates :simple_datatype, presence: true

end