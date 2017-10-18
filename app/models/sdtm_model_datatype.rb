class SdtmModelDatatype < EnumeratedLabel
  
  C_LINK_TYPE = "typedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableType"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_DEFAULT = "CHAR"
  C_CID_SUFFIX = "DT"

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
  # @params namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all(namespace)
    results = super(C_RDF_TYPE, C_SCHEMA_PREFIX, namespace)  
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
  # @return [Hash] The object hash 
  def to_json
    json = super
    return json
  end

  # From JSON
  #
  # @param json [Hash] The hash of values for the object 
  # @return [SdtmModelDatatype] The object
  def self.from_json(json)
    object = super(json)
    return object
  end

  # To SPARQL
  #
  # @param [UriV2] parent_uri the parent URI
	# @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The URI
 	def to_sparql_v2(parent_uri, sparql)
 		self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{Uri::C_UID_SECTION_SEPARATOR}#{self.label.upcase.gsub(/\s+/, "")}"
    self.namespace = parent_uri.namespace
    uri = super(sparql, C_SCHEMA_PREFIX)
    return uri
  end

end
