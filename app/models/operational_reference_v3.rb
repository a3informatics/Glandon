# Operational Reference (v3)
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class OperationalReferenceV3 < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Reference",
            uri_suffix: "R",
            uri_property: :ordinal

  data_property :enabled, default: true
  data_property :optional, default: false
  data_property :ordinal, default: 1
  object_property :reference, cardinality: :one, model_class: "IsoConceptV2", delete_exclude: true, read_exclude: true
  object_property :context, cardinality: :one, model_class: "IsoManagedV2", delete_exclude: true, read_exclude: true
  
  # Reference Klass. Return the reference clas
  #
  # @return [Class] the reference class
  def self.referenced_klass
    resources[:reference][:model_classes].first
  end

  # Create
  #
  # @param params [Hash] parameters for the class
  # @param parent [Object] the parent object, used for building the URI of the reference
  # @return [OperationalReferenceV3] the new object. May contain errros if unsuccesful
  def self.create(params, parent)
    params[:parent_uri] = parent.uri
    super(params)
  end

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasCommon>?",
      "<http://www.assero.co.uk/BusinessForm#hasItem>",
      "<http://www.assero.co.uk/BusinessForm#hasCommonItem>*",
      "<http://www.assero.co.uk/BusinessForm#hasProperty>",  
    ]
  end

end