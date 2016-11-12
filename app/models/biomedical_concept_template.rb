class BiomedicalConceptTemplate < BiomedicalConceptCore
  
  # Constants
  C_INSTANCE_PREFIX = "mdrBcts"
  C_CLASS_NAME = "BiomedicalConceptTemplate"
  C_CID_PREFIX = "BCT"
  C_RDF_TYPE = "BiomedicalConceptTemplate"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Find a given biomedical concept template
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @param children [boolean] Find all child objects. Defaults to true.
  # @return [object] The form object.
  def self.find(id, namespace, children=true)
    super(id, namespace, children)
  end

  # Find all versions of all BCTs.
  #
  # @return [array] Array of objects found.
  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find list of BCTs 
  #
  # @return [array] Array of objects found.
  def self.unique
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find all released BCTs
  #
  # @return [array] An array of objects.
  def self.list
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find history for a given identifier
  #
  # @params [hash] {:identifier, :scope_id}
  # @return [array] An array of objects.
  def self.history(params)
    super(C_RDF_TYPE, C_SCHEMA_NS, params)
  end 

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:children] = Array.new
    self.items.each do |item|
      json[:children] << item.to_json
    end 
    json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    return json
  end
  
end
