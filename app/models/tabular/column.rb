class Tabular::Column < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :rule, :ordinal
  
  # Constants
  C_CLASS_NAME = "Column"

  def initialize(triples=nil, id=nil)
    self.rule = ""
    self.ordinal = 0
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

end
