class SdtmModelDatatype < EnumeratedLabel
  
  C_LINK_TYPE = "typedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableType"
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

  def to_json
    json = super
    return json
  end

  def self.from_json(json)
    object  = super(json)
    return object
  end

  def self.all(namespace)
    results = super(C_RDF_TYPE, namespace)  
    return results
  end

end
