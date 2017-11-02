class CrossReference < IsoConcept
  
  attr_accessor :children, :comments, :ordinal
  
  C_CLASS_NAME = self.name
  C_SCHEMA_PREFIX = "bcr"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_RDF_TYPE = "CrossReference"
 	C_CID_SUFFIX = "XR"

  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    self.children = []
    self.comments = ""
    self.ordinal = 1
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # From Hash
  #
  # @param [Hash] params
  # @return [CrossReference] The object
  def self.from_hash(params)
    object = self.from_json(params)
    object.comments = params[:comments]
    object.ordinal = params[:ordinal]
    params[:children].each { |c| object.children << OperationalReferenceV2.from_json(c) } if !params[:children].blank?
    return object
  end

  # To Hash
  #
  # @return [Hash] The hash
  def to_hash()
    result = to_json
    result[:comments] = self.comments
    result[:ordinal] = self.ordinal
    result[:children] = []
    self.children.each { |c| result[:children] << c.to_json }
    return result
  end

  # To SPARQL
  #
  # @param parent_uri [object] URI object
  # @param sparql [object] The SPARQL object
  # @return [Sparql] The SPARQL object created.
  def to_sparql_v2(parent_uri, sparql)
    self.namespace = parent_uri.namespace
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{C_CID_SUFFIX}#{self.ordinal}"
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ordinal"}, {:literal => "#{self.ordinal}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "comments"}, {:literal => "#{self.comments}", :primitive_type => "string"})
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, "hasCrossReference", C_CID_SUFFIX, child.ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasCrossReference"}, {:uri => ref_uri})
    end
    return uri
  end

end
