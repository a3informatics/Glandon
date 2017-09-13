class IsoConcept

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
      if !class_triples.nil?
        if class_triples.length > 0
          self.id = ModelUtility.extractCid(class_triples[0][:subject])
          self.namespace = ModelUtility.extractNs(class_triples[0][:subject])
          class_triples.each do |triple|
            if triple[:predicate] == C_RDF_TYPE
              self.rdf_type = triple[:object]
            elsif triple[:predicate] == C_RDFS_LABEL
              self.label = triple[:object]
            elsif @@property_attributes.has_key?(triple[:predicate])
              set_class_property(triple)
            elsif @@extension_attributes.has_key?(triple[:predicate])
              set_class_property(triple, true)
            elsif @@link_attributes.has_key?(triple[:predicate])
              self.links << {:rdf_type => triple[:predicate], :value => triple[:object]}
            else
              # @todo Should we do something else?
            end
          end
        end
      end
    end
    # Set a value for any extension property not found in triples.
    @@extension_attributes.each do |key, attribute|
      items = self.extension_properties.select {|property| property[:rdf_type] == key}
      if items.length == 0 && self.rdf_type == attribute[:domain]
        name = ModelUtility.extractCid(key)
        self.extension_properties << {:rdf_type => key, :instance_variable => name, :label => attribute[:label]}
        self.instance_variable_set("@#{name}", "")
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
  def self.exists?(property, property_value, rdf_type, schema_namespace, instance_namespace)
    result = false
    prefix = UriManagement.getPrefix(schema_namespace)
    prefix_set = []
    prefix_set << prefix
    query = UriManagement.buildNs(instance_namespace, prefix_set) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type " + prefix + ":" + rdf_type + " . \n" +
      "  ?a " + prefix + ":" + property + " \"" + property_value + "\" . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    if xmlDoc.xpath("//result").length >= 1
      result = true
    end
    return result
  end

  # Find by Property value
  #
  # @param params [Hash] name value pairs of search parameters
  # @param rdf_type [string] The RDF type
  # @param schema_namespace [string] The schema namespace
  # @param instance_namespace [string] The instance namespace
  # @return [Array] array of Uri objects
  def self.find_by_property(params, rdf_type, schema_namespace, instance_namespace)
    results = []
    prefix = UriManagement.getPrefix(schema_namespace)
    prefix_set = []
    prefix_set << prefix
    query = UriManagement.buildNs(instance_namespace, prefix_set) +
      "SELECT ?a ?b WHERE \n{ \n  ?a rdf:type #{prefix}:#{rdf_type} . \n"
    params.each { |name, value| query += "  ?a #{prefix}:#{name} \"#{value}\" . \n" }
    query += "  FILTER(STRSTARTS(STR(?a), \"#{instance_namespace}\")) \n}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      results << UriV2.new(uri: ModelUtility.getValue('a', true, node))
    end
    return results
  end

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
    raise Exceptions::NotFoundError.new(message: "Failed to find #{ns}##{id} in #{C_CLASS_NAME} object.") if object.id.empty?
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
      object = find_from_triples(triples, link.id)
      results << object
    end
    return results
  end
  
  # Find an object from triples
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The id of the item to be found
  # @return [object] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, object.triples, id)
    return object
  end

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

  # Create a Object
  #
  # @param sparql [Object] The sparql object for the concept tbeing created
  # @raise [CreateError] If object not created.
  # @return null
  def create(sparql)
    response = CRUD.update(sparql.create)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME, "create", "Failed to create object.")
      raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
    end
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
      "  :#{self.id} ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :#{self.id} ?p ?o . \n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # Create a Child Object
  #
  # @param child [Object] The new child object. Assumed to be valid.
  # @param sparql [Object] The sparql object for the concept tbeing created
  # @param schema_prefix [String] The schema prefix for the link from this parent to the child
  # @param rdf_type [String] The rdf type for the link from this parent to the child
  # @raise [CreateError] If object not created.
  # @return null
  def create_child(child, sparql, schema_prefix, rdf_type)
    sparql.triple({:uri => self.uri}, {:prefix => schema_prefix, :id => rdf_type}, {:uri => child.uri})
    ConsoleLogger.debug(C_CLASS_NAME, "create_child", "SPARQL=#{sparql.to_s}")
    response = CRUD.update(sparql.create)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME, "create_child", "Failed to create child object.")
      raise Exceptions::CreateError.new(message: "Failed to create child " + C_CLASS_NAME + " object.")
    end
  end

  # Destroy Object and links to the object
  #
  # @raise [DestroyError] If object not destroyed.
  # @return null
  def destroy_with_links
    # Create the query
    update = UriManagement.buildNs(self.namespace, []) +
      "DELETE \n" +
      "{\n" +
      "  :#{self.id} ?p1 ?o . \n" +
      "  ?s ?p2 :#{self.id} . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :#{self.id} ?p1 ?o . \n" +
      "  ?s ?p2 :#{self.id} . \n" +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # Update the object
  #
  # @param sparql [Object] The sparql object for the concept tbeing created
  # @raise [DestroyError] If object not destroyed.
  # @return null
  def update(sparql)
    ConsoleLogger.debug(C_CLASS_NAME, "create_child", "UPDATE=#{sparql.update(self.uri)}")
    response = CRUD.update(sparql.update(self.uri))
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME, "update", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
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
        #ConsoleLogger::log(C_CLASS_NAME,"add_extension_property", "Extension=#{@@extension_attributes.to_json}.")
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
    if !json[:extension_properties].blank?
      object.extension_properties = json[:extension_properties]
    end
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
      value = get_extension_value(item[:instance_variable])
      sparql.triple(subject, {:uri => predicate}, {:literal => "#{value}", :primitive_type => IsoUtility.extract_cid(@@extension_attributes[item[:rdf_type]][:xsd_type])})
    end
    return self.uri
  end

  # Links From the concept. Find the links from the concept to other concepts or concepts pointed
  # at by references.
  #
  # @param id [string] The id of the concept
  # @param namespace [string] The namespace of the concept
  # @return [Array] Array of hash, each hash containing the URI and the RDF type of the item found
  def self.links_from(id, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C, UriManagement::C_BO]) +
      "SELECT DISTINCT ?o ?o_type ?ref_o ?ref_o_type WHERE \n" +
      "{ \n" + 
      "  :#{id} ?p ?o . \n" +
      "  ?p rdfs:subPropertyOf isoC:link . \n" +
      "  ?o rdf:type ?o_type . \n" +
      "  OPTIONAL \n" + 
      "  { \n" +  
      "    ?o_type rdfs:subClassOf bo:Reference . \n" + 
      "    ?o ?ref_p ?ref_o . \n" +
      "    ?ref_p rdfs:subPropertyOf isoC:link . \n" + 
      "    ?ref_o rdf:type ?ref_o_type . \n" +
      "  } \n" +
      "}"
    #ConsoleLogger::log(C_CLASS_NAME, "links_from", "Query=#{query}")
    response = CRUD.query(query) 
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      i_object = ModelUtility.getValue('o', true, node)
      i_type = ModelUtility.getValue('o_type', true, node)
      ref_object = ModelUtility.getValue('ref_o', true, node)
      ref_type = ModelUtility.getValue('ref_o_type', true, node)
      #ConsoleLogger::log(C_CLASS_NAME, "links_from", "Query={#{i_object}, #{i_type}, #{ref_object}, #{ref_type}}")
      if ref_object.empty?
        results << { uri: UriV2.new({uri: i_object}), rdf_type: i_type, local: true}
      else
        results << { uri: UriV2.new({uri: ref_object}), rdf_type: ref_type, local: false}
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME, "links_from", "Results={#{results.to_json}}.")
    return results
  end

  # Links To the concept. Find the links to the concept from other concepts or concepts pointed
  # to via references.
  #
  # @param id [string] The id of the concept
  # @param namespace [string] The namespace of the concept
  # @return [Array] Array of hash, each hash containing the URI and the RDF type of the item found
  def self.links_to(id, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C, UriManagement::C_BO]) +
      "SELECT DISTINCT ?s ?s_type ?ref_s ?ref_s_type WHERE \n" +
      "{\n" +
      "  ?s ?p :#{id} .\n" + 
      "  ?s rdf:type ?s_type .\n" +
      "  ?p rdfs:subPropertyOf isoC:link .\n" +
      "  OPTIONAL\n" + 
      "  {\n" +
      "    ?s rdf:type ?c .\n" +
      "    ?c rdfs:subClassOf bo:Reference .\n" + 
      "    ?ref_s ?ref_p ?s .\n" +
      "    ?ref_s rdf:type ?ref_s_type .\n" +
      "  }\n" +
      "}"
    response = CRUD.query(query) 
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      s_object = ModelUtility.getValue('s', true, node)
      s_type = ModelUtility.getValue('s_type', true, node)
      ref_object = ModelUtility.getValue('ref_s', true, node)
      ref_type = ModelUtility.getValue('ref_s_type', true, node)
      #ConsoleLogger::log(C_CLASS_NAME, "links_to", "Query={#{s_object}, #{s_type}, #{ref_object}, #{ref_type}}")
      if ref_object.empty?
        results << { uri: UriV2.new({uri: s_object}), rdf_type: s_type, local: true}
      else
        results << { uri: UriV2.new({uri: ref_object}), rdf_type: ref_type, local: false}
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME, "links_to", "Results={#{results.to_json}}.")
    return results
  end
  
  # Parent. Get the parent object depending on the specififed link type.
  #
  # @param uri [Object] URI of the child concept.
  # @return [Object] The URI of the parent. Nil if not found
  def self.find_parent(uri)
    result = nil
    query = UriManagement.buildNs(uri.namespace, [UriManagement::C_ISO_I, UriManagement::C_ISO_25964, UriManagement::C_BF, UriManagement::C_CBC, UriManagement::C_BD]) +
      "SELECT DISTINCT ?s ?o WHERE \n" +
      "{ \n" +
      "  { \n" +
      "    ?s (iso25964:hasConcept|iso25964:hasChild) :#{uri.id} . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (bf:hasGroup|bf:hasSubGroup|bf:hasItem|bf:hasCommon|bf:hasCommonItem) :#{uri.id} . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (cbc:hasItem|cbc:hasDatatype|cbc:hasProperty) :#{uri.id} . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (bd:includesColumn) :#{uri.id} . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  }\n" +   
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    if nodes.length == 1
      uri = UriV2.new({uri: ModelUtility.getValue('s', true, nodes[0] )})
      rdf_type = ModelUtility.getValue('o', true, nodes[0])
      result = { uri: uri, rdf_type: rdf_type }
    end
    return result
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
    l = @links.select {|link| link[:rdf_type] == uri.to_s } 
    if l.length > 0
      results = l.map { |link| UriV2.new({:uri => link[:value]})}
    end
    return results
  end

  # Get the value of an extension property
  #
  # @param name [string] The name of the extension proeprty
  # @ return [various] The extension property value
  def get_extension_value(name)
    value = self.instance_variable_get("@#{name}")
    return "" if value.nil?
    return value
  end

  # Get the value of an extension property
  #
  # @param name [string] The name of the extension proeprty
  # @ return null
  def set_extension_value(name, value)
    self.instance_variable_set("@#{name}", value)
  end

  # Different?
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [boolean] True if different, false otherwise.
  def self.diff?(previous, current)
    return true if previous.nil?
    return true if current.nil?
    result = diff_properties?(previous, previous.properties, current, current.properties)
    result = diff_properties?(previous, previous.extension_properties, current, current.extension_properties ) if !result 
    return result
  end

  # Difference between this and another object.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Hash] The differenc hash
  def self.difference(previous, current)
    results = {}
    status = :no_change
    if previous.nil? && current.nil?
      status = :not_present
    elsif previous.nil?
      difference_properties(nil, [], current, current.properties, results)
      difference_properties(nil, [], current, current.extension_properties, results)
      status = :created
    elsif current.nil?
      difference_properties(previous, previous.properties, nil, [], results)
      difference_properties(previous, previous.extension_properties, nil, [], results)
      status = :deleted
    else
      changes1 = difference_properties(previous, previous.properties, current, current.properties, results)
      changes2 = difference_properties(previous, previous.extension_properties, current, current.extension_properties, results)
      status = :updated if changes1 || changes2
    end
    return {status: status, results: results}
  end

  # Child Match, do the list of child objects match. The list are compared using
  # a single, specified, property. 
  #
  # @previous [Object] The previous object being compared against
  # @child_name [String] The child array name within the object
  # @variable_name [String] The property name within the object used to uniquely identify the instance.
  # @return [Hash] The differenc hash
  def child_match?(previous, child_name, variable_name)
    current_array = self.instance_variable_get("@#{child_name}")
    previous_array = previous.instance_variable_get("@#{child_name}")
    current_identifiers = current_array.map {|x| x.instance_variable_get("@#{variable_name}")}
    previous_identifiers = previous_array.map {|x| x.instance_variable_get("@#{variable_name}")}
    return false if current_identifiers - previous_identifiers != [] || previous_identifiers - current_identifiers != []
    return true
  end    

  # Deleted Set. Returns a list of deleted items from the previous object.
  #
  # @previous [Object] The previous object being compared against
  # @child_name [String] The child array name within the object
  # @variable_name [String] The property name within the object used to uniquely identify the instance.
  # @return [Hash] The differenc hash
  def deleted_set(previous, child_name, variable_name)
    current_array = self.instance_variable_get("@#{child_name}")
    previous_array = previous.instance_variable_get("@#{child_name}")
    current_identifiers = current_array.map {|x| x.instance_variable_get("@#{variable_name}")}
    previous_identifiers = previous_array.map {|x| x.instance_variable_get("@#{variable_name}")}
    return previous_identifiers - current_identifiers
  end    

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    return FieldValidation.valid_label?(:label, self.label, self)
  end

  # Copy Errors from another object
  #
  # @param object [object] The other object containing errors
  # @param text [string] Text to prefix the errors with
  # @return null
  def copy_errors(object, text)
    object.errors.full_messages.each do |msg|
      self.errors[:base] << "#{text} #{msg}"
    end
  end

  if Rails.env == "test"
    # Return the triples
    #
    # @return [Hash] The triples
    def triples
      return @triples
    end
  end

