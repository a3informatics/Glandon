# Complex Datatype
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ComplexDatatype < Fuseki::Base

  configure rdf_type: "http://www.s-cubed.dk/Datatypes#ComplexDatatype",
            base_uri: "http://#{ENV["url_authority"]}/CDT",
            uri_unique: :short_label,
            cache: true,
            key_property: :short_label

  data_property :label
  object_property :attribute, cardinality: :many, model_class: "ComplexDatatype::Atribute"
  
  validates :label, presence: true

end