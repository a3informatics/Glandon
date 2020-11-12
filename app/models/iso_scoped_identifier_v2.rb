# ISO Scoped identifier (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoScopedIdentifierV2 < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier",
            base_uri: "http://#{ENV["url_authority"]}/SI",
            uri_suffix: "SI"

  data_property :identifier
  data_property :version_label
  data_property :version
  data_property :semantic_version
  object_property :has_scope, cardinality: :one, model_class: "IsoNamespace", delete_exclude: true

  validates_with Validator::Field, attribute: :identifier, method: :valid_identifier?
  validates_with Validator::Field, attribute: :version_label, method: :valid_label?
  validates_with Validator::Field, attribute: :version, method: :valid_version?
  validates_with Validator::Field, attribute: :semantic_version, method: :valid_semantic_version?
  validates_with Validator::ScopedIdentifier, on: :create

  # Constants
  C_CLASS_NAME = self.name
  C_FIRST_VERSION = 1

  # Next Integer Version. Get the next integer version
  #
  # @return [integer] The updated version
  def next_integer_version
    return self.version + 1
  end
  
  # Next Semantic Version. Get the next semantic version
  #
  # @return [integer] The updated version
  def next_semantic_version
    temp = SemanticVersion.from_s self.semantic_version.to_s
    temp.increment_minor
    return temp
  end
  
  # Later Version? A later version than the specified version?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def later_version?(version)
    return self.version > version
  end
  
  # Earlier Version? A earlier version than the specified version?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def earlier_version?(version)
    return self.version < version
  end
  
  # Same Version? Same version than specified?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def same_version?(version)
    return self.version == version
  end
  
  # First Integer Version. Return the first version
  #
  # @return [integer] The first version
  def self.first_integer_version
    return C_FIRST_VERSION
  end

  # Exists? Find if the object with identifier exists within the specified scope (ISO Namespace).
  #
  # @param identifier [String] The identifer being checked.
  # @param scope [IsoNamespace] the scope namespace (IsoNamespace object).
  # @return [Boolean] true if theidentifier exists within the scope, false otherwise
  def self.exists?(identifier, scope)
    results = object_results(exists_query(identifier, scope), prefixes: [:isoI])
    !results.empty?
  end

  # Version Exists? Find if the object with the identifier with a specified version exists within the specified scope (namespace).
  #
  # @param identifier [String] the identifer being checked.
  # @param version [Integer] the version being checked.
  # @param scope [IsoNamespace] the scope namespace (IsoNamespace object).
  # @return [boolean] True if the item exists, False otherwise.
  def self.version_exists?(identifier, version, scope)
    results = object_results(version_exists_query(identifier, version, scope), prefixes: [:isoI])
    !results.empty?
  end

  # Latest Integer Version. Find the latest version for a given identifier within the specified scope (namespace).
  #
  # @param identifier [String] the identifer being checked.
  # @param scope [IsoNamespace] the scope namespace (IsoNamespace object).
  # @return [Boolean] true if the item exists, false otherwise.
  def self.latest_integer_version(identifier, scope)   
    results = object_results(latest_version_query(identifier, scope), prefixes: [:isoI])
    return C_FIRST_VERSION if results.empty?
    return results.by_object.first.to_i
  end

  # Next Integer Version. Obtain the next version for a given identifier within the specified scope (namespace).
  #
  # @param identifier [String] the identifer being checked.
  # @param scope [IsoNamespace] the scope namespace (IsoNamespace object).
  # @return [Integer] the next version.
  def self.next_integer_version(identifier, scope)   
    results = object_results(latest_version_query(identifier, scope), prefixes: [:isoI])
    return C_FIRST_VERSION if results.empty?
    return results.by_object.first.to_i + 1
  end

  # ---------
  # Test Only  
  # ---------
  if Rails.env.test?
    
    # Create
    #
    # @param attributes [Hash] the set of properties
    # @return [IsoNamespace] the object. Contains errors if it fails
    def self.create(attributes)
      identifier = attributes[:identifier].gsub(/[^0-9A-Za-z]/, '-')
      uri = Uri.new(namespace: base_uri.namespace, fragment: "")
      uri.extend_path("#{attributes[:has_scope].short_name}/#{identifier}")
      attributes[:uri] = uri
      super
    end 

  end

  # Update Version
  #
  # @params [Hash] params the parameters
  # @option params [String] :version_label the version label
  # @option params [String] :semantic_version the semantic version
  # @raise [Exceptions::UpdateError] if an error occurs during the update
  # @return null
  def update_version(params)
    self.version_label = params[:version_label] if params.key?(:version_label)  
    self.semantic_version = params[:semantic_version] if params.key?(:semantic_version)  
    partial_update(update_query(params), [:isoI]) if valid?(:update)
  end

private

  # The update query
  def update_query(params)
    %Q{
      DELETE
      {
       #{self.uri.to_ref} isoI:versionLabel ?a .
       #{self.uri.to_ref} isoI:semanticVersion ?b .
      }
      INSERT
      {
       #{self.uri.to_ref} isoI:versionLabel \"#{self.version_label}\"^^xsd:string .
       #{self.uri.to_ref} isoI:semanticVersion \"#{self.semantic_version}\"^^xsd:string .
      }
      WHERE
      {
       #{self.uri.to_ref} isoI:versionLabel ?a .
       #{self.uri.to_ref} isoI:semanticVersion ?b .
      }
    }
  end

  def self.exists_query(identifier, scope)
    "SELECT ?s WHERE \n" +
    "{\n" +
    "  ?s rdf:type isoI:ScopedIdentifier . \n" +
    "  ?s isoI:identifier \"#{identifier}\" . \n" +
    "  ?s isoI:hasScope #{scope.uri.to_ref} . \n" +
    "}"
  end

  def self.version_exists_query(identifier, version, scope)
    "SELECT ?s WHERE \n" +
    "{\n" +
    "  ?s rdf:type isoI:ScopedIdentifier . \n" +
    "  ?s isoI:identifier \"#{identifier}\" . \n" +
    "  ?s isoI:version #{version} . \n" +
    "  ?s isoI:hasScope #{scope.uri.to_ref} . \n" +
    "}"
  end

  def self.latest_version_query(identifier, scope)
    "SELECT ?o WHERE \n" +
    "{\n" +
    "  ?s rdf:type isoI:ScopedIdentifier . \n" +
    "  ?s isoI:identifier \"#{identifier}\" . \n" +
    "  ?s isoI:version ?o . \n" +
    "  ?s isoI:hasScope #{scope.uri.to_ref} . \n" +
    "} ORDER BY DESC(?o)"
  end

end