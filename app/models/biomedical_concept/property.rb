class BiomedicalConcept::Property < IsoConcept

  attr_accessor :alias, :collect, :enabled, :qText, :pText, :datatype, :format, :bridgPath, :values, :complex
  validates_presence_of :alias, :label, :collect, :enabled, :questionText, :promptText, :datatype, :format, :bridgPath, :values, :complex

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
      #ConsoleLogger::log(C_CLASS_NAME,"find","Finding Complex")
      #links = object.links.get(C_SCHEMA_PREFIX, "hasComplexDatatype")
      #ConsoleLogger::log(C_CLASS_NAME,"find","Finding Complex, Links=" + object.links.to_json)
      object.complex = BiomedicalConcept::Datatype.findForChild(object.links, ns)
      #ConsoleLogger::log(C_CLASS_NAME,"find","Finding Complex, Result=" + object.complex.to_json)
      object.values = nil
    else
      object.values = BiomedicalConcept::PropertyValue.findForParent(object.links, ns)
      object.complex = nil
      setAttributes(object)
    end
    return object  
  end

  def self.findForParent(links, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasProperty", links, ns)
    return results
  end

  def isComplex?
    return self.complex != nil
  end

   def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    if self.isComplex? 
      self.complex.each do |key, item|
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
    object.label = object.properties.getOnly(C_SCHEMA_PREFIX, "name")[:value]      
    object.alias = object.properties.getOnly(C_SCHEMA_PREFIX, "alias")[:value]      
    object.collect = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "collect")[:value])      
    object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enabled")[:value])      
    object.qText = object.properties.getOnly(C_SCHEMA_PREFIX, "qText")[:value]    
    object.pText = object.properties.getOnly(C_SCHEMA_PREFIX, "pText")[:value]  
    object.bridgPath = object.properties.getOnly(C_SCHEMA_PREFIX, "bridgPath")[:value]  
  end

end