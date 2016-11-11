#require "nokogiri"
#require "uri"

class IsoConcept

  #include CRUD
  #include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
    
  attr_accessor :id, :namespace, :rdf_type, :label, :links, :properties, :extension_properties, :triples
  
  # Constants
  C_CID_PREFIX = "ISOC"
  C_NS_PREFIX = "mdrCons"
  C_CLASS_NAME = "IsoConcept"
  C_RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  C_RDFS_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  
  # Instance data
  @@property_attributes 
  @@extension_attributes 
  @@link_attributes 
  
  def persisted?
    id.present?
  end

  # Method to get the uri for the concept
  #
  # @return [uri] The uri of the concept
  def uri
    return UriV2.new({:namespace => self.namespace, :id => self.id})
  end

  # Method to get the fragment of the concept type
  #
  # @return [string] The fragment of the concept type
  def rdf_type_fragment
    type = UriV2.new({:uri => self.rdf_type})
    return type.id
  end

  # Get Extension Attributes
  #
  # @return [hash] The attributes
  def extension_attributes
    return @@extension_attributes
  end

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)    
    # Make sure we have the attributes and link info set. 
    # Should only execute once as we use a simple cache mechanism.
    @@property_attributes ||= get_property_attributes
    @@extension_attributes ||= get_extension_attributes
    @@link_attributes ||= get_link_attributes
    # Set default values
    self.rdf_type = ""
    self.id = ""
    self.namespace = ""
    self.label = ""
    self.properties = Array.new
    self.links = Array.new
    self.extension_properties = Array.new
    self.triples = Hash.new
    # If we have triples, process. 
    if !triples.nil?
      class_triples = triples[id]
      self.triples = triples
      if class_triples.length > 0
        self.id = ModelUtility.extractCid(class_triples[0][:subject])
        self.namespace = ModelUtility.extractNs(class_triples[0][:subject])
        class_triples.each do |triple|
          if triple[:predicate] == C_RDF_TYPE
            self.rdf_type = triple[:object]
          elsif triple[:predicate] == C_RDFS_LABEL
            self.label = triple[:object]
          elsif @@property_attributes.has_key?(triple[:predicate])
            set_class_instance(triple)
            self.properties << {:rdf_type => triple[:predicate], :value => triple[:object], :label => @@property_attributes[triple[:predicate]][:label]}
          elsif @@extension_attributes.has_key?(triple[:predicate])
            set_class_instance(triple, true)
            self.extension_properties << {:rdf_type => triple[:predicate], :value => triple[:object], :label => @@extension_attributes[triple[:predicate]][:label]}
          elsif @@link_attributes.has_key?(triple[:predicate])
            self.links << {:rdf_type => triple[:predicate], :value => triple[:object]}
          else
            # Do nothing. Shoudl we do something else?
          end
        end
      end
    end
    # Set a value for any extension property not found in triples.
    @@extension_attributes.each do |key, attribute|
      items = self.extension_properties.select {|property| property[:rdf_type] == key}
      if items.length == 0 && self.rdf_type == attribute[:domain]
        self.extension_properties << {:rdf_type => key, :value => "", :label => attribute[:label]}
      end
    end
  end

  # Get RDF type of the concept. Return nil if not found.
  #
  # @param id [string] The identifier for the concept
  # @param namespace [string] The namespace for the concept
  # @return [object] The type 
  def self.get_type(id, namespace)
    uri = nil
    query = UriManagement.buildNs(namespace, []) +
      "SELECT ?o WHERE \n" +
        "{ \n" +
        "  :" + id + " rdf:type ?o .\n" + 
        "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = UriV2.new({:uri => ModelUtility.getValue('o', true, node)})
    end
    return uri
  end

  # Get the type of the object at the end of a link (uri) 
  #
  # @param [uri] The link
  # @return [string] The type (uri) if found, "" otherwise
  def get_link_object_type_v2(link) 
    #uri = UriV2({ :uri => link[:value] })   
    uri = link
    rdf_type = IsoConcept.get_type(uri.id, uri.namespace)
    rdf_type.nil? ? result = "" : result = rdf_type.to_s 
    return result
  end

  # Does a property with given value exist.
  #
  # @param property [string] The property name
  # @param property_value [string] The property value
  # @param rdf_type [string] The RDF type
  # @param schema_namespace [string] The schema namespace
  # @param instance_namespace [string] The instance namespace
  # @return [boolean] True is property exists, false otherwise
  #def self.exists?(property, property_value, rdf_type, schema_namespace, instance_namespace)
  #  result = false
  #  prefix = UriManagement.getPrefix(schema_namespace)
  #  prefix_set = []
  #  prefix_set << prefix
  #  query = UriManagement.buildNs(instance_namespace, prefix_set) +
  #    "SELECT ?a ?b WHERE \n" +
  #    "{ \n" +
  #    "  ?a rdf:type " + prefix + ":" + rdfType + " . \n" +
  #    "  ?a " + prefix + ":" + property + " \"" + property_value + "\" . \n" +
  #    "}"
  #  response = CRUD.query(quer)
  #  xmlDoc = Nokogiri::XML(response.body)
  #  xmlDoc.remove_namespaces!
  #  if xmlDoc.xpath("//result").length >= 1
  #    result = true
  #  end
  #  return result
  #end

  # Find a given item given the id and namespace
  #
  # @param id [string] The id
  # @param namespace [string] The instance schema namespace
  # @param children [boolean] include all children concepts in the find
  # @return [object] The concept
  def self.find(id, ns, children=true)    
    if children
      query = UriManagement.buildNs(ns, []) +
        "SELECT ?s ?p ?o WHERE \n" +
        "{ \n" +
        "  :" + id + " (:|!:)* ?s .\n" +
        "  ?s ?p ?o .\n" + 
        "  FILTER(STRSTARTS(STR(?s), \"" + ns + "\")) \n" +
        "}"
    else
      query = UriManagement.buildNs(ns, []) +
        "SELECT ?s ?p ?o WHERE \n" +
        "{ \n" +
        "  :" + id + " ?p ?o .\n" +
        "  BIND ( :" + id + " as ?s ) .\n" +
        "}"
    end
    response = CRUD.query(query)
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLiteral = ModelUtility.getValue('o', false, node)
      if predicate != ""
        triple_object = objectUri
        if triple_object == ""
          triple_object = objectLiteral
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
      end
    end
    object = new(triples, id)
    return object
  end

  # Find all objects of a given type using the link set.
  #
  # @param triples [hash] The triples
  # @param links [array] The links
  # @return [array] Array of objects
  def self.find_for_parent(triples, links)
    results = Array.new
    links.each do |link|
      #object = find_from_triples(triples, ModelUtility.extractCid(link))
      object = find_from_triples(triples, link.id)
      results << object
    end
    return results
  end
  
  # Find all objects of a given type using the link set.
  # TODO: Why different from the above, code is the same?
  #def self.find_for_child(triples, links)    
  #  results = Array.new
  #  links.each do |link|
  #    object = find_from_triples(triples, ModelUtility.extractCid(link))
  #    results << object
  #  end
  #  return results
  #end

  # Find all concepts of a given type within specified namespace.
  #
  # @param rdf_type [string] The RDF type
  # @param namespace [string] The namespace
  # @return [array] Array of objects
  def self.all(rdf_type, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, []) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      if uri != "" && label != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = UriV2.new({:namespace => namespace, :id => rdf_type}).to_s
        object.label = label
        results << object
      end
    end
    return results
  end

  # Destroy the object
  #
  # @raise [DestroyError] If object not destroyed.
  # @return null
  def destroy
    # Create the query
    update = UriManagement.buildNs(self.namespace, []) +
      "DELETE \n" +
      "{\n" +
      "  ?s ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " (:|!:)* ?s . \n" +  
      "  ?s ?p ?o . \n" +
      "  FILTER(STRSTARTS(STR(?s), \"" + self.namespace + "\"))" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # Add extension property
  #
  # @param schema_namespace [string] The namespace into which the property is to be created
  # @param params [hash] Hahs containing the property attributes
  # @return null. Sets class errors if problems detected.
  def add_extension_property(schema_namespace, params)
    self.errors.clear
    identifiers = Hash.new
    query = UriManagement.buildNs(schema_namespace, [UriManagement::C_OWL]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  {  \n" +
      "    ?a rdf:type owl:Class . \n" +
      "  } \n" + 
      "  UNION \n" +
      "  { \n" + 
      "    ?a rdf:type owl:ObjectProperty . \n" +
      "  } \n" + 
      "  UNION \n" +
      "  { \n" + 
      "    ?a rdf:type owl:DatatypeProperty . \n" +
      "  } \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + schema_namespace + "\")) \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      if uri != ""
        identifier = ModelUtility.extractCid(uri)
        identifiers[identifier] = identifier
      end
    end
    if identifiers.has_key?(params[:identifier])
      self.errors.add(:base, "The extension property cannot be created. The identifier is already in use.")
    else
      extension = IsoConcept::ExtendedProperty.new(params)
      sparql = SparqlUpdateV2.new
      extension.to_sparql_v2(sparql, UriV2.new({:uri => schema_namespace}), UriV2.new({:uri => self.rdf_type}))
      response = CRUD.update(sparql.to_s)
      if !response.success?
        self.errors.add(:base, "The extension property was not created in the database.")
      else
        @@extension_attributes = get_extension_attributes
        ConsoleLogger::log(C_CLASS_NAME,"add_extension_property", "Extension=#{@@extension_attributes.to_json}.")
      end
    end
  end

  # Destroy Extension Property
  #
  # @param params [hash] Hash containing the uri
  # @raise [DestroyError] Exception raised if destroy fails
  # @return null.
  def destroy_extension_property(params)
    # Create the query
    uri = UriV2.new({:uri => params[:uri]})
    update = UriManagement.buildNs("", []) +
      "DELETE \n" +
      "{\n" +
      "  #{uri.to_ref} ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  #{uri.to_ref} ?p ?o . \n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy_extension", "Failed to destroy extension #{params[:uri]}.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    else
      @@extension_attributes = get_extension_attributes
    end
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = self.new
    object.rdf_type = json[:type]
    object.namespace = json[:namespace]
    object.id = json[:id]
    object.label = json[:label]
    object.extension_properties = json[:extension_properties]
    return object
  end

  # Create the object from data. Will build the id for the object.
  #
  # @param namespace [string] The namespace
  # @param parent_id [string] The parent id.
  # @param schema_prefix [string] The schema prefix
  # @param rdf_type [string] The RDF type
  # @param label [string] The label
  # @return [object] 
  def self.from_data(namespace, parent_id, schema_prefix, rdf_type, label)
    object = self.new
    object.rdf_type = UriV2.new({:namespace => UriManagement.getNs(schema_prefix), :id => rdf_type})
    object.namespace = namespace
    object.id = parent_id
    object.label = label
    object.extension_properties = Array.new
    return object
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    result = 
    { 
      :type => self.rdf_type,
      :id => self.id, 
      :namespace => self.namespace, 
      :label => self.label,
      :extension_properties => Array.new
    }
    extension_properties.each do |item|
      result[:extension_properties] << item
    end
    return result
  end

  # Return the object as SPARQL
  #
  # @param sparql [object] The sparql object being built (to be added to)
  # @param schema_prefix [string] The schema prefix
  # @return [object] The URI of the object
  def to_sparql_v2(sparql, schema_prefix)
    subject = {:namespace => self.namespace, :id => self.id}
    uri = UriV2.new({:uri => self.rdf_type})
    sparql.triple(subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:uri => uri})
    sparql.triple(subject, {:prefix => UriManagement::C_RDFS, :id => "label"}, {:literal => "#{self.label}", :primitive_type => "string"})
    self.extension_properties.each do |item|
      predicate = UriV2.new({ :uri => item[:rdf_type] })
      sparql.triple(subject, {:uri => predicate}, {:literal => "#{item[:value]}", :primitive_type => IsoUtility.extract_cid(@@extension_attributes[item[:rdf_type]][:xsd_type])})
    end
    ConsoleLogger::log(C_CLASS_NAME, "to_sparql_v2", "URI=#{self.uri}.")
    return self.uri
  end

  # Find links to the concept
  #
  # @param id [string] The id of the concept
  # @param namespace [string] The namespace of the concept
  # @return [array] Array o fhash values of link end {id and namespace}
  def self.graph_to(id, namespace)
    # Initialise.
    results = Hash.new
    children = Array.new
    object = nil
    isoC_link = UriV2.new({:namespace => UriManagement.getNs(UriManagement::C_ISO_C), :id => "link"})
    # Create the query and action.
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C]) +
      "SELECT ?s ?p ?o ?p_type WHERE \n" +
      "{ \n" +
      "  :" + id + " ?p ?o .\n" +
      "  BIND ( :" + id + " as ?s ) .\n" +
      "  OPTIONAL { ?p rdfs:subPropertyOf ?p_type . } \n" +
      "}"
    # Get triples
    response = CRUD.query(query) 
    # Process the response.
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      object_uri = ModelUtility.getValue('o', true, node)
      object_literal = ModelUtility.getValue('o', false, node)
      predicate_type = ModelUtility.getValue('p_type', true, node)
      if predicate != ""
        triple_object = object_uri
        if triple_object == ""
          triple_object = object_literal
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
        if predicate_type == isoC_link.to_s
          uri = UriV2.new({:uri => object_uri})
          children << {:id => uri.id, :namespace => uri.namespace}
        end
      end
    end
    object = new(triples, id)
    results = {:parent => object, :children => children}
    return results
  end

  # Find links from the concept
  #
  # @param id [string] The id of the concept
  # @param namespace [string] The namespace of the concept
  # @return [array] Array o fhash values of link end {id and namespace}
  def self.graph_from(id, namespace)
    # Initialise.
    results = Array.new
    # Create the query and action.
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C]) +
      "SELECT DISTINCT ?s WHERE \n" +
      "{ \n" +
      "  ?s ?p :" + id + " . \n" +      
      "  ?p rdfs:subPropertyOf ?p_type .\n" +
      "  FILTER(?p_type = isoC:link) \n" +
      "}"
    response = CRUD.query(query)
    # Process the response.
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = UriV2.new({:uri => ModelUtility.getValue('s', true, node)})
      results << {:id => uri.id, :namespace => uri.namespace}
    end
    return results
  end

  # Does a link exist
  #
  # @param prefix [string] The schema prefix
  # @param rdf_type [string] The RDF type
  # @return [boolean] True if link exists, false otherwise
  def link_exists?(prefix, type)
    ns = UriManagement.getNs(prefix)
    uri = UriV2.new({:namespace => ns, :id => type})
    l = @links.select {|link| link[:rdf_type] == uri.to_s } 
    if l.length == 0
      return false
    else
      return true
    end
  end

  # Get the links of a certain type from the set of links. Returns array of URIs
  #
  # @param prefix [string] The schema prefix
  # @param rdf_type [string] The RDF type
  def get_links(prefix, rdf_type)
    return get_links_v2(prefix, rdf_type)
  end
  
  def get_links_v2(prefix, rdf_type)
    results = Array.new
    namespace = UriManagement.getNs(prefix)
    uri = UriV2.new({:id => rdf_type, :namespace => namespace})
    ConsoleLogger::log(C_CLASS_NAME, "get_links_v2", "uri=#{uri}")
    ConsoleLogger::log(C_CLASS_NAME, "get_links_v2", "links=#{@links.to_json}")
    l = @links.select {|link| link[:rdf_type] == uri.to_s } 
    if l.length > 0
      results = l.map { |link| UriV2.new({:uri => link[:value]})}
    end
    return results
  end

  # Get the links of a certain type from the set of links.
  #def get_extension(prefix, rdf_type)
  #  result = ""
  #  ns = UriManagement.getNs(prefix)
  #  uri = UriV2.new({:namespace => ns, :id => rdf_type})
  #  l = @extension_properties.select {|property| property[:rdf_type] == uri.to_s } 
  #  if l.length == 1
  #    result = l[0][:value]
  #  end
  #  return result
  #end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    return FieldValidation.valid_label?(:label, self.label, self)
  end

