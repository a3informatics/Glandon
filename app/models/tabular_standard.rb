# Handles a tabular structure as a managed item. Note that the class should never
#  be used directly, it needs to be configured with several constants from the sub-class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @!attribute rule
#   @return [String] any rule for the tabular structure.
# @!attribute identifier
#   @return [String] the identifier for the managed item
# @!attribute cid_prefix
#   @return [String] the CID prefix used in constructing instance URIs
class TabularStandard < IsoManaged
  
  # Attributes
  attr_accessor :references, :collections
  
  # Constants
  C_CLASS_NAME = self.name

  # Initialize
  #
  # @params [Hash] triples the triples indexed by id (fragment)
  # @params [String] the id of the object to be initialized
  # @return [Void] no return
  def initialize(triples=nil, id=nil)
    self.references = []
    self.collections = []
    super(triples, id)
    self.rdf_type = self.class::C_RDF_TYPE_URI.to_s if triples.nil?
  end

  # Find the given object.
  #
  # @param [String] id the id of the domain. Note this is the true id, not a fragment.
  # @param [Boolean] children find all child objects. Defaults to true.
  # @return [Object] the resulting object.
  def self.find(id, children=true)
    uri = UriV3.new(id: id)
    object = super(uri.fragment, uri.namespace)
    object.children_from_triples if children
    object.triples = {}
    return object
  end

  # Find all the tabular standards
  #
  # @return [Array] array of objects found
  def self.all
    return IsoManaged.all_by_type(self::C_RDF_TYPE, self::C_SCHEMA_NS)
  end

  # Find all the released models
  #
  # @return [Array] array of objects found
  def self.list
    return super(self::C_RDF_TYPE, self::C_SCHEMA_NS)
  end

  # Find history for a given identifier within a specified scope.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :identifier the identifier of the items required.
  # @option params [String] :scope_id the id of the scoping namespace (namespace within which the identifier is unique)
  # @return [Array] An array of objects found.
  def self.history(params)    
    return super(self::C_RDF_TYPE, self::C_SCHEMA_NS, params)
  end

  def add_child(child)
    ref = OperationalReferenceV2.new
    ref.subject_ref = child.uri
    self.references << ref
    ref.ordinal = self.references.count 
  end

  # From Json
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmIg] the object created
  def self.from_json(json)
    object = super(json)
    json[:references].each {|r| object.domain_refs << OperationalReferenceV2.from_json(r) } if !json[:references].blank?
    return object
  end

  # To Json
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:references] = []
    self.references.sort_by! {|u| u.ordinal}
    self.references.each {|r| json[:references] << r.to_json}
    return json
  end

  # To SPARQL
  #
  # @param parent_uri [UriV2] URI object
  # @param sparql [SparqlUpdateV2] The SPARQL object
  # @return [UriV2] The URI
  def to_sparql_v2(sparql, schema_prefix)
    subject = {:uri => self.uri}
    self.collections.each {|k, c| c.to_sparql(self.uri, sparql)}
    super(sparql, schema_prefix)
    self.references.each do |ref|
      ref_uri = ref.to_sparql_v2(self.uri, "includesTabulation", 'TR', ref.ordinal, sparql)
      sparql.triple(subject, {:prefix => schema_prefix, :id => "includesTabulation"}, {:uri => ref_uri})
    end
    return self.uri
  end

  # Check Valid
  #
  # @return [Boolean] returns true if valid, false otherwise.
  def valid?
    super
  end
  
  # Import Params Valid. Check the import parameters.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :version the version, integer
  # @option params [String] :date, a valid date
  # @option params [String] :files, at least one file
  # @option params [String] :semantic_version, a valid semantic version
  # @return [Errors] active record errors class
  def self.import_params_valid?(params)
    object = self.new
    FieldValidation::valid_version?(:version, params[:version], object)
    FieldValidation::valid_date?(:date, params[:date], object)
    FieldValidation::valid_files?(:files, params[:files], object)
    FieldValidation::valid_semantic_version?(:semantic_version, params[:semantic_version], object)
    return object
  end

end