module ModelHelpers

	# Class level
  # ===========

  def self.included(klass) 
	  
		# URI as a string
	  #
	  # @param params [Hash] params that contain the id and namespace
	  # @option id [String] the identifier
	  # @option namespace [String] the namespace
	  # @return [String] the URI as a string
	  def klass.uri_to_s(params)
		  uri = Uri.new({id: params[:id], namespace: params[:namespace]})
		  return uri.to_s
		end

	  # URI Helper
	  #
	  # @param namespace [string] The namespace
	  # @param id [string] The id
	  # @return [uri] The URI object
	  def klass.uri(namespace, id)
	    uri = UriV2.new({:namespace => namespace, :id => id})
	    return uri
	  end
	  
	  # URI Reference Helper
	  #
	  # @param namespace [string] The namespace
	  # @param id [string] The id
	  # @return [string] The URI reference
	  def klass.uri_ref(namespace, id)
	    uri = UriV2.new({:namespace => namespace, :id => id})
	    return uri.to_ref
	  end
	  
	  # Extract Id from URI Helper
	  #
	  # @param uri [string] The uri
	  # @return [string] The CID
	  def klass.extract_id(uri)
	    object = UriV2.new({:uri => uri})
	    return object.id
	  end
	  
	  # Extract Namespace from URI Helper
	  #
	  # @param uri [string] The uri
	  # @return [string] The namespace
	  def klass.extract_namespace(uri)
	    object = UriV2.new({:uri => uri})
	    return object.namespace
	  end

	  # Node Value Helper. Extract a value from a XML node
	  #
	  # @param [String] name the attribute name
	  # @param [Boolean] uri true if looking for a URI, false if literal value required
	  # @param [Object] node the nokogiri xml node object to be searched (parent node)
	  # @return [String] The value, blank if multiple values found
	  def klass.node_value(name, uri, node)
	    base = "binding[@name='#{name}']/"
	    path = uri ? "#{base}uri" : "#{base}literal"
	    values = node.xpath(path)
	    return values[0].text if values.length == 1
	    return ""
	  end

	  # Query and Result Helper. Send query and get results
	  #
	  # @param [String] query the query string
	  # @result [Array] the array of result nodes (XML)
	  def klass.query_and_result(query)
	  	response = CRUD.query(query) 
    	xmlDoc = Nokogiri::XML(response.body)
    	xmlDoc.remove_namespaces!
    	return xmlDoc.xpath("//result")
    end

	end

  # Instance level
  # ==============

  # URI Helper
  #
  # See class version for details
	def uri(namespace, id)
		klass.class.uri(namespace, id)
  end

  # URI Reference Helper
  #
  # See class version for details
	def uri_ref(namespace, id)
		klass.class.uri_ref(namespace, id)
  end

  # Extract Id Helper
  #
  # See class version for details
	def extract_id(uri)
		klass.class.extract_cid(uri)
  end	

  # Extract Namespace Helper
  #
  # See class version for details
	def extract_namespace(uri)
		klass.class.extract_namespace(uri)
  end	

  # Node Value Helper
  #
  # See class version for details
	def node_value(name, uri, node)
  	klass.node_value(name, uri, node)
  end

  # Query and Result Helper
  #
  # See class version for details
  def query_and_result(query)
  	klass.query_and_result(query)
  end

end