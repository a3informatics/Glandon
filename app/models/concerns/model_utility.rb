module ModelUtility

  C_CLASS_NAME = "ModelUtility"

  # Build URI to return a URI reference
  #
  # @param namespace [string] The namespace
  # @param id [string] The id
  # @return [string] The URI reference
  def ModelUtility.buildUri(namespace, id)
    IsoUtility.uri_ref(namespace, id)
  end
  
  # Extract CID from a URI
  #
  # @param uri [string] The uri
  # @return [string] The fragment (CID) from the URI
  def ModelUtility.extractCid(uri)
    IsoUtility.extract_cid(uri)
  end
  
  # Extract Namespace from a URI
  #
  # @param uri [string] The uri
  # @return [string] The namespace from the URI
  def ModelUtility.extractNs(uri)
    IsoUtility.extract_namespace(uri)
  end
  
  # Get value from a XML node
  #
  # @param name [string] The attribute name
  # @param uri [boolean] True if looking for a URI, false if literal value required
  # @param node [object] The nokogiri xml node object to be searched (parent node)
  # @return [string] The value
  def ModelUtility.getValue(name, uri, node)
    path = "binding[@name='" + name + "']/"
    if uri 
      path = path + "uri"
    else
      path = path + "literal"
    end
    valueArray = node.xpath(path)
    if valueArray.length == 1
      return valueArray[0].text
    else
      return ""
    end
  end
  
end
