class SdtmModelDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :variable_ref

  # Constants
  C_SCHEMA_PREFIX = SdtmModelDomain::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmModelDomain::C_INSTANCE_PREFIX
  C_CLASS_NAME = "SDTMModelDomain::Variable"
  C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  C_RDF_TYPE = "ClassVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.variable_ref = nil
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find an item
  #
  # @params id [String] the id of the item to be found.
  # @params namespace [String] the namespace of the item to be found.
  # @raise [NotFoundError] if the object is not found.
  # @return [SdtmModelDomain::Variable] the object found.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @param [String] schema_prefix the schema prefix for the triples
	# @return [UriV2] The URI
  def to_sparql_v2(sparql, schema_prefix)
    super(sparql, schema_prefix)
    subject = {:uri => self.uri}
    ref_uri = self.variable_ref.to_sparql_v2(self.uri, OperationalReferenceV2::C_PARENT_LINK_C, 'CR', 1, sparql)
    sparql.triple(subject, {:prefix => schema_prefix, :id => OperationalReferenceV2::C_PARENT_LINK_C}, {:uri => ref_uri})
    return self.uri
  end

	# From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModelDomain::Variable] the object created
  def self.from_json(json)
    object = super(json)
    object.variable_ref = OperationalReferenceV2.from_json(json[:variable_ref])
    return object
  end

  # To JSON
  #
  # @return [Hash] the object hash.
  def to_json
    json = super
    if !self.variable_ref.nil? 
      json[:variable_ref] = self.variable_ref.to_json
    end
    return json
  end

private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    if variable_refs.length > 0 
      object.variable_ref = variable_refs[0]
    end
  end

end
