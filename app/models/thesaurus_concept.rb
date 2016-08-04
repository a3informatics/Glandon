require "nokogiri"
require "uri"

class ThesaurusConcept < IsoConcept

  include CRUD
  include ModelUtility
      
  attr_accessor :identifier, :notation, :synonym, :definition, :preferredTerm, :topLevel, :children, :parentIdentifier
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_CLASS_NAME = "ThesaurusConcept"
  C_RDF_TYPE = "ThesaurusConcept"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
      self.identifier = ""
      self.notation = ""
      self.synonym = ""
      self.definition = ""
      self.preferredTerm = ""
      self.topLevel = false
      self.parentIdentifier = ""
    else
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.exists?(identifier, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    schemaNs = UriManagement.getNs(C_SCHEMA_PREFIX)
    return super("identifier", identifier, "ThesaurusConcept", schemaNs, ns)
  end

  def self.create(params, ns)
    # Create the object
    object = self.new 
    object.errors.clear
    identifier  = params[:identifier]
    label  = params[:label]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]
    # Create the query
    id = ModelUtility.buildCidIdentifier(C_CLASS_PREFIX, identifier)
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + id + " rdfs:label  \"" + label.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      object.id = id
      object.identifier = identifier
      object.notation = notation
      object.preferredTerm = preferredTerm
      object.synonym = synonym
      object.definition = definition
      object.children = nil
    else
      object.errors.add(:base, "The concept was not created in the database.")
    end
    return object
  end

  def self.create_top_level(params, ns, thesauriId)
    # Create the object
    object = self.new 
    object.errors.clear
    identifier  = params[:identifier]
    label  = params[:label]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]
    # Create the query
    id = ModelUtility.buildCidIdentifier(C_CLASS_PREFIX, identifier)
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + thesauriId + " iso25964:hasConcept :" + id + " . \n" +
      "  :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + id + " rdfs:label  \"" + label.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      object.id = id
      object.identifier = identifier
      object.notation = notation
      object.preferredTerm = preferredTerm
      object.synonym = synonym
      object.definition = definition
      object.children = nil
    else
      object.errors.add(:base, "The concept was not created in the database.")
    end
    return object
  end
  
  def add_child(child, ns)
    # Clear errors
    self.errors.clear
    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + self.id + " iso25964:hasChild :" + child.id + " . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      cl = ThesaurusConcept.find(self.id, self.namespace)
      self.children = cl.children
    else
      self.errors.add(:base, "The concept was not created in the database.")
    end
  end

  def update(params, ns)
    result = false
    # Clear errors
    self.errors.clear
    # Note extensible cannot be modified.
    identifier  = params[:identifier]
    label  = params[:label]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    definition = params[:definition]
    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "DELETE { :" + self.id + " ?p ?o } \n" +
      "INSERT \n" +
      "{ \n" +
      "  :" + self.id + " rdfs:label \"" + label.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "} \n" +
      "WHERE \n" +
      "{\n" +
      "  :" + self.id + " (iso25964:identifier|iso25964:notation|iso25964:preferredTerm|iso25964:synonym|iso25964:definition) ?o .\n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      result = true
      self.children = ThesaurusConcept::allChildren(self.id, ns)
      ConsoleLogger::log(C_CLASS_NAME,"updated","Object created, id=" + self.id)
    end
    return result
  end

  def destroy(ns, thesauriId)
    result = false
    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "DELETE \n" +
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "  :" + thesauriId + " iso25964:hasConcept :" + self.id + " . \n" +
      "  ?c iso25964:hasChild :" + self.id + " . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "  OPTIONAL { :" + thesauriId + " iso25964:hasConcept :" + self.id + " } \n" +
      "  OPTIONAL { ?c iso25964:hasChild :" + self.id + " } \n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object deleted")
      result = true
    end
    return result 
  end
  
  def self.diff? (thcA, thcB)
    result = false
    if ((thcA.id == thcB.id) &&
      (thcA.identifier == thcB.identifier) &&
      (thcA.notation == thcB.notation) &&
      (thcA.preferredTerm == thcB.preferredTerm) &&
      (thcA.synonym == thcB.synonym) &&
      (thcA.definition == thcB.definition))
      result = false
    else
      result = true
    end
    return result
  end

  def to_json
    json = super
    json[:identifier] = self.identifier
    json[:notation] = self.notation
    json[:synonym] = self.synonym
    json[:definition] = self.definition
    json[:preferredTerm] = self.preferredTerm
    json[:topLevel] = self.topLevel
    json[:parentIdentifier] = self.parentIdentifier
    json[:children] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  def d3
    result = ThesaurusNode.new(self)
    result[:children] = Array.new
    index = 0
    self.children.each do |child|
      result[:children][index] = ThesaurusNode.new(child)
      index += 1
    end
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = ThesaurusConcept.find_for_parent(triples, object.get_links(UriManagement::C_ISO_25964, "hasChild"))
  end

end