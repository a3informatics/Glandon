class Form::Item::Placeholder < Form::Item

  attr_accessor :free_text
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::Placeholder"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Placeholder"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  def initialize(triples=nil, id=nil)
    self.free_text = ""
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end        
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    object.triples = ""
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end
  
  def to_json
    json = super
    json[:free_text] = self.free_text
    return json
  end

  def self.from_json(json)
    object = super(json)
    object.free_text = json[:free_text]
    return object
  end

  def to_sparql(parent_id, sparql)
    super(parent_id, sparql)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "free_text", "#{self.free_text}", "string")
    return self.id
  end
    
 end
