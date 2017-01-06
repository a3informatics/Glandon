class SdtmModelClassification < EnumeratedLabel
  
  C_LINK_TYPE = "classifiedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableClassification"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
   # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
    else
      super(triples, id)
    end
    self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
  end

  # Get all items
  #
  # @params instance_namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all(instance_namespace)
    results = Array.new
    query = UriManagement.buildPrefix(C_SCHEMA_PREFIX, [UriManagement::C_BD]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + C_RDF_TYPE + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  MINUS { ?a bd:childClassification ?c } \n" +
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
        object.rdf_type = C_RDF_TYPE
        object.label = label
        results << object
      end
    end
    return results
  end

  # To JSON
  #
  # @return [Hash] The object hash 
  def to_json
    return super
  end

  # From JSON
  #
  # @param json [Hash] The hash of values for the object 
  # @return [SdtmModelDatatype] The object
  def self.from_json(json)
    return super(json)
  end

end
