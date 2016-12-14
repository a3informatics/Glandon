class Form::Group::Common < Form::Group
  
  attr_accessor :children

  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Group::Common"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "CommonGroup"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.children = []
    if triples.nil?
      super
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
    end
  end
# Find the object
  #
  # @param id [string] The id of the item to be found
  # @param ns [string] The namespace of the item to be found
  # @return [object] The new object
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  # Find an object from triples
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The id of the item to be found
  # @return [object] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    return object
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:children] = Array.new
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
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << Form::Item::CommonItem.from_json(child)
      end
    end
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_id, sparql)
    uri = super(parent_id, sparql)
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, sparql)
      sparql.triple({uri: uri}, {:prefix => C_SCHEMA_PREFIX, :id => "hasItem"}, {:uri => ref_uri})
    end
    return uri
  end

  # To XML
  #
  # @param metadata_version [object] 
  # @param form_def [object] 
  # @param item_group_def [object]
  def to_xml(metadata_version, form_def)
    super(metadata_version, form_def)
  end

private

  def self.children_from_triples(object, triples, id)
    super(object, triples, id)
    links = object.get_links_v2(C_SCHEMA_PREFIX, "hasItem")
    links.each do |link|
      object.children << Form::Item::CommonItem.find_from_triples(triples, link.id)
    end  
  end

end
