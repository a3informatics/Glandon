# User Access. Links a user to the roles allocated to that user.
#
# @author Dave Iberson-Hurst
# @since 4.0.0
class User::Access < Fuseki::Base

  configure rdf_type: 'http://www.a3informatics.com/rdf-schema/users-and-roles#UserAccess',
            base_uri: "http://#{ENV["url_authority"]}/UA",
            uri_unique: true


  data_property :user_id
  object_property :has_role, cardinality: :many, model_class: "Role"
  object_property :can_access_scope, cardinality: :many, model_class: "IsoNamespace"

end
