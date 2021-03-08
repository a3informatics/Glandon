# Association
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class Association < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Association",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/ASSOC",
            uri_unique: true

  data_property :semantic
  object_property :the_subject, cardinality: :one, model_class: "IsoManagedV2", delete_exclude: true, read_exclude: true
  object_property :associated_with, cardinality: :many, model_class: "IsoManagedV2", delete_exclude: true, read_exclude: true

  include IsoManagedV2::Associations

end