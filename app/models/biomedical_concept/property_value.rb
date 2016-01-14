class BiomedicalConcept::PropertyValue < IsoConcept

  attr_accessor :clis, :cli, :next
  validates_presence_of :clis, :cli, :next

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
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    object.clis = Hash.new  
    if object.links.exists?(C_SCHEMA_PREFIX, "value")
      links = object.links.get(C_SCHEMA_PREFIX, "value")
      # FIX: Nasty bodge, needs fixing. BC setup looks wrong!
      if links[0] != ""
        object.cli = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        object.clis[object.cli.id] = object.cli
      else
        object.cli = nil
      end
    else
      object.cli = nil
    end
    #ConsoleLogger::log(C_CLASS_NAME,"find","Links=" + object.links.to_s)    
    if object.links.exists?(C_SCHEMA_PREFIX, "nextValue")
      # Recurse to run through the chain of values and add the values (CLIs)
      # to the top level (first in chain) PropertyValue CLI collection
      links = object.links.get(C_SCHEMA_PREFIX, "nextValue")
      id = ModelUtility.extractCid(links[0])
      ns = ModelUtility.extractNs(links[0])
      object.next = find(id, ns)
      object.next.clis.each do |key, cli|
        object.clis[cli.id] = cli
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"findNext","Clis=" + object.clis.to_json)
    return object  
  end

  def self.findForParent(links, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasValue", links, ns)
    return results
  end

private
  
  def self.setAttributes(object)
    object.label = object.properties.getOnly(C_SCHEMA_PREFIX, "name")[:value]      
    object.alias = object.properties.getOnly(C_SCHEMA_PREFIX, "alias")[:value]      
    object.collect = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "collect")[:collect])      
    object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enbaled")[:enabled])      
    object.qText = object.properties.getOnly(C_SCHEMA_PREFIX, "qText")[:value]    
    object.pText = object.properties.getOnly(C_SCHEMA_PREFIX, "pText")[:value]  
    object.bridgPath = object.properties.getOnly(C_SCHEMA_PREFIX, "bridgPath")[:value]  
  end

end