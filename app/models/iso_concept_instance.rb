class IsoConceptInstance < IsoItem

  include CRUD
  include ModelUtility
      
  attr_accessor :properties, :links
  validates_presence_of :properties, :links

  # Constants
  C_NS_PREFIX = "mdrCons"
  C_CID_PREFIX = "CI"
  C_CLASS_NAME = "IsoConceptInstance"
       
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def baseNs
    return @@baseNs 
  end
  
  def self.find(id, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    
    # Set the namespace
    useNs = ns || @@baseNs

    # Find the object, get the properties and the links
    object = super(id, ns)
    ConsoleLogger::log(C_CLASS_NAME,"find","Object return, object=" + object.to_s)
    object.properties = IsoPropertyInstance.findForConcept(id, useNs)
    object.links = IsoLinkInstance.findForConcept(id, useNs)
    
    # Return
    return object
    
  end

end