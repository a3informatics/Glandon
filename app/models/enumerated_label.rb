class EnumeratedLabel < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  C_CLASS_NAME = "EnumeratedLabel"

  @@uri_cache = {}

  # Find an item. Will find from the cache if already searched for and found.
  #
  # @param id [String] the id of the item to be retireved
  # @param namespace [String] the namespace of the item to be retrieved
  # @raise NotFoundError if the item is not found
  # @result [EnumeratedLabel] the object if found
  def self.find(id, namespace)
    object = nil
    uri = UriV2.new({id: id, namespace: namespace})
    #ConsoleLogger.debug(C_CLASS_NAME, "find", "URI=#{uri}")
    uri_s = uri.to_s
    if @@uri_cache.has_key?(uri_s)
      object = @@uri_cache[uri_s]
      #ConsoleLogger.debug(C_CLASS_NAME, "find", "Cached")
    else
      object = super(id, namespace)
      @@uri_cache[object.uri.to_s] = object
      #ConsoleLogger.debug(C_CLASS_NAME, "find", "Found")
    end    
    return object
  end

  # Find All entries for a given type within a given schema within a given instance namespace
  #
  # @param rdf_type [string] The rdf_type (fragment)
  # @param schema_prefix [string] The schema prefix
  # @param instance_namesapce [string] The instance namespace
  # @result [array] Array of objects.
  def self.all(rdf_type, schema_prefix, instance_namespace)
    results = Array.new
    query = UriManagement.buildPrefix(schema_prefix, []) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + instance_namespace + "\")) \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      if uri != "" && label != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = UriV2.new({ id: rdf_type, namespace: UriManagement.getNs(schema_prefix) }).to_s
        object.label = label
        results << object
      end
    end
    return results
  end

  # Find the defalt value (label) from a set of values. Upper case comparison made.
  #
  # @param value_set [Array] the value set, an array from the all method
  # @param default [String] the default value desired
  # @raise ApplicationLogicError if the item is not found
  # @return [Object] the item found
  def self.default(value_set, default)
    result = value_set.select {|x| x.label.upcase == default.upcase}
    return result[0] if result.length == 1
    raise Exceptions::ApplicationLogicError.new(message: "Failed to find default value #{default} in #{C_CLASS_NAME} object.")
  end

  # Find an object from triples
  #
  # @param triples [Hash] the raw triples keyed by subject
  # @param id [String] The id of the item to be found
  # @return [EnumeratedLabel] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end

end
