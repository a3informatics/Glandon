# Role Permission. Handles the permission for a class a a given access type.
#
# @author Dave Iberson-Hurst
# @since 4.0.0
class Role::Permission < Fuseki::Base

  configure rdf_type: 'http://www.a3informatics.com/rdf-schema/users-and-roles#RolePermission',
            base_uri: "http://#{ENV["url_authority"]}/RP",
            uri_unique: true

  object_property :for_class, cardinality: :one, model_class: "IsoConceptV2"
  object_property :with_access, cardinality: :one, model_class: "IsoConceptSystem::Node"
  object_property :for_role, cardinality: :many, model_class: "Role"

  validates_with Validator::Klass, property: :for_class, level: :uri
  validates_with Validator::Klass, property: :with_access, level: :uri

end
