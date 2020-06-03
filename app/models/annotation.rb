# Annotation. Base class for annotations
#
# @author Dave Iberson-Hurst
# @since 2.23.0
class Annotation < IsoConceptV2
  
  configure rdf_type: "http://www.assero.co.uk/Annotations#Annotation",
            uri_suffix: "A",
            uri_unique: true

  data_property :reference
  data_property :description
  object_property :current, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :by_authority, cardinality: :one, model_class: "IsoRegistrationAuthority"

  validates_with Validator::Field, attribute: :reference, method: :valid_non_empty_label?
  validates_with Validator::Field, attribute: :description, method: :valid_non_empty_label?

end