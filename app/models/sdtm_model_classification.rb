class SdtmModelClassification < EnumeratedLabel
  
  attr_accessor :children, :parent

  C_LINK_TYPE = "classifiedAs"
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_RDF_TYPE = "VariableClassification"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_DEFAULT = "QUALIFIER"
  C_CID_SUFFIX_PARENT = "C"
  C_CID_PARENT_CHILD = "SC"

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
  	self.children = []
    self.parent = false
    if triples.nil?
      super
    else
      super(triples, id)
    end
    self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
  end

  # Get all leaf items (i.e. parent with no children or the children but not parent)
  #
  # @params instance_namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all_leaf(instance_namespace)
    results = Array.new
    query = UriManagement.buildPrefix(C_SCHEMA_PREFIX, [UriManagement::C_BD]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + C_RDF_TYPE + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  MINUS { ?a bd:childClassification ?c } \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + instance_namespace + "\")) \n" +
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
        object.rdf_type = UriV2.new({ id: C_RDF_TYPE , namespace: C_SCHEMA_NS }).to_s
        object.label = label
        results << object
      end
    end
    return results
  end

  # Get all parent items (i.e. parent with or without children)
  #
  # @params instance_namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all_parent(instance_namespace)
    results = Array.new
    query = UriManagement.buildPrefix(C_SCHEMA_PREFIX, [UriManagement::C_BD]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + C_RDF_TYPE + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  MINUS { ?a bd:parentClassification ?c } \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + instance_namespace + "\")) \n" +
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
        object.rdf_type = UriV2.new({ id: C_RDF_TYPE , namespace: C_SCHEMA_NS }).to_s
        object.label = label
        results << object
      end
    end
    return results
  end

  # Get all parent items (i.e. parent with or without children)
  #
  # @params instance_namespace [String] the namespace from which the items are to be retrieved
  # @return [Array] array of SdtmModelDatatype objects
  def self.all_children(id, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, [UriManagement::C_BD]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  :#{id} bd:childClassification ?a . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + namespace + "\")) \n" +
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
        object.rdf_type = UriV2.new({ id: C_RDF_TYPE , namespace: C_SCHEMA_NS }).to_s
        object.label = label
        results << object
      end
    end
    return results
  end

  # Find the defalt parent value (label) from a set of values. Upper case comparison made.
  #
  # @param value_set [Array] the value set, an array from the all method
  # @raise ApplicationLogicError if the item is not found
  # @return [Object] the item found
  def self.default_parent(value_set)
    return EnumeratedLabel.default(value_set, C_DEFAULT)
  end

  # Find the defalt child value (label) from a set of values. Just sets first value.
  # Ready for future sophistication
  #
  # @param value_set [Array] the value set, an array from the all method
  # @return [Object] the item found
  def self.default_child(value_set)
    return value_set[0]
  end

  # To JSON
  #
  # @return [Hash] The object hash 
  def to_json
    return super
  end

  # From JSON
  #
  # @param json [Hash] The hash of values for the object 
  # @return [SdtmModelClassification] The object
  def self.from_json(json)
    return super(json)
  end

  # Add Child
  #
  # @param [SdtmModelClassification] object the object for the child
  # @return [void] no return
  def add_child(object)
  	self.children << object
  end

  # Set Parent
  #
  # @return [void] no return
  def set_parent
  	self.parent = true
  end

  # To SPARQL
  #
  # @param [UriV2] parent_uri the parent URI
	# @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The URI
 	def to_sparql_v2(parent_uri, sparql)
 		suffix = self.parent ? C_CID_SUFFIX_PARENT : C_CID_PARENT_CHILD 
 		self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{suffix}#{Uri::C_UID_SECTION_SEPARATOR}#{self.label.upcase.gsub(/\s+/, "")}"
    self.namespace = parent_uri.namespace
    uri = super(sparql, C_SCHEMA_PREFIX)
  	subject = {uri: uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "parentClassification "}, {:uri => parent_uri}) if !self.parent
    self.children.each do |child| 
    	ref_uri = child.to_sparql_v2(uri, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "childClassification "}, {:uri => ref_uri}) 
    end
    return uri
  end

end
