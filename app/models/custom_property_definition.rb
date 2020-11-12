# Custom Property Definition. The class holding the definition of a custom property.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class CustomPropertyDefinition < Fuseki::Base
  
  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#CustomPropertyDefinition",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/CPD",
            uri_unique: true

  data_property :datatype
  data_property :default
  data_property :label
  data_property :description
  object_property :custom_property_of, cardinality: :one, model_class: "IsoConceptV2"

  validates_with Validator::Field, attribute: :label, method: :valid_label?
  validates_with Validator::Field, attribute: :description, method: :valid_label?
  validates :label, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :datatype, presence: true, allow_blank: false
  validates :default, presence: true, allow_blank: false
  validates_with Validator::Klass, property: :custom_property_of, level: :uri

end