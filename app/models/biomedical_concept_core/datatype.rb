class BiomedicalConceptCore::Datatype < IsoConcept

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
  
  def self.find(id, ns, children=true)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + object.to_json)
    setAttributes(object)
    if children
      object.propertySet = BiomedicalConceptCore::Property.findForParent(object, ns)
    end
    return object  
  end

  def self.findForParent(object, ns)    
    results = super(C_SCHEMA_PREFIX, "hasDatatype", object.links, ns)
    return results
  end

  def self.findForChild(object, ns)    
    results = super(C_SCHEMA_PREFIX, "hasComplexDatatype", object.links, ns)
    return results
  end

  def self.findParent(id, ns)
    object = find(id, ns, false)
    return object
  end
  
  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    self.propertySet.each do |oKey, oProperty|
      if !oProperty.isComplex? 
        results[oKey] = oProperty
      else
        set = oProperty.flatten
        set.each do |iKey, iProperty|
          results[iKey] = iProperty
        end
      end
    end
    return results
  end

	def to_edit
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    self.propertySet.each do |oKey, oProperty|
      if !oProperty.isComplex? 
        results[oKey] = oProperty.to_minimum
      else
        set = oProperty.to_edit
        set.each do |iKey, iProperty|
          results[iKey] = iProperty
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
    self.propertySet.each do |key, property|
      sparql.triple("", id, prefix, "hasProperty", "", id + Uri::C_UID_SECTION_SEPARATOR + 'P' + ordinal.to_s)
      ordinal += 1
    end

    ordinal = 1
    self.propertySet.each do |key, property|
      property.to_sparql(id, ordinal, params, sparql, prefix)
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

  def self.setAttributes(object)
    datatypeLinks = object.links.get(C_SCHEMA_PREFIX, "hasDatatypeRef")
    if datatypeLinks.length >= 1
      object.datatype = getDatatype(datatypeLinks[0])
    else
      object.datatype = ""
    end
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