private

   def self.diff_properties?(previous, previous_properties, current, current_properties)
    previous_labels = previous_properties.map{|x| x[:label]}
    current_labels = current_properties.map{|x| x[:label]}
    return true if current_labels - previous_labels != []
    previous_values = Hash[previous_properties.map{|x| [x[:label], previous.instance_variable_get("@#{x[:instance_variable]}") ]}]
    current_values = Hash[current_properties.map{|x| [x[:label],  current.instance_variable_get("@#{x[:instance_variable]}") ]}]
    return true if current_values != previous_values
    return false
  end

  def self.difference_properties(previous, previous_properties, current, current_properties, results)
    check = {}
    changes = false
    current_properties.each do |current_prop|
      current_value = current.instance_variable_get("@#{current_prop[:instance_variable]}")
      l = previous_properties.select {|previous_prop| previous_prop[:instance_variable] == current_prop[:instance_variable] }
      if l.length == 0
        changes = true
        results[current_prop[:label].to_sym] = {status: :created, previous: "", current: current_value, difference: Diffy::Diff.new("", current_value).to_s(:html) }
      elsif l.length == 1
        previous_value = previous.instance_variable_get("@#{current_prop[:instance_variable]}")
        if previous_value == current_value
          results[current_prop[:label].to_sym] = {status: :no_change, previous: previous_value, current: current_value, difference: "" }
        else
          changes = true
          results[current_prop[:label].to_sym] = {status: :updated, previous: previous_value, current: current_value, difference: Diffy::Diff.new(previous_value, current_value).to_s(:html) }
        end
      end
      check[current_prop[:instance_variable]] = true
    end
    previous_properties.each do |previous_prop|
      if !check.has_key?(previous_prop[:instance_variable])
        changes = true
        previous_value = previous.instance_variable_get("@#{previous_prop[:instance_variable]}")
        results[previous_prop[:label].to_sym] = {status: :deleted, previous: previous_value, current: "", difference: Diffy::Diff.new(previous_value, "").to_s(:html) }
      end
    end
    return changes
  end

  # Set a class property depending on the content of the triple. Save the definition
  def set_class_property(triple, extension=false)
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
      # @todo May be consider a better way to do this. String.to_time type function?
      begin
        value = literal.to_time_with_default
      end
    elsif internal_type == BaseDatatype::C_INTEGER || internal_type == BaseDatatype::C_POSITIVE_INTEGER
      value = literal.to_i
    else
      value = "#{literal}"
    end
    self.instance_variable_set("@#{name}", value)
    if !extension
      self.properties << {:rdf_type => triple[:predicate], :instance_variable => name, :label => @@property_attributes[triple[:predicate]][:label]}
    else
      self.extension_properties << {:rdf_type => triple[:predicate], :instance_variable => name, :label => @@extension_attributes[triple[:predicate]][:label]}
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