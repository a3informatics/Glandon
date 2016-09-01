class ThesaurusConcept < IsoConcept

  include CRUD
  include ModelUtility
      
  attr_accessor :identifier, :notation, :synonym, :definition, :preferredTerm, :topLevel, :children, :parentIdentifier
  
  # Constants
  C_SCHEMA_PREFIX = Thesaurus::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = Thesaurus::C_INSTANCE_PREFIX
  C_CLASS_NAME = "ThesaurusConcept"
  C_CID_PREFIX = "THC"
  C_RDF_TYPE = "ThesaurusConcept"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
    
  def initialize(triples=nil, id=nil)
    self.identifier = ""
    self.notation = ""
    self.synonym = ""
    self.definition = ""
    self.preferredTerm = ""
    self.topLevel = false
    self.parentIdentifier = ""
    self.children = Array.new
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

  def self.exists?(identifier, namespace)
    result = super("identifier", identifier, C_RDF_TYPE, C_SCHEMA_NS, namespace)
    ConsoleLogger::log(C_CLASS_NAME,"exists?","result=#{result}")
    return result
  end

  def add_child(params)
    #ConsoleLogger::log(C_CLASS_NAME,"add_child","params=#{params}")
    sparql = SparqlUpdateV2.new
    # Create the object
    object = self.create_sparql(params, sparql)
    if object.errors.empty?
      # Add the reference
      sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasChild"}, {:uri => object.uri})
      # Send the request, wait the resonse
      ConsoleLogger::log(C_CLASS_NAME,"add_child","Sparql=#{sparql}")
      response = CRUD.update(sparql.to_s)
      # Response
      if !response.success?
        object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, was not created in the database.")
        raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
      else
        cl = ThesaurusConcept.find(self.id, self.namespace)
        self.children = cl.children
      end
    end
    return object
  end

  def create_sparql(params, sparql)
    object = ThesaurusConcept.from_json(params)
    # Make sure namespace set correctly
    object.namespace = self.namespace
    object.errors.clear
    if !ThesaurusConcept.exists?(object.identifier, self.namespace)
      # Create the sparql. Add the ref to the child.
      object.to_sparql_v2(self.id, sparql)
    else
      object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, already exists in the database.")
    end
    return object
  end

  def update(params)
    # Build object
    self.label = "#{params[:label]}"
    self.notation = "#{params[:notation]}"
    self.preferredTerm = "#{params[:preferredTerm]}"
    self.synonym = "#{params[:synonym]}"
    self.definition = "#{params[:definition]}"
    # Create the query
    update = UriManagement.buildNs(self.namespace, ["iso25964"]) +
      "DELETE { :" + self.id + " ?p ?o } \n" +
      "INSERT \n" +
      "{ \n" +
      "  :" + self.id + " rdfs:label \"#{self.label}\"^^xsd:string . \n" +
      # Dont allow identifier to be updated.
      #"  :" + self.id + " iso25964:identifier \"#{self.identifier}\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:notation \"#{self.notation}\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:preferredTerm \"#{self.preferredTerm}\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:synonym \"#{self.synonym}\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:definition \"#{self.definition}\"^^xsd:string . \n" +
      "} \n" +
      "WHERE \n" +
      "{\n" +
      "  :" + self.id + " (iso25964:identifier|iso25964:notation|iso25964:preferredTerm|iso25964:synonym|iso25964:definition) ?o .\n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  def destroy()
    self.errors.clear
    # Create the query
    if self.children.length == 0
      update = UriManagement.buildNs(self.namespace, ["iso25964"]) +
        "DELETE \n" +
        "{\n" +
        "  :" + self.id + " ?a ?b . \n" +
        "  ?d iso25964:hasConcept :" + self.id + " . \n" +
        "  ?c iso25964:hasChild :" + self.id + " . \n" +
        "}\n" +
        "WHERE\n" + 
        "{\n" +
        "  :" + self.id + " ?a ?b . \n" +
        "  OPTIONAL { ?d iso25964:hasConcept :" + self.id + " } \n" +
        "  OPTIONAL { ?c iso25964:hasChild :" + self.id + " } \n" +
        "}\n"
      # Send the request, wait the resonse
      response = CRUD.update(update)
      # Response
      if !response.success?
        ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
        raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
      end
      return true
    else
      self.errors.add(:base, "The Thesaurus Concept, identifier #{self.identifier}, has children. It cannot be deleted.")
      return false
    end
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

  def self.from_json(json)
    object = super(json)
    object.identifier = "#{json[:identifier]}"
    object.notation = "#{json[:notation]}"
    object.preferredTerm = "#{json[:preferredTerm]}"
    object.synonym = "#{json[:synonym]}"
    object.definition = "#{json[:definition]}"
    return object
  end

  def to_sparql_v2(parent_id, sparql)
    ConsoleLogger::log(C_CLASS_NAME, "to_sparql_v2", "object=#{self.to_json}")
    cid_extension = self.identifier
    # TODO Quick fix, this needs to be centralised better.
    self.id = "#{parent_id}#{Uri::C_UID_SECTION_SEPARATOR}#{cid_extension.gsub(/[^0-9A-Za-z_]/, '')}"
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:namespace => self.namespace, :id => self.id}
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "identifier"}, {:literal => "#{self.identifier}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "notation"}, {:literal => "#{self.notation}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "preferredTerm"}, {:literal => "#{self.preferredTerm}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "synonym"}, {:literal => "#{self.synonym}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "definition"}, {:literal => "#{self.definition}", :primitive_type => "string"})
    return id
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = ThesaurusConcept.find_for_parent(triples, object.get_links(UriManagement::C_ISO_25964, "hasChild"))
    object.children.each do |child|
      child.parentIdentifier = object.identifier
    end
  end

end