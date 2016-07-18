class SdtmModelClassification < EnumeratedLabel
  
  C_LINK_TYPE = "classifiedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableClassification"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
    else
      super(triples, id)
    end
    # Set the type. Overwrite default.
    self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
  end

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

  def to_json
    json = super
    return json
  end

  def self.from_json(json)
    object  = super(json)
    return object
  end

end
