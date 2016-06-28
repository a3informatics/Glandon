class Standard
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :classes, :bcs
  
  # Constants
  C_SCHEMA_PREFIX = "bd"
  C_INSTANCE_PREFIX = "mdrDomains"
  C_CLASS_NAME = "Domain"
  C_CID_PREFIX = "D"
  C_RDF_TYPE = "Domain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  def initialize(triples=nil, id=nil)
    self.variables = Hash.new
    self.bcs = Hash.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.groups = Form::Group.find_for_parent(object.triples, object.get_links("bf", "hasGroup"))
    end
    #object.triples = ""
    return object     
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

end
