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
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
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
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
    end
  end

  # Find
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @param children [boolean] Find all child objects. Defaults to true.
  # @return [object] The form object.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  # Exists. Checks if the identifier exists.
  #
  # @return [boolean] True if the identifier exists, false otherwise
  def exists?
    return IsoConcept.exists?("identifier", self.identifier, C_RDF_TYPE, C_SCHEMA_NS, self.namespace)
  end

  # Find by Property values
  #
  # @param params [Hash] hash containing search parameters
  # @param namespace [String] the namespace to be search within
  # @return [Array] array of ThesaurusConcept objects
  def self.find_by_property(params, namespace)
    results = []
    uris = IsoConcept.find_by_property(params, C_RDF_TYPE, C_SCHEMA_NS, namespace)
    uris.each { |x| results << ThesaurusConcept.find(x.id, x.namespace)}
    return results
  end

  # Children?
  #
  # @return [boolean] True if there are children, false otherwise
  def children?
    links = get_links_v2(UriManagement::C_ISO_25964, "hasChild")
    return links.length > 0
  end

  # Add a child concept
  #
  # @params params [Hash] the params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [ThesaurusCocncept] the object created. Errors set if create failed.
  def add_child(params)
    object = ThesaurusConcept.from_json(params)
    object.identifier = "#{self.identifier}.#{object.identifier}"
    if !object.exists?
      if object.valid?
        sparql = SparqlUpdateV2.new
        object.to_sparql_v2(self.uri, sparql)
        sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasChild"}, {:uri => object.uri})
        response = CRUD.update(sparql.to_s)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME, "add_child", "The Thesaurus Concept, identifier #{object.identifier}, was not created")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      end
    else
      object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, already exists")
    end
    return object
  end

  # Update
  #
  # @params params [Hash] The params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [Boolean] true if the update is successful, false otherwise. 
  def update(params)
    result = true
    self.errors.clear
    self.label = "#{params[:label]}"
    self.notation = "#{params[:notation]}"
    self.preferredTerm = "#{params[:preferredTerm]}"
    self.synonym = "#{params[:synonym]}"
    self.definition = "#{params[:definition]}"
    if self.valid?
      update = UriManagement.buildNs(self.namespace, ["iso25964"]) +
        # Note: Dont allow identifier or any links to be updated.
        "DELETE \n" +
        "{\n" +
        "  :" + self.id + " rdfs:label ?a .\n" +
        "  :" + self.id + " iso25964:notation ?b .\n" +
        "  :" + self.id + " iso25964:preferredTerm ?c .\n" +
        "  :" + self.id + " iso25964:synonym ?d .\n" +
        "  :" + self.id + " iso25964:definition ?e .\n" +
        "}\n" +
        "INSERT \n" +
        "{ \n" +
        "  :" + self.id + " rdfs:label \"#{SparqlUtility::replace_special_chars(params[:label])}\"^^xsd:string . \n" +
        "  :" + self.id + " iso25964:notation \"#{SparqlUtility::replace_special_chars(params[:notation])}\"^^xsd:string . \n" +
        "  :" + self.id + " iso25964:preferredTerm \"#{SparqlUtility::replace_special_chars(params[:preferredTerm])}\"^^xsd:string . \n" +
        "  :" + self.id + " iso25964:synonym \"#{SparqlUtility::replace_special_chars(params[:synonym])}\"^^xsd:string . \n" +
        "  :" + self.id + " iso25964:definition \"#{SparqlUtility::replace_special_chars(params[:definition])}\"^^xsd:string . \n" +
        "} \n" +
        "WHERE \n" +
        "{\n" +
        "  :" + self.id + " rdfs:label ?a .\n" +
        "  :" + self.id + " iso25964:notation ?b .\n" +
        "  :" + self.id + " iso25964:preferredTerm ?c .\n" +
        "  :" + self.id + " iso25964:synonym ?d .\n" +
        "  :" + self.id + " iso25964:definition ?e .\n" +
        "}\n"
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
      end
    else
      result = false
    end
    return result
  end

  # Destroy the object
  #
  # @return [boolean] True if object destroyed, otherwise false. If false object will contain the errors.
  def destroy()
    self.errors.clear
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
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "destroy", "Failed to destroy object.")
        raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
      end
      return true
    else
      self.errors.add(:base, "The Thesaurus Concept, identifier #{self.identifier}, has children. It cannot be deleted.")
      return false
    end
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
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
    self.children.sort_by! {|u| u.identifier}
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.identifier = "#{json[:identifier]}"
    object.notation = "#{json[:notation]}"
    object.preferredTerm = "#{json[:preferredTerm]}"
    object.synonym = "#{json[:synonym]}"
    object.definition = "#{json[:definition]}"
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << ThesaurusConcept.from_json(child)
      end
    end
    return object
  end

  # To SPARQL
  #
  # @return [object] The SPARQL object created.
  def to_sparql_v2(parent_uri, sparql)
    cid_extension = self.identifier.split('.').last
    #self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{cid_extension.gsub(/[^0-9A-Za-z\.]/, '')}"
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{cid_extension}"
    self.namespace = parent_uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "identifier"}, {:literal => "#{self.identifier}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "notation"}, {:literal => "#{self.notation}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "preferredTerm"}, {:literal => "#{self.preferredTerm}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "synonym"}, {:literal => "#{self.synonym}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_25964, :id => "definition"}, {:literal => "#{self.definition}", :primitive_type => "string"})
    self.children.sort_by! {|u| u.identifier}
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(self.uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasChild"}, {:uri => ref_uri})
    end
    return self.uri
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_tc_identifier?(:identifier, self.identifier, self) &&
      FieldValidation::valid_submission_value?(:notation, self.notation, self) &&
      FieldValidation::valid_terminology_property?(:preferredTerm, self.preferredTerm, self) &&
      FieldValidation::valid_terminology_property?(:synonym, self.synonym, self) &&
      FieldValidation::valid_terminology_property?(:definition, self.definition, self)
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = ThesaurusConcept.find_for_parent(triples, object.get_links(UriManagement::C_ISO_25964, "hasChild"))
    object.children.each do |child|
      child.parentIdentifier = object.identifier
    end
  end

end