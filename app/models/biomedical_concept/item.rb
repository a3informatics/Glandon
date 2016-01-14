class BiomedicalConcept::Item < IsoConcept

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
    object.datatypes = BiomedicalConcept::Datatype.findForParent(object.links, ns)
    return object  
  end

  def self.findForParent(links, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY*****")
    results = super(C_SCHEMA_PREFIX, "hasItem", links, ns)
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

end