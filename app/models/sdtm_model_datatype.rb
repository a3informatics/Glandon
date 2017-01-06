class SdtmModelDatatype < EnumeratedLabel
  
  C_LINK_TYPE = "typedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableType"
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
    results = super(C_RDF_TYPE, C_SCHEMA_PREFIX, namespace)  
    return results
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
    object  = super(json)
    return object
  end

end
