class BiomedicalConceptCore::Item < BiomedicalConceptCore::Node

  attr_accessor :bridg_class, :bridg_attribute, :datatype
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Item"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Item"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.bridg_class = ""
    self.bridg_attribute = ""
    self.datatype = BiomedicalConceptCore::Datatype.new
    if triples.nil?
      super
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
    end
  end

  # Get Properties
  #
  # @return [array] Array of leaf (property) JSON structures
  def get_properties
    return self.datatype.get_properties
  end

	# Set Properties
  #
  # param json [hash] The properties
  def set_properties(json)
    self.datatype.set_properties(json)
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.bridg_class = json[:bridg_class]
    object.bridg_attribute = json[:bridg_attribute]
    object.datatype = BiomedicalConceptCore::Datatype.from_json(json[:datatype])
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:bridg_class] = self.bridg_class
    json[:bridg_attribute] = self.bridg_attribute
    json[:children] = Array.new
    json[:datatype] = self.datatype.to_json
    return json
  end
  
  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{UriV2::C_UID_SECTION_SEPARATOR}I#{self.ordinal}"
    self.namespace = parent_uri.namespace
    uri = super(sparql)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "bridg_class"}, {:literal => "#{self.bridg_class}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "bridg_attribute"}, {:literal => "#{self.bridg_attribute}", :primitive_type => "string"})
    ref_uri = self.datatype.to_sparql_v2(uri, sparql)
    sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "hasDatatype"}, { :uri => uri })
    return uri
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = true
    if !self.datatype.valid?
      result = false
      self.copy_errors(self.datatype, "Item error:")
    end
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    datatypes = BiomedicalConceptCore::Datatype.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasDatatype"))
    if datatypes.length > 0
      object.datatype = datatypes[0]
    end
  end

end