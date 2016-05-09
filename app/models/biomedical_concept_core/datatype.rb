class BiomedicalConceptCore::Datatype < IsoConceptNew

  attr_accessor :datatype, :propertySet
  validates_presence_of :datatype, :propertySet

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Datatype"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Datatype"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.propertySet = Array.new
    if triples.nil?
      super
      self.datatype = ""
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
    #if children
      children_from_triples(object, triples, id)
    #end
    object.triples = ""
    return object
  end

  def self.find_parent(triples, id)
    object = new(triples, id)
    datatypeLinks = object.get_links(C_SCHEMA_PREFIX, "hasDatatypeRef")
    if datatypeLinks.length >= 1
      object.datatype = getDatatype(datatypeLinks[0])
    end
    return object
  end
  
  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Array.new
    self.propertySet.each do |oProperty|
      if !oProperty.isComplex? 
        results << oProperty
      else
        set = oProperty.flatten
        set.each do |iProperty|
          results << iProperty
        end
      end
    end
    return results
  end

	def to_api_json
    #ConsoleLogger::log(C_CLASS_NAME,"to_edit","*****ENTRY*****")
    results = Array.new
    self.propertySet.each do |oProperty|
      if !oProperty.isComplex? 
        results << oProperty.to_minimum
      else
        set = oProperty.to_api_json
        set.each do |iProperty|
          results << iProperty
        end
      end
    end
    return results
  end
  
  def to_sparql(parent, ordinal, params, sparql, prefix)
    id = parent + Uri::C_UID_SECTION_SEPARATOR + 'DT' + ordinal.to_s
    sparql.triple("", id, "rdf", "type", prefix, "DataType")
    sparql.triple_primitive_type("", id, prefix, "ordinal", ordinal.to_s, "positiveInteger")
    sparql.triple("", id, prefix, "isDatatypeOf", "", parent.to_s)
    sparql.triple("", id, prefix, "hasDatatypeRef", UriManagement::C_MDR_ISO21090, get_ref("hasDatatypeRef"))
    ordinal = 1
    self.propertySet.each do |property|
      sparql.triple("", id, prefix, "hasProperty", "", id + Uri::C_UID_SECTION_SEPARATOR + 'P' + ordinal.to_s)
      ordinal += 1
    end
    ordinal = 1
    self.propertySet.each do |property|
      property.to_sparql(id, ordinal, params, sparql, prefix)
      ordinal += 1
    end
  end

private

  def self.children_from_triples(object, triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","*****ENTRY*****")
    object.propertySet = BiomedicalConceptCore::Property.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasProperty"))
    #ConsoleLogger::log(C_CLASS_NAME,"children_from_triples","Datatype=" + object.datatype.to_json.to_s)
    datatypeLinks = object.get_links(C_SCHEMA_PREFIX, "hasDatatypeRef")
    if datatypeLinks.length >= 1
      object.datatype = getDatatype(datatypeLinks[0])
    end
  end

  def get_ref(predicate)
    result = ""
    ref = self.get_links(C_SCHEMA_PREFIX, predicate)
    if ref.length >= 1
      result = ModelUtility::extractCid(ref[0])
    end
    return result
  end

  def self.getDatatype (uri)
    text = ModelUtility.extractCid(uri)
    parts = text.split("-")
    if parts.size == 2
      result = parts[1]
    else
      result = ""
    end
    return result 
  end

end