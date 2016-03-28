class BiomedicalConceptCore::PropertyValue < IsoConceptNew

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

  def initialize(triples=nil, id=nil)
    self.cli = nil
    if triples.nil?
      super
      ordinal = ""
    else
      super(triples, id)    
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object  
  end

  def self.find_from_triples(triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"find_from_triples","*****ENTRY*****")
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

  def self.to_sparql(parent, ordinal, params, sparql, prefix)
    id = parent + Uri::C_UID_SECTION_SEPARATOR + 'PV' + ordinal.to_s
    sparql.triple("", id, UriManagement::C_RDF, "type", prefix, "PropertyValue")
    sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
    sparql.triple_uri("", id, prefix, "value", params[:uri_ns], params[:uri_id])
  end

private

  def self.children_from_triples(object, triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****ENTRY*****")
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","id=" + id.to_s)
    if object.link_exists?(C_SCHEMA_PREFIX, "value")
      links = object.get_links(C_SCHEMA_PREFIX, "value")
      object.cli = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
      #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","cli=" + object.to_json.to_s)
    end
  end

end