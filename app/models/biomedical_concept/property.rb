class BiomedicalConcept::Property < IsoConcept

  attr_accessor :alias, :collect, :enabled, :qText, :pText, :datatype, :format,  :bridgPath, :values, :childComplex, :datatypeComplex
  validates_presence_of :alias, :label, :collect, :enabled, :questionText, :promptText, :datatype, :format, :bridgPath, :values, :childComplex, :datatypeComplex

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept::Property"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Property"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    if object.links.exists?(C_SCHEMA_PREFIX, "hasComplexDatatype")
      object.values = nil
      object.childComplex = BiomedicalConcept::Datatype.findForChild(object, ns)
      object.datatypeComplex = nil
    else
      object.values = BiomedicalConcept::PropertyValue.findForParent(object, ns)
      if object.links.exists?(C_SCHEMA_PREFIX, "isPropertyOf")
        links = object.links.get(C_SCHEMA_PREFIX, "isPropertyOf")
        if links[0] != ""
          object.datatypeComplex = BiomedicalConcept::Datatype.findParent(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        end
      end
      object.childComplex = nil
      setAttributes(object)
    end
    return object  
  end

  def self.findForParent(object, ns)
    results = super(C_SCHEMA_PREFIX, "hasProperty", object.links, ns)
    return results
  end

  def isComplex?
    return self.childComplex != nil
  end

   def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    #if self.isComplex? 
    #  more = self.childComplex.flatten
    #  more.each do |iKey, datatype|
    #    results[iKey] = datatype
    #  end
    #end

    if self.isComplex? 
      self.childComplex.each do |key, item|
        more = item.flatten
        more.each do |iKey, datatype|
          results[iKey] = datatype
        end
      end
    end
    return results
  end

private
  
  def self.setAttributes(object)
    count = 0
    object.label = object.properties.getOnly(C_SCHEMA_PREFIX, "name")[:value]      
    object.alias = object.properties.getOnly(C_SCHEMA_PREFIX, "alias")[:value]      
    object.collect = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "collect")[:value])      
    object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enabled")[:value])      
    object.qText = object.properties.getOnly(C_SCHEMA_PREFIX, "qText")[:value]    
    object.pText = object.properties.getOnly(C_SCHEMA_PREFIX, "pText")[:value]  
    object.bridgPath = object.properties.getOnly(C_SCHEMA_PREFIX, "bridgPath")[:value]
    if object.values != nil
        count = object.values.values[0].clis.length
    end
    if object.datatypeComplex != nil
      object.datatype = getDatatype(object.datatypeComplex.datatype, count)  
      object.format = getFormat(object.datatype)  
    else
      object.datatype = ""
      object.format = ""
    end
    #ConsoleLogger::log(C_CLASS_NAME,"setAttributes","datatype=" + object.to_json)
  end

  def self.getFormat(datatype)
    if datatype == "F"
      return "5.1"
    else
      return ""
    end
  end

  def self.getDatatype (parentDatatype, count)
    result = ""
    if count > 0 then
      result = "CL"
    else
      if parentDatatype == "CD"
        result = "CL"
      elsif parentDatatype == "PQR"
        result = "F"
      elsif parentDatatype == "BL"
        result = "BL"
      elsif parentDatatype == "SC"
        result = "CL"
      elsif parentDatatype == "IVL_TS_DATETIME"
        result = "D+T"
      elsif parentDatatype == "TS_DATETIME"
        result = "D+T"
      else
        result = "S"
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Parent=" + parentDatatype + ", Result=" + result + ", Count=" + count.to_s)
    return result 
  end

end