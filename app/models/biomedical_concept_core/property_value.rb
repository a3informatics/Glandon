class BiomedicalConceptCore::PropertyValue < IsoConcept

  attr_accessor :cli, :ordinal
  validates_presence_of :cli, :ordinal

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::PropertyValue"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "PropertyValue"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  # Instance data
  @cli

  def self.find(id, ns)
    object = super(id, ns)
    object.ordinal = object.properties.getOnly(C_SCHEMA_PREFIX, "ordinal")[:value].to_i
    if object.links.exists?(C_SCHEMA_PREFIX, "value")
      links = object.links.get(C_SCHEMA_PREFIX, "value")
      if links[0] != ""
        object.cli = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
      else
        object.cli = nil
      end
    else
      object.cli = nil
    end
    return object  
  end

  def self.findForParent(object, ns)    
    results = super(C_SCHEMA_PREFIX, "hasValue", object.links, ns)
    return results
  end

  def self.to_sparql(parent, ordinal, params, sparql, prefix)
    id = parent + Uri::C_UID_SECTION_SEPARATOR + 'PV' + ordinal.to_s
    sparql.triple("", id, UriManagement::C_RDF, "type", prefix, "PropertyValue")
    sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
    sparql.triple_uri("", id, prefix, "value", params[:uri_ns], params[:uri_id])
  end

end