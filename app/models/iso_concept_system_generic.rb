class IsoConceptSystemGeneric < IsoConcept

  attr_accessor :description, :children
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_ISO_C
  C_INSTANCE_PREFIX = UriManagement::C_MDR_C
  C_CLASS_NAME = "IsoConceptSystemGeneric"
  
  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.description = ""
    self.children = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.all(rdf_type)
    results = super(rdf_type, C_SCHEMA_NS)
  end

  def to_json
    result = super
    result[:description] = self.description
    result[:children] = Array.new
    children.each do |child|
      result[:children] << child.to_json
    end
    return result
  end

  def self.from_json(json, rdf_type)
    object = super(json)
    object.description = json[:description]
    object.rdf_type = UriV2.new({:namespace => C_SCHEMA_NS, :id => rdf_type})
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << IsoConceptSystem::Node.from_json(child)
      end
    end
    return object
  end

  def to_sparql(cid_prefix)
    sparql = SparqlUpdate.new
    ra = IsoRegistrationAuthority.owner
    uri = UriV2.new({:prefix => cid_prefix, :org_name => ra.namespace.shortName, :identifier => Time.now.to_i, :namespace => C_INSTANCE_NS})
    self.id = uri.id
    self.namespace = uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    sparql.triple_primitive_type("", self.id, C_SCHEMA_PREFIX, "description", "#{self.description}", "string")
    return sparql
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

private

  def self.params_valid?(params, object)
    result1 = FieldValidation::valid_free_text?(:label, params[:label], object)
    result2 = FieldValidation::valid_free_text?(:description, params[:description], object)
    return result1 && result2
  end

  def self.children_from_triples(object, triples, id)
    object.children = IsoConceptSystem::Node.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasMember"))
  end

end