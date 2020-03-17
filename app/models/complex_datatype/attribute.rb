# Complex Datatype Attribute
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ComplexDatatype::Attribute < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/Datatypes#ComplexDatatypeAttribute",
            base_uri: "http://#{ENV["url_authority"]}/CDTA",
            uri_unique: :label,
            cache: true,
            key_property: :label

  data_property :label
  object_property :simple_datatype, cardinality: :one, model_class: "SimpleDatatype"
  
  validates :label, presence: true

end