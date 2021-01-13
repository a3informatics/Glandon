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

  validates_with Validator::Field, attribute: :for_class, method: :valid_object_or_uri?
  validates_with Validator::Field, attribute: :with_access, method: :valid_object_or_uri?

end
