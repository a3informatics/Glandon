class SdtmModelCompliance < EnumeratedLabel
  
  C_LINK_TYPE = "compliance"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableCompliance"
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
  # @params namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all(namespace)
    return super(C_RDF_TYPE, C_SCHEMA_PREFIX, namespace)  
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

end