private

  def set_class_instance(triple, extension=false)
    name = ModelUtility.extractCid(triple[:predicate])
    predicate = triple[:predicate]
    extension ? xsd_type = @@extension_attributes[predicate][:xsd_type] : xsd_type = @@property_attributes[predicate][:xsd_type]
    internal_type = BaseDatatype.from_xsd(xsd_type)
    literal = triple[:object]
    if internal_type == BaseDatatype::C_STRING
      value = "#{literal}"
    elsif internal_type == BaseDatatype::C_BOOLEAN
      value = literal.to_bool
    elsif internal_type == BaseDatatype::C_DATETIME
      value = Time.parse(literal)
    elsif internal_type == BaseDatatype::C_INTEGER || internal_type == BaseDatatype::C_POSITIVE_INTEGER
      value = literal.to_i
    else
      value = "#{literal}"
    end
    if !extension 
      self.instance_variable_set("@#{name}", value)
    end
  end

  # Find the list of properties from the DB schema.
  def get_property_attributes
    result = get_attributes("property")
    return result
  end

  # Find the list of properties from the DB schema.
  def get_extension_attributes
    result = get_attributes("extensionProperty")
    return result
  end

  # Find the list of links from the DB schema.
  def get_link_attributes
    result = get_attributes("link")
    return result
  end

  # Find the list of properties from the schema.
  def get_attributes(rdf_type)
    result = Hash.new
    query = UriManagement.buildNs("", [UriManagement::C_ISO_C]) +
      "SELECT ?a ?b ?c ?d WHERE\n" +
      "{ \n" +
      "  ?a rdfs:subPropertyOf " + UriManagement::C_ISO_C + ":" + rdf_type + " .\n" +
      "  ?a rdfs:label ?b .\n" +
      "  ?a rdfs:range ?c .\n" +
      "  ?a rdfs:domain ?d .\n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      xsd_type = ModelUtility.getValue('c', true, node)
      domain = ModelUtility.getValue('d', true, node)
      result[uri] = {:uri => uri, :label => label, :domain => domain, :xsd_type => xsd_type}
    end
    return result
  end

end