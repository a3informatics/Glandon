class SdtmModelCompliance < EnumeratedLabel
  
  C_LINK_TYPE = "compliance"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableCompliance"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_DEFAULT = "PERMISSIBLE"
  C_CID_SUFFIX = "C"

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
	    self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Get all items
  #
  # @params id [String] the id of the domain for which the compliance values are required
  # @params namespace [String] the namespace of the domain for which the compliance values are required
  # @return [Array] array of SdtmModelCompliance objects
  def self.all(id, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, ["bd", "bo"])  +
      "SELECT DISTINCT ?b ?c WHERE \n" +
      "{ \n " +
      "  :#{id} bd:includesColumn ?a . \n " +
      "  ?a bd:compliance ?b . \n" +
      "  ?b rdfs:label ?c . \n" +
      "}\n"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('b', true, node)
      label = ModelUtility.getValue('c', false, node)
      if uri != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = UriV2.new({ id: C_RDF_TYPE , namespace: C_SCHEMA_NS }).to_s
        object.label = label
        results << object
      end
    end
    return results
  end
  
  # Find the defalt value (label) from a set of values. Upper case comparison made.
  #
  # @param value_set [Array] the value set, an array from the all method
  # @raise ApplicationLogicError if the item is not found
  # @return [Object] the item found
  def self.default(value_set)
    return super(value_set, C_DEFAULT)
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    return super
  end

  # From JSON
  #
  # @param json [Hash] the hash of values for the object 
  # @return [SdtmModelDatatype] the object
  def self.from_json(json)
    return super(json)
  end

  # To SPARQL
  #
  # @param [UriV2] parent_uri the parent URI
	# @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The URI
 	def to_sparql_v2(parent_uri, sparql)
 		self.id = "#{parent_uri.id}#{UriV2::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{UriV2::C_UID_SECTION_SEPARATOR}#{self.label.upcase.gsub(/\s+/, "")}"
    self.namespace = parent_uri.namespace
    return super(sparql, C_SCHEMA_PREFIX)
  end

end
