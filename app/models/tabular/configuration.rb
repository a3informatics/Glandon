# Handles the configuration for a managed item.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @!attribute type_uri
#   @return [UriV3] the type URI for the managed item. 
# @!attribute identifier
#   @return [String] the identifier for the managed item
# @!attribute cid_prefix
#   @return [String] the CID prefix used in constructing instance URIs
class IsoManagedItem::Configuration

  C_CLASS_NAME = self.name
  
  attr_reader :type_uri, :identifier, :cid_prefix

  # @todo 
  #C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  #C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Initialize method
  #
  # @param [Hash] args a hash containing the configuration parameters
  # @option args [String] :type_uri the type URI for the managed item
  # @option args [String] :identifier the identifier for the managed item
  # @option args [String] :cid_prefix the prefix to be used when constructing instance URIs
  # @raise Errors::ApplicationLogicError if args are missing
  # @return [Void] no return
  def initialize(args)
    check_args(args)
    @type_uri = UriV3.new(uri: args[:type_uri])
    @identifier = args[:identifier]
    @cid_prefix = args[:cid_prefix]
  end

  # Schema Namespace
  #
  # @return [String] the schema namespace
  def schema_namespace
    return @type_uri.namespace
  end

  # Schema Prefix
  #
  # @return [String] the schema prefix
  def schema_prefix
    return UriManagement.getPrefix(@type_uri.namespace)
  end

  # RDF Type
  #
  # @return [String] the schema namespace
  def rdf_type
    return @type_uri.fragment
  end

private
  
  # Check initialization arguments
  def check_args(args)
    Errors.application_error(C_CLASS_NAME, "initialize", "Missing type URI detected.") if args[:type_uri].blank?
    Errors.application_error(C_CLASS_NAME, "initialize", "Missing identifier detected.") if args[:identifier].blank?
    Errors.application_error(C_CLASS_NAME, "initialize", "Missing CID prefix detected.") if args[:cid_prefix].blank?
  end

end