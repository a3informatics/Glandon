# Association
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class Association < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Association",
            base_uri: "http://#{EnvironmentVariable.read("url_authority")}/ASSOC",
            uri_unique: true

  object_property :the_subject, cardinality: :one, model_class: "IsoManagedV2", delete_exclude: true, read_exclude: true
  object_property :associated_with, cardinality: :many, model_class: "IsoManagedV2", delete_exclude: true, read_exclude: true
  
  # Create
  #
  # @param params [Hash] parameters for the class
  # @param parent [Object] the parent object, used for building the URI of the reference
  # @return [Association] the new object. May contain errros if unsuccesful
  def self.create(params, parent)
    params[:parent_uri] = parent.uri
    super(params)
  end

end