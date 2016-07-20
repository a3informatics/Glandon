class SdtmModelDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :variable_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SDTMModelDomain::Variable"
  C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  C_RDF_TYPE = "ClassVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.variable_ref = nil
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.import_sparql(parent_id, sparql, json, map)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    super(id, sparql, UriManagement::C_BD, C_RDF_TYPE, json[:label])
    sparql.triple_primitive_type("", id, UriManagement::C_BD, "ordinal", "#{json[:ordinal]}", "positiveInteger")
    uri = map[json[:variable_name]]
    ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'CR'
    sparql.triple("", id, UriManagement::C_BD, "basedOnVariable", "", ref_id.to_s)
    sparql.triple("", ref_id, UriManagement::C_RDF, "type", UriManagement::C_BO, "CReference")
    sparql.triple_uri_full("", ref_id, UriManagement::C_BO, "hasColumn", uri)
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "enabled", "true", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "optional", "false", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "ordinal", "#{json[:ordinal]}", "positiveInteger")
    return id
  end

private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    object.variable_ref = variable_refs[0]
  end

end
