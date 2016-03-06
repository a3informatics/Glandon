class BiomedicalConceptCore::Item < IsoConcept

  attr_accessor :datatypes
  validates_presence_of :datatypes

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Item"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Item"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    object.datatypes = BiomedicalConceptCore::Datatype.findForParent(object, ns)
    return object  
  end

  def self.findForParent(object, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasItem", object.links, ns)
    return results
  end

  def flatten
    #ßConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    self.datatypes.each do |key, datatype|
      more = datatype.flatten
      more.each do |key, datatype|
        results[key] = datatype
      end
    end
    return results
  end

	def to_edit
    results = Hash.new
    self.datatypes.each do |key, datatype|
      more = datatype.to_edit
      more.each do |key, datatype|
        results[key] = datatype
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
    sparql.triple_primitive_type("", id, prefix, "alias", get_literal("alias"), "string")
    
    ordinal = 1
    self.datatypes.each do |key, datatype|
      sparql.triple("", id, prefix, "hasDatatype", "", id + Uri::C_UID_SECTION_SEPARATOR + 'DT' + ordinal.to_s)
      ordinal += 1
    end

    ordinal = 1
    self.datatypes.each do |key, datatype|
      datatype.to_sparql(id, ordinal, params, sparql, prefix)
      ordinal += 1
    end
  end

private

  def get_ref(predicate)
    result = ""
    ref = self.links.get(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ModelUtility::extractCid(ref[0])
    end
    return result
  end

  def get_literal(predicate)
    result = ""
    ref = self.properties.get(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ref[0][:value]
    end
    return result
  end

end