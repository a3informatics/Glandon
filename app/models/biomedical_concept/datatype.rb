class BiomedicalConcept::Datatype < IsoConcept

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
  
  def self.find(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + object.to_json)
    setAttributes(object)
    object.propertySet = BiomedicalConcept::Property.findForParent(object.links, ns, object.datatype)
    return object  
  end

  def self.findForParent(links, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasDatatype", links, ns)
    return results
  end

  def self.findForChild(links, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"findForChild","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasComplexDatatype", links, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + results.to_json)
    return results
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

private

  def self.setAttributes(object)
    datatypeLinks = object.links.get(C_SCHEMA_PREFIX, "hasDatatypeRef")
    ConsoleLogger::log(C_CLASS_NAME,"setAttributes","datatypeLinks=" + datatypeLinks.to_s)
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