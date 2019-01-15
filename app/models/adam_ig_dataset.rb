# AdamModel. Class for processing ADaM Model Excel Files
#
# @!attribute children
#   @return [Array] the array of child variables
# @!attribute prefix
#   @return [String] @todo not sure needed
# @!attribute structure
#   @return [String] @todo not sure needed
# @author Dave Iberson-Hurst
# @since 2.21.0
class AdamIgDataset < Tabular
  
  attr_accessor :children, :prefix, :structure

  # Constants
  C_CLASS_NAME = self.name
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_IGD
  C_CID_PREFIX = AdamIg::C_CID_PREFIX
  C_RDF_TYPE = "IgDataset"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.prefix = SdtmUtility::C_PREFIX
    self.structure = ""
    self.children = []
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Update Variables.
  #
  # @return [Void] no return
  def update_variables(args)
    self.children.each do |child|
      child.datatype = args[:datatype].add(child.datatype.label)
      child.compliance = args[:compliance].add(child.compliance.label)
    end
  end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
	# @return [UriV2] The URI
  def to_sparql_v2(sparql)
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prefix"}, {:literal => "#{self.prefix}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "structure"}, {:literal => "#{self.structure}", :primitive_type => "string"})
		self.children.each do |child|
    	ref_uri = child.to_sparql_v2(self.uri, sparql)
    	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {:uri => ref_uri})
    end
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmIgDomain] the object created
  def self.from_json(json)
    object = super(json)
    object.prefix = json[:prefix]
    object.structure = json[:structure]
    json[:children].each {|c| object.children << AdamIgDataset::Variable.from_json(c)} if !json[:children].blank?
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:prefix] = self.prefix
    json[:structure] = self.structure
    json[:children] = []
    self.children.sort_by! {|u| u.ordinal}
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  alias :to_hash :to_json
  
  # Build. Build an object from the operational hash
  #
  # @param [Hash] params the operational hash (see IsoManaged)
  # @return [AdamIgDataset] the object created
  def self.build(params)
    super(params, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  end

  def children_from_triples
    self.children = AdamIgDataset::Variable.find_for_parent(triples, self.get_links(C_SCHEMA_PREFIX, "includesColumn"))
  end

end
