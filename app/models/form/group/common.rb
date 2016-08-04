class Form::Group::Common < Form::Group
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group::Common"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "CommonGroup"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    return object
  end

  def to_json
    json = super
    return json
  end

  def self.from_json(json)
    object = super(json)
    return object
  end

  def to_sparql(parent_id, sparql)
    super(sparql, C_SCHEMA_PREFIX)
    return self.id
  end

private

  def self.children_from_triples(object, triples, id)
    super(object, triples, id)
  end

end
