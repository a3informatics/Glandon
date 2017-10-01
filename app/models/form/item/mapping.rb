class Form::Item::Mapping < Form::Item

  attr_accessor :mapping
  
  # Constants
  C_SCHEMA_PREFIX = Form::C_SCHEMA_PREFIX
  C_CLASS_NAME = "Form::Item::Mapping"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "Mapping"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.mapping = ""
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
    object.triples = ""
    return object
  end

  # Find an object from triples
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The id of the item to be found
  # @return [object] The new object
  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:mapping] = self.mapping
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.mapping = json[:mapping]
    return object
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    uri = super(parent_uri, sparql)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "mapping"}, {:literal => "#{self.mapping}", :primitive_type => "string"})
    return uri
  end
  
  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  def to_xml(metadata_version, form_def, item_group_def)
    # Do nothing currently
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    result = result &&
      FieldValidation::valid_mapping?(:mapping, self.mapping, self)
    return result
  end

 end
