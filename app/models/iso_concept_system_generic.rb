class IsoConceptSystemGeneric < IsoConcept

  attr_accessor :description, :children
  
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
    self.description = ""
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
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  # Find all concepts of a given type within specified namespace.
  #
  # @param rdf_type [Atring] The RDF type
  # @return [Array] Array of objects
  def self.all(rdf_type)
    results = super(rdf_type, C_SCHEMA_NS)
  end

  # To JSON
  #
  # @return [Hash] The object hash 
  def to_json
    result = super
    result[:description] = self.description
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
  def self.from_json(json, rdf_type)
    object = super(json)
    object.description = json[:description]
    object.rdf_type = UriV2.new({:namespace => C_SCHEMA_NS, :id => rdf_type}).to_s
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
  def to_sparql_v2(cid_prefix)
    sparql = SparqlUpdateV2.new
    ra = IsoRegistrationAuthority.owner
    uri = UriV2.new({:prefix => cid_prefix, :org_name => ra.ra_namespace.short_name, :identifier => Time.now.to_i, :namespace => C_INSTANCE_NS})
    self.id = uri.id
    self.namespace = uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    sparql.triple({:uri => self.uri}, {:prefix => C_SCHEMA_PREFIX, :id => "description"}, {:literal => "#{self.description}", :primitive_type => "string"})
    return sparql
  end

  # Object Valid?
  #
  # @return [Boolean] True if valid, false otherwise.
  def valid?
    result1 = super
    result2 = FieldValidation::valid_long_name?(:description, self.description, self)
    return result1 && result2
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = IsoConceptSystem::Node.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasMember"))
  end

end