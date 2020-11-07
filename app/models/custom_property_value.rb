# Custom Property Value. The class holding the data for a custom property.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class CustomPropertyValue < IsoContextualRelationship
  
  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#CustomProperty",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/CPV",
            uri_unique: true

  data_property :value
  object_property :custom_property_defined_by, cardinality: :one, model_class: "CustomPropertyDefinition"

  validates :value, presence: true, allow_blank: false
  validates_with Validator::Klass, property: :custom_property_defined_by, level: :uri

end