class BiomedicalConceptCore::Item < IsoConceptNew

  attr_accessor :datatypes, :alias, :ordinal
  validates_presence_of :datatypes, :alias, :ordinal

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Item"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Item"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.datatypes = Array.new
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
    object.triples = ""
    return object  
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    children_from_triples(object, triples, id)
    object.triples = ""
    return object
  end

  def flatten
    results = Array.new
    self.datatypes.each do |datatype|
      more = datatype.flatten
      more.each do |datatype|
        results << datatype
      end
    end
    return results
  end

	def to_edit
    results = Array.new
    self.datatypes.each do |datatype|
      more = datatype.to_edit
      more.each do |datatype|
        results << datatype
      end
    end
    return results
  end
  
  def to_sparql(parent, ordinal, params, sparql, prefix)
    id = parent + Uri::C_UID_SECTION_SEPARATOR + 'I' + ordinal.to_s
    sparql.triple("", id, UriManagement::C_RDF, "type", prefix, "Item")
    sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
    sparql.triple("", id, prefix, "isItemOf", "", parent.to_s)
    sparql.triple("", id, prefix, "hasClassRef", UriManagement::C_MDR_BRIDG, get_ref("hasClassRef"))
    sparql.triple("", id, prefix, "hasAttributeRef", UriManagement::C_MDR_BRIDG, get_ref("hasAttributeRef"))
    sparql.triple_primitive_type("", id, prefix, "alias", self.alias.to_s, "string")
    ordinal = 1
    self.datatypes.each do |datatype|
      sparql.triple("", id, prefix, "hasDatatype", "", id + Uri::C_UID_SECTION_SEPARATOR + 'DT' + ordinal.to_s)
      ordinal += 1
    end
    ordinal = 1
    self.datatypes.each do |datatype|
      datatype.to_sparql(id, ordinal, params, sparql, prefix)
      ordinal += 1
    end
  end

private

  def self.children_from_triples(object, triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****ENTRY*****")
    object.datatypes = BiomedicalConceptCore::Datatype.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasDatatype"))
  end

  def get_ref(predicate)
    result = ""
    ref = self.get_links(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ModelUtility::extractCid(ref[0])
    end
    return result
  end

end