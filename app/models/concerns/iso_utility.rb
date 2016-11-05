module IsoUtility

  C_CLASS_NAME = "IsoUtility"

  # URI Helper
  #
  # @param namespace [string] The namespace
  # @param id [string] The id
  # @return [uri] The URI object
  def self.uri(namespace, id)
    uri = UriV2.new({:namespace => namespace, :id => id})
    return uri
  end
  
  # URI Reference Helper
  #
  # @param namespace [string] The namespace
  # @param id [string] The id
  # @return [string] The URI reference
  def self.uri_ref(namespace, id)
    uri = UriV2.new({:namespace => namespace, :id => id})
    return uri.to_ref
  end
  
  # Extract CID from URI Helper
  #
  # @param uri [string] The uri
  # @return [string] The CID
  def self.extract_cid(uri)
    object = UriV2.new({:uri => uri})
    return object.id
  end
  
  # Extract Namespace from URI Helper
  #
  # @param uri [string] The uri
  # @return [string] The namespace
  def self.extract_namespace(uri)
    object = UriV2.new({:uri => uri})
    return object.namespace
  end
  
end
