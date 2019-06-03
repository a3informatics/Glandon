class IsoConceptSystemGeneric < IsoConcept

  attr_accessor :children
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_ISO_C
  C_INSTANCE_PREFIX = UriManagement::C_MDR_C
  C_CLASS_NAME = "IsoConceptSystemGeneric"
  
  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find a given item given the id and namespace
  #
  # @param id [String] The id
  # @param ns [String] The instance schema namespace
  # @param children [Boolean] include all children concepts in the find
  # @return [Object] The concept
  def self.find(id, ns, children=true)
    object = super(id, ns)
    children_from_triples(object, object.triples, id) if children
    return object
  end

  # Find all concepts of a given type within specified namespace.
  #
  # @param rdf_type [Atring] The RDF type
  # @return [Array] Array of objects
  def self.all
    results = super(self::C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Add a child object
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def add(params)
    object = IsoConceptSystem::Node.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      create_child(object, sparql, C_SCHEMA_PREFIX, "hasMember")
    end
    return object
  end

  # To JSON
  #
  # @return [Hash] The object hash 
  def to_json
    result = super
    result[:children] = Array.new
    children.each do |child|
      result[:children] << child.to_json
    end
    return result
  end

  # From JSON
  #
  # @param json [Hash] The hash of values for the object 
  # @return [Object] The object
  def self.from_json(json)
    object = super(json)
    object.rdf_type = UriV2.new({:namespace => C_SCHEMA_NS, :id => self::C_RDF_TYPE}).to_s
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << IsoConceptSystem::Node.from_json(child)
      end
    end
    return object
  end

  # Return the object as SPARQL
  #
  # @param cid_prefix [String] The fragment prefix
  # @return [Object] The sparql object
  def to_sparql_v2
    sparql = SparqlUpdateV2.new
    ra = IsoRegistrationAuthority.owner
    uri = UriV2.new({:prefix => self.class::C_CID_PREFIX, :org_name => ra.namespace.shortName, :identifier => Time.now.to_i, :namespace => C_INSTANCE_NS})
    self.id = uri.id
    self.namespace = uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    return sparql
  end

  # Object Valid?
  #
  # @return [Boolean] True if valid, false otherwise.
  def valid?
    super
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = IsoConceptSystem::Node.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasMember"))
  end

end