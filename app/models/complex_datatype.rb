# Complex Datatype
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class ComplexDatatype < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/ComplexDatatypes#ComplexDatatype",
            base_uri: "http://www.s-cubed.dk/CDT",
            uri_property: :short_name,
            cache: true,
            key_property: :short_name

  data_property :label
  data_property :short_name
  object_property :has_property, cardinality: :many, model_class: "ComplexDatatype::PropertyX"

  validates :label, presence: true
  validates :short_name, presence: true

end
