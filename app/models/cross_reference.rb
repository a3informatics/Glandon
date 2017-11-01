class CrossReference < IsoConcept
  
  attr_accessor :children, :comments
  
  C_CLASS_NAME = self.name
  C_SCHEMA_PREFIX = "bcr"
  C_CLASS_NAME = "CrossReference"
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
    object = super(params)
    json[:comments] = params[:comments]
    json[:children].each { |c| object.children << OperationalReferenceV2(c) } if !json[:children].blank?
    return object
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
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "comments"}, {:literal => "#{self.comments}", :primitive_type => "string"})
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasCrossReference"}, {:uri => ref_uri})
    end
    return uri
  end

end
