class Tabular < IsoManaged
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :children

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD 
  C_CLASS_NAME = "Tabular"

  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns)
    object = super(id, ns)
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

  def self.all(schema_type, schema_namespace)
    results = super(schema_type, schema_namespace)
  end

  def self.history(schema_type, schema_namespace, params)
    results = super(schema_type, schema_namespace, params)
    return results
  end

end
