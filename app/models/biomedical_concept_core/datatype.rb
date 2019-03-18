class BiomedicalConceptCore::Datatype  < BiomedicalConceptCore::Node

  attr_accessor :iso21090_datatype, :children
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Datatype"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Datatype"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    self.iso21090_datatype = ""
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
    results = Array.new
    self.children.each do |child|
      results += child.get_properties
    end
    return results
  end

	# Set Properties
  #
  # param json [hash] The properties
  def set_properties(json)
    self.children.each do |child|
      child.set_properties(json)
    end 
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.iso21090_datatype = json[:iso21090_datatype]
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << BiomedicalConceptCore::Property.from_json(child)
      end
    end
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:iso21090_datatype] = self.iso21090_datatype
    json[:children] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end 
    return json
  end
  
  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{UriV2::C_UID_SECTION_SEPARATOR}DT#{self.ordinal}"
    self.namespace = parent_uri.namespace
    uri = super(sparql)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "iso21090_datatype"}, {:literal => "#{self.iso21090_datatype}", :primitive_type => "string"})
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasProperty"}, { :uri => ref_uri })
    end
    return uri
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = true
    self.children.each do |child|
      if !child.valid?
        result = false
        self.copy_errors(child, "Property, ordinal=#{child.ordinal}, error:")
      end
    end
    return result
  end

private

  def self.children_from_triples(object, triples, id)
    object.children = BiomedicalConceptCore::Property.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasProperty"))
  end

end