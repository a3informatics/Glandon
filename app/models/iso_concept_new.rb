class IsoConceptNew

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
    
  attr_accessor :id, :namespace, :rdf_type, :label, :links, :extension_properties, :triples, :properties
  
  # Constants
  C_CID_PREFIX = "ISOC"
  C_NS_PREFIX = "mdrCons"
  C_CLASS_NAME = "IsoConcept"
  
  C_RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  C_RDFS_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  #C_ISO_LINK = "http://www.assero.co.uk/ISO11179Concepts#link"
  #C_ISO_PROPERTY = "http://www.assero.co.uk/ISO11179Concepts#property"

  # Class data
  @@property_attributes 
  @@link_attributes 
  
  def persisted?
    id.present?
  end
 
  def initialize(triples=nil, id=nil)    
    # Make sure we have the attributes and link info set. 
    # Should only execute once. Class level info.
    @@property_attributes ||= get_property_attributes
    @@link_attributes ||= get_link_attributes
    # Set default values
    self.id = ""
    self.namespace = ""
    self.rdf_type = ""
    self.label = ""
    self.properties = Array.new
    self.links = Array.new
    self.extension_properties = Array.new
    self.triples = Array.new
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
          elsif @@link_attributes.has_key?(triple[:predicate])
            self.links << {:rdf_type => triple[:predicate], :value => triple[:object]}
          else
            # TODO: Make this more capable, but will do as a hook at the mo.
            self.extension_properties << {:rdf_type => triple[:predicate], :value => triple[:object]}
          end
        end
      end
    end
  end

  # Does the item exist.
  def self.exists?(property, propertyValue, rdfType, schemaNs, instanceNs)
    result = false
    prefix = UriManagement.getPrefix(schemaNs)
    prefixSet = []
    prefixSet << prefix
    query = UriManagement.buildNs(instanceNs, prefixSet) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type " + prefix + ":" + rdfType + " . \n" +
      "  ?a " + prefix + ":" + property + " \"" + propertyValue + "\" . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    if xmlDoc.xpath("//result").length >= 1
      result = true
    end
    return result
  end

  def self.find(id, ns)    
    # Create the query and action.
    query = UriManagement.buildNs(ns, ["isoC"]) +
      "SELECT ?s ?p ?o WHERE \n" +
      "{ \n" +
      "  :" + id + " (:|!:)* ?s .\n" +
      "  ?s ?p ?o .\n" + 
      "  FILTER(STRSTARTS(STR(?s), \"" + ns + "\")) \n" +
      "}"
    response = CRUD.query(query)
    uri = Uri.new
    uri.setNsCid(ns, id)
    subject = uri.all
    # Process the response.
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
    # Create the object based on the triples.
    object = new(triples, id)
    return object
  end

  # Find all objects of a given type using the link set.
  def self.find_for_parent(triples, links)
    results = Array.new
    links.each do |link|
      object = find_from_triples(triples, ModelUtility.extractCid(link))
      results << object
    end
    return results
  end
  
  # Find all objects of a given type using the link set.
  # TODO: Why different from the above, code is the same?
  def self.find_for_child(triples, links)    
    results = Array.new
    links.each do |link|
      object = find_from_triples(triples, ModelUtility.extractCid(link))
      results << object
    end
    return results
  end

  # Find all concepts of a given type within specified namespace.
  def self.all(rdfType, ns)
    results = Hash.new
    query = UriManagement.buildNs(ns, []) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
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
        object.rdfType = rdfType
        object.label = label
      end
    end
    return results
  end

  # Build the sparql to create the concept triples.
  def self.to_sparql(parent_id, sparql, schema_prefix, rdf_type, label)
    sparql.triple("", parent_id, UriManagement::C_RDF, "type", schema_prefix, rdf_type)
    sparql.triple_primitive_type("", parent_id, UriManagement::C_RDFS, "label", label, "string")
  end

  def link_exists?(prefix, type)
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    l = @links.select {|link| link[:rdf_type] == uri.all } 
    if l.length == 0
      return false
    else
      return true
    end
  end

  # Get the links of a certain type from the set of links.
  def get_links(prefix, rdf_type)
    results = Array.new
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, rdf_type)
    l = @links.select {|link| link[:rdf_type] == uri.all } 
    if l.length > 0
      results = l.map { |link| link[:value] }
    end
    return results
  end

private

  def set_class_instance(triple)
    name = ModelUtility.extractCid(triple[:predicate])
    xsd_type = @@property_attributes[triple[:predicate]][:rdf_type]
    literal = triple[:object]
    if xsd_type == "http://www.w3.org/2001/XMLSchema#string"
      self.instance_variable_set("@#{name}", "#{literal}")
    elsif xsd_type == "http://www.w3.org/2001/XMLSchema#boolean"
      value = literal.to_bool
      self.instance_variable_set("@#{name}", value)
    elsif xsd_type == "http://www.w3.org/2001/XMLSchema#integer" || xsd_type == "http://www.w3.org/2001/XMLSchema#positiveInteger"
      value = literal.to_i
      self.instance_variable_set("@#{name}", value)
    else
      self.instance_variable_set("@#{name}", "#{literal}")
    end
  end

  # Find the list of properties from the DB schema.
  def get_property_attributes
    result = get_attributes("property")
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
      "SELECT ?a ?b ?c WHERE\n" +
      "{ \n" +
      "  ?a rdfs:subPropertyOf " + UriManagement::C_ISO_C + ":" + rdf_type + " .\n" +
      "  ?a rdfs:label ?b .\n" +
      "  ?a rdfs:range ?c .\n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      rdf_type = ModelUtility.getValue('c', true, node)
      result[uri] = {:uri => uri, :label => label, :rdf_type => rdf_type}
    end
    return result
  end

end