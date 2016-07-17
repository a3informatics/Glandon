class EnumeratedLabel < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end

end